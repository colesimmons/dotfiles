"""Check real temporary symlinks and shell logic without changing the host account."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPOSITORY = Path(__file__).resolve().parents[1]
FISH = shutil.which("fish")


class DotfilesTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-links-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.repo = self.root / "repo with spaces"
        self.home = self.root / "staged home"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for folder in ("lib", "config", "dotfiles"):
            shutil.copytree(REPOSITORY / folder, self.repo / folder)
        self.env = dict(os.environ, DOTFILES_TARGET_HOME=str(self.home),
                        XDG_CONFIG_HOME=str(self.home / ".config"),
                        XDG_STATE_HOME=str(self.home / ".local/state"),
                        PATH=str(self.bin) + ":/usr/bin:/bin:/usr/sbin:/sbin")

    def shell(self, body, *args, expected=0):
        result = subprocess.run(
            ["/bin/bash", "-c", 'set -Eeuo pipefail; source "$1/lib/common.sh"; '
             'source "$1/lib/dotfiles.sh"; source "$1/lib/fish.sh"; shift; ' + body,
             "test", str(self.repo), *args], cwd=self.root, env=self.env,
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=10,
        )
        self.assertEqual(result.returncode, expected, result.stdout)
        return result.stdout

    def stub(self, name, content):
        path = self.bin / name
        path.write_text("#!/bin/bash\nset -eu\n" + content + "\n")
        path.chmod(0o755)

    def test_preview_writes_nothing(self):
        self.shell('link_dotfiles preview')
        self.assertFalse(self.home.exists())

    def test_links_survive_reruns_and_atomic_edits_reach_repo(self):
        self.shell('link_dotfiles apply')
        fish = self.home / ".config/fish"
        self.assertTrue(fish.is_symlink())
        temporary = fish / "new-config.fish"
        temporary.write_text("# edited through the normal config directory\n")
        temporary.replace(fish / "config.fish")
        self.assertIn("edited through", (self.repo / "dotfiles/fish/config.fish").read_text())
        self.shell('link_dotfiles apply; each_dotfile check_dotfile')
        self.assertFalse((self.home / ".local/state").exists())
        xdg = self.home / ".config/ghostty"
        native = self.home / "Library/Application Support/com.mitchellh.ghostty"
        self.assertEqual(xdg.resolve(), native.resolve())

    def test_conflict_preflight_changes_nothing_even_for_late_entry(self):
        target = self.home / ".local/bin/dotfiles-fish"
        target.parent.mkdir(parents=True)
        target.write_text("keep this file")
        self.shell('link_dotfiles apply', expected=1)
        self.assertEqual(target.read_text(), "keep this file")
        self.assertFalse((self.home / ".config/fish").exists())

    def test_backup_preserves_existing_directory_and_broken_symlink(self):
        fish = self.home / ".config/fish"
        fish.mkdir(parents=True)
        (fish / "local.fish").write_text("# existing private configuration")
        broken = self.home / ".config/starship.toml"
        broken.symlink_to(self.home / "missing-target")
        self.shell('link_dotfiles backup')
        backup, = (self.home / ".local/state/dotfiles/backups").iterdir()
        self.assertIn("private", (backup / "config/fish/local.fish").read_text())
        self.assertTrue((backup / "config/starship.toml").is_symlink())
        self.assertTrue(fish.is_symlink())
        self.shell('link_dotfiles backup')
        self.assertEqual(len(list(backup.parent.iterdir())), 1)

    def test_failed_backup_never_replaces_existing_configuration(self):
        fish = self.home / ".config/fish"
        fish.mkdir(parents=True)
        (fish / "config.fish").write_text("keep me")
        self.stub("mv", "echo 'mv: denied by fixture' >&2; exit 7")
        self.shell('link_dotfiles backup', expected=7)
        self.assertFalse(fish.is_symlink())
        self.assertEqual((fish / "config.fish").read_text(), "keep me")

    def test_failed_link_restores_the_saved_configuration(self):
        fish = self.home / ".config/fish"
        fish.mkdir(parents=True)
        (fish / "config.fish").write_text("restore me")
        self.stub("ln", "echo 'ln: denied by fixture' >&2; exit 6")
        self.shell('link_dotfiles backup', expected=6)
        self.assertFalse(fish.is_symlink())
        self.assertEqual((fish / "config.fish").read_text(), "restore me")

    def test_missing_source_and_traversal_fail_before_mutation(self):
        manifest = self.repo / "config/links.tsv"
        for entry in ("missing\tconfig\tmissing\n", "fish\thome\t../outside\n"):
            with self.subTest(entry=entry):
                manifest.write_text(entry)
                self.shell('link_dotfiles apply', expected=1)
                self.assertFalse(self.home.exists())

    def test_login_shell_registration_and_change_are_idempotent(self):
        state = self.root / "login-shell"
        state.write_text("/bin/zsh\n")
        shells = self.root / "shells"
        shells.write_text("/bin/bash\n/bin/zsh\n")
        log = self.root / "account-actions"
        self.env.update(TEST_SHELL_STATE=str(state), TEST_SHELL_LOG=str(log))
        self.stub("dscl", 'printf "UserShell: "; cat "$TEST_SHELL_STATE"')
        self.stub("sudo", 'echo register >> "$TEST_SHELL_LOG"; exec "$@"')
        self.stub("chsh", 'echo change >> "$TEST_SHELL_LOG"; printf "%s\\n" "$2" > "$TEST_SHELL_STATE"')
        for _ in range(2):
            self.shell('set_fish_login_shell "$1" fixture "$2"', "/fixture/bin/fish", str(shells))
        self.assertEqual(log.read_text().splitlines(), ["register", "change"])
        self.assertEqual(shells.read_text().count("/fixture/bin/fish"), 1)

    def test_failed_registration_does_not_change_the_account(self):
        shells = self.root / "shells"
        shells.write_text("/bin/zsh\n")
        self.stub("dscl", 'echo "UserShell: /bin/zsh"')
        self.stub("sudo", "echo 'sudo: permission denied by fixture' >&2; exit 5")
        self.stub("chsh", "echo SHOULD_NOT_RUN; exit 9")
        output = self.shell('set_fish_login_shell /fixture/bin/fish fixture "$1"', str(shells), expected=5)
        self.assertNotIn("SHOULD_NOT_RUN", output)

    def test_terminal_profile_is_rewritable_and_has_no_source_machine_identity(self):
        profile, = json.loads((self.repo / "dotfiles/iterm2/profiles/fish.json").read_text())["Profiles"]
        self.assertTrue(profile["Rewritable"])
        self.assertEqual(profile["Custom Command"], "Yes")
        self.assertIn("$HOME/.local/bin/dotfiles-fish", profile["Command"])
        self.assertNotIn("/Users/cole", json.dumps(profile))


@unittest.skipUnless(FISH, "Install Fish to run its configuration and worktree checks")
class FishTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-fish-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.config = self.root / "config"
        self.config.mkdir()
        shutil.copytree(REPOSITORY / "dotfiles/fish", self.config / "fish")
        shutil.copytree(REPOSITORY / "dotfiles/starship", self.config / "starship")
        shutil.copyfile(REPOSITORY / "dotfiles/starship.toml", self.config / "starship.toml")
        self.env = dict(os.environ, XDG_CONFIG_HOME=str(self.config),
                        XDG_DATA_HOME=str(self.root / "data"), XDG_CACHE_HOME=str(self.root / "cache"),
                        STARSHIP_CONFIG=str(self.config / "starship.toml"),
                        STARSHIP_CACHE=str(self.root / "starship-cache"),
                        TERM="xterm-256color", GIT_CONFIG_GLOBAL=os.devnull,
                        GIT_CONFIG_NOSYSTEM="1", GIT_AUTHOR_NAME="Fixture",
                        GIT_AUTHOR_EMAIL="fixture@example.invalid", GIT_COMMITTER_NAME="Fixture",
                        GIT_COMMITTER_EMAIL="fixture@example.invalid")
        self.project = self.root / "project with spaces"
        self.project.mkdir()

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.project, env=self.env, text=True).strip()

    def fish(self, code, expected=0, cwd=None):
        result = subprocess.run([FISH, "--no-config", "-c", code],
                                cwd=cwd or self.project, env=self.env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20)
        self.assertEqual(result.returncode, expected, result.stdout)
        return result.stdout

    def test_syntax_and_interactive_startup_without_private_config(self):
        for path in (self.config / "fish").rglob("*.fish"):
            subprocess.run([FISH, "--no-config", "--no-execute", str(path)], env=self.env, check=True)
        result = subprocess.run([FISH, "--interactive", "-c",
                                 "functions -q gs; and functions -q gwt; and functions -q fish_prompt"],
                                env=self.env, cwd=self.project, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_worktree_helpers_handle_subdirectories_dirty_trees_and_keep_branches(self):
        self.git("init", "-q")
        (self.project / "file").write_text("initial")
        self.git("add", "file")
        self.git("commit", "-qm", "initial")
        nested = self.project / "nested"
        nested.mkdir()
        functions = self.config / "fish/functions"
        self.fish(f'source "{functions}/gwt.fish"; gwt demo', cwd=nested)
        worktree, = (self.project / ".worktrees").iterdir()
        branch = worktree.name
        (worktree / "untracked").write_text("keep this")
        self.fish(f'source "{functions}/gwtr.fish"; gwtr "{worktree}"', expected=128)
        self.assertTrue(worktree.exists())
        (worktree / "untracked").unlink()
        self.fish(f'source "{functions}/gwtr.fish"; gwtr "{worktree}"')
        self.assertFalse(worktree.exists())
        self.git("show-ref", "--verify", "refs/heads/" + branch)

    def test_commit_helper_preserves_message_and_rejects_missing_arguments(self):
        self.git("init", "-q")
        (self.project / "file").write_text("initial")
        self.git("add", "file")
        function = self.config / "fish/functions/gc.fish"
        self.fish(f'source "{function}"; gc', expected=1)
        self.fish(f'source "{function}"; gc "A message with spaces"')
        self.assertEqual(self.git("log", "-1", "--format=%s"), "A message with spaces")
