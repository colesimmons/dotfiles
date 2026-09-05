"""Exercise bootstrap boundaries without installing software on the host."""

import errno
import os
from pathlib import Path
import pty
import select
import shutil
import subprocess
import tempfile
import time
import unittest


REPOSITORY = Path(__file__).resolve().parents[1]


class SyntaxTests(unittest.TestCase):
    def test_builtin_bash_parses_all_shell_files(self):
        scripts = list(REPOSITORY.rglob("*.sh")) + [REPOSITORY / "dotfiles/bin/dotfiles-fish"]
        for script in sorted(scripts):
            with self.subTest(script=script.name):
                subprocess.run(["/bin/bash", "-n", str(script)], check=True)


@unittest.skipIf(os.geteuid() == 0, "Installer scripts deliberately reject root")
class ScriptTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-tests-")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.checkout = self.directory / "checkout with spaces"
        self.checkout.mkdir()
        for folder in ("scripts", "lib", "config", "dotfiles"):
            shutil.copytree(REPOSITORY / folder, self.checkout / folder)
        self.bin = self.directory / "bin"
        self.bin.mkdir()
        self.log = self.directory / "commands.log"
        self.log.touch()
        # Exclude the host's Homebrew and user tools; the fake architecture below
        # also prevents fallback to either of the real Homebrew prefixes.
        self.env = {
            "HOME": os.environ["HOME"],
            "PATH": str(self.bin) + ":/usr/bin:/bin:/usr/sbin:/sbin",
            "TMPDIR": str(self.directory),
            "TEST_LOG": str(self.log),
            "TEST_BIN": str(self.bin),
            "DOTFILES_TARGET_HOME": str(self.directory / "home"),
            "TEST_CLT": "1",
            "TEST_PLATFORM": "Darwin",
            "TEST_ARCH": "fixture-architecture",
            "TEST_DOWNLOAD": "success",
            "TEST_INSTALLER": "success",
            "TEST_BUNDLE_CHECK": "0",
            "TEST_BUNDLE_INSTALL": "0",
        }
        self.stub("uname", 'case "$1" in -s) echo "$TEST_PLATFORM" ;; -m) echo "$TEST_ARCH" ;; esac')
        self.stub("sysctl", 'echo "${TEST_TRANSLATED:-0}"')
        self.stub("xcode-select", """
case "$1" in
  -p)
    if [[ "$TEST_CLT" == 1 ]]; then
      echo /fixture/developer
    else
      echo 'xcode-select: no active developer directory' >&2
      exit 1
    fi
    ;;
  --install)
    echo 'xcode-select:install' >> "$TEST_LOG"
    exit "${TEST_CLT_REQUEST:-0}"
    ;;
  *) exit 1 ;;
esac
""")
        self.stub("xcrun", """
[[ "$TEST_CLT" == 1 ]] || exit 1
if [[ "${TEST_BROKEN_TOOL:-}" == "$2" ]]; then
  echo "xcrun: tool $2 is unavailable" >&2
  exit 1
fi
echo "/fixture/bin/$2"
""")
        self.brew_source = self.directory / "brew-stub"
        self.brew_source.write_text("""#!/bin/bash
set -eu
printf 'brew:%s;auto_update=%s;cleanup=%s\\n' "$*" "${HOMEBREW_NO_AUTO_UPDATE:-}" "${HOMEBREW_NO_INSTALL_CLEANUP:-}" >> "$TEST_LOG"
case "$1" in
  --version) echo 'Homebrew fixture' ;;
  --prefix) echo "$TEST_BIN/.." ;;
  bundle)
    case "$2" in
      check)
        [[ "$TEST_BUNDLE_CHECK" == 0 ]] || echo 'Homebrew: fixture-package needs to be installed.' >&2
        exit "$TEST_BUNDLE_CHECK"
        ;;
      install)
        [[ "$TEST_BUNDLE_INSTALL" == 0 ]] || echo 'Homebrew: fixture-package could not be downloaded.' >&2
        exit "$TEST_BUNDLE_INSTALL"
        ;;
      *) exit 91 ;;
    esac
    ;;
  *) exit 92 ;;
esac
""")
        self.env["TEST_BREW_SOURCE"] = str(self.brew_source)
        self.stub("fish", "exit 0")
        self.stub("dscl", 'echo "UserShell: $TEST_BIN/../bin/fish"')
        for line in (self.checkout / "config" / "links.tsv").read_text().splitlines():
            if not line or line.startswith("#"):
                continue
            source, base, relative = line.split("\t")
            home = self.directory / "home"
            target = (home / ".config" if base == "config" else home) / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.symlink_to(self.checkout / "dotfiles" / source)
        self.stub("curl", """
echo 'curl:download' >> "$TEST_LOG"
if [[ "$TEST_DOWNLOAD" != success ]]; then
  echo 'curl: Could not reach the download server.' >&2
  exit 22
fi
destination=''
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --output) destination="$2"; shift 2 ;;
    *) shift ;;
  esac
done
[[ -n "$destination" ]] || exit 93
cat > "$destination" <<'INSTALLER'
#!/bin/bash
set -eu
echo 'installer:run' >> "$TEST_LOG"
case "$TEST_INSTALLER" in
  fail) echo 'installer: Could not write the installation destination.' >&2; exit 7 ;;
  missing) exit 0 ;;
esac
cp "$TEST_BREW_SOURCE" "$TEST_BIN/brew"
chmod +x "$TEST_BIN/brew"
INSTALLER
""")

    def stub(self, name, body):
        destination = self.bin / name
        destination.write_text("#!/bin/bash\nset -eu\n" + body + "\n")
        destination.chmod(0o755)

    def install_fake_brew(self):
        shutil.copyfile(self.brew_source, self.bin / "brew")
        (self.bin / "brew").chmod(0o755)

    def run_script(self, name, expected=0, terminal=False, args=()):
        command = ["/bin/bash", str(self.checkout / "scripts" / name), *args]
        if terminal:
            master, slave = pty.openpty()
            process = None
            try:
                process = subprocess.Popen(
                    command, cwd=self.directory, env=self.env,
                    stdin=subprocess.DEVNULL, stdout=slave, stderr=slave,
                )
                chunks = []
                deadline = time.monotonic() + 10
                # Drain output while the terminal is open: macOS may discard unread
                # bytes when its last slave descriptor closes.
                while True:
                    if time.monotonic() > deadline:
                        self.fail("Terminal fixture did not finish within 10 seconds")
                    readable, _, _ = select.select([master], [], [], 0.1)
                    if readable:
                        try:
                            chunk = os.read(master, 65536)
                        except OSError as error:
                            if error.errno == errno.EIO:
                                break
                            raise
                        if not chunk:
                            break
                        chunks.append(chunk)
                    elif process.poll() is not None:
                        break
                output = b"".join(chunks).decode("utf-8")
                returncode = process.wait(timeout=1)
            finally:
                if process is not None and process.poll() is None:
                    process.kill()
                    process.wait()
                os.close(slave)
                os.close(master)
            self.assertEqual(returncode, expected, output)
            return output
        result = subprocess.run(
            command,
            cwd=self.directory,
            env=self.env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=10,
        )
        self.assertEqual(result.returncode, expected, result.stdout)
        return result.stdout

    def assert_no_installer_temps(self):
        self.assertEqual(list(self.directory.glob("dotfiles-homebrew*")), [])

    def test_clt_rejects_non_macos_without_side_effects(self):
        self.env["TEST_PLATFORM"] = "Linux"
        self.run_script("00-install-command-line-tools.sh", expected=1)
        self.assertEqual(self.log.read_text(), "")

    def test_clt_already_installed_is_a_noop_and_standalone(self):
        shutil.rmtree(self.checkout / "lib")
        for _ in range(2):
            self.run_script("00-install-command-line-tools.sh")
        self.assertEqual(self.log.read_text(), "")

    def test_clt_request_requires_completion_before_success(self):
        self.env["TEST_CLT"] = "0"
        output = self.run_script("00-install-command-line-tools.sh", expected=2)
        self.assertIn("rerun", output)
        self.assertEqual(self.log.read_text(), "xcode-select:install\n")
        self.env["TEST_CLT"] = "1"
        self.run_script("00-install-command-line-tools.sh")
        self.assertEqual(self.log.read_text(), "xcode-select:install\n")

    def test_clt_request_failure_does_not_claim_completion(self):
        self.env.update(TEST_CLT="0", TEST_CLT_REQUEST="1")
        output = self.run_script("00-install-command-line-tools.sh", expected=1)
        self.assertIn("Software Update", output)

    def test_broken_selected_developer_tools_do_not_count_as_installed(self):
        self.env["TEST_BROKEN_TOOL"] = "clang"
        output = self.run_script("10-install-homebrew.sh", expected=1)
        self.assertIn("xcrun: tool clang is unavailable", output)
        self.assertIn("00-install-command-line-tools.sh", output)
        self.assertEqual(self.log.read_text(), "")

    def test_brew_requires_clt_before_downloading(self):
        self.env["TEST_CLT"] = "0"
        self.run_script("10-install-homebrew.sh", expected=1)
        self.assertEqual(self.log.read_text(), "")

    def test_brew_rejects_rosetta_before_downloading(self):
        self.env["TEST_TRANSLATED"] = "1"
        self.run_script("10-install-homebrew.sh", expected=1)
        self.assertEqual(self.log.read_text(), "")

    def test_existing_brew_is_checked_without_installing_or_upgrading(self):
        self.install_fake_brew()
        for _ in range(2):
            self.run_script("10-install-homebrew.sh")
        self.assertEqual(
            self.log.read_text(),
            "brew:--version;auto_update=;cleanup=\n" * 2,
        )

    def test_brew_failed_download_never_executes_installer(self):
        self.env["TEST_DOWNLOAD"] = "fail"
        output = self.run_script("10-install-homebrew.sh", expected=22)
        self.assertLess(
            output.index("curl: Could not reach the download server."),
            output.index("Check your connection"),
        )
        self.assertNotIn("exit code", output.lower())
        self.assertEqual(self.log.read_text(), "curl:download\n")
        self.assert_no_installer_temps()

    def test_brew_installer_failure_propagates_and_cleans_up(self):
        self.env["TEST_INSTALLER"] = "fail"
        output = self.run_script("10-install-homebrew.sh", expected=7)
        self.assertIn("installer: Could not write the installation destination.", output)
        self.assertIn("rerun this step", output)
        self.assertEqual(output.count("Oops"), 1)
        self.assertEqual(self.log.read_text(), "curl:download\ninstaller:run\n")
        self.assert_no_installer_temps()

    def test_brew_installer_must_actually_provide_brew(self):
        self.env["TEST_INSTALLER"] = "missing"
        self.run_script("10-install-homebrew.sh", expected=1)
        self.assert_no_installer_temps()

    def test_brew_installation_then_rerun_only_installs_once(self):
        self.run_script("10-install-homebrew.sh")
        self.run_script("10-install-homebrew.sh")
        self.assertEqual(self.log.read_text().count("curl:download"), 1)
        self.assertEqual(self.log.read_text().count("installer:run"), 1)
        self.assert_no_installer_temps()

    def test_package_stages_require_brew(self):
        self.run_script("11-install-applications.sh", expected=1)
        self.assertEqual(self.log.read_text(), "")

    def test_early_package_stages_use_their_separate_manifests(self):
        self.install_fake_brew()
        for script, category in (("11-install-terminals.sh", "terminals"),
                                 ("11-install-shell-tools.sh", "shell")):
            self.run_script(script)
            manifest = self.checkout / "config" / ("Brewfile." + category)
            self.assertIn("bundle install --file=" + str(manifest), self.log.read_text())

    def test_link_stage_previews_applies_and_rejects_invalid_fish_before_changes(self):
        self.install_fake_brew()
        home = Path(self.env["DOTFILES_TARGET_HOME"])
        shutil.rmtree(home)
        self.run_script("12-link-dotfiles.sh", args=("--dry-run",))
        self.assertFalse(home.exists())
        self.stub("fish", "echo 'fish: invalid syntax in fixture' >&2; exit 7")
        output = self.run_script("12-link-dotfiles.sh", expected=7)
        self.assertIn("fish: invalid syntax", output)
        self.assertFalse(home.exists())
        self.stub("fish", "exit 0")
        self.run_script("12-link-dotfiles.sh")
        self.assertTrue((home / ".config/fish").is_symlink())
        self.run_script("12-link-dotfiles.sh")
        self.assertEqual(list(self.directory.glob("dotfiles-fish-check*")), [])

    def test_account_and_terminal_stages_reject_a_staged_home(self):
        self.install_fake_brew()
        for command in ("sudo", "chsh", "open"):
            self.stub(command, 'echo "UNEXPECTED side effect" >> "$TEST_LOG"; exit 9')
        self.run_script("13-set-default-shell.sh", expected=1)
        self.run_script("14-open-terminal.sh", expected=1, args=("ghostty",))
        self.assertNotIn("UNEXPECTED", self.log.read_text())

    def test_terminal_launch_waits_for_fish_then_opens_only_the_chosen_app(self):
        self.install_fake_brew()
        # Use only a temporary config link for this launch fixture. No account
        # or real home files are changed, and app opening is always a stub.
        self.env["XDG_CONFIG_HOME"] = str(Path(self.env["DOTFILES_TARGET_HOME"]) / ".config")
        self.env["DOTFILES_TARGET_HOME"] = os.environ["HOME"]
        (self.checkout / "config/links.tsv").write_text("fish\tconfig\tfish\n")
        self.stub("open", 'printf "open:%s\\n" "$*" >> "$TEST_LOG"')
        self.stub("dscl", 'echo "UserShell: /bin/zsh"')
        self.run_script("14-open-terminal.sh", expected=1, args=("ghostty",))
        self.assertNotIn("open:", self.log.read_text())
        self.stub("dscl", 'echo "UserShell: $TEST_BIN/../bin/fish"')
        for choice, application in (("iterm2", "iTerm"), ("ghostty", "Ghostty"), ("cmux", "cmux")):
            self.run_script("14-open-terminal.sh", args=(choice,))
            self.assertIn("open:-a " + application + "\n", self.log.read_text())
        self.stub("open", "echo 'open: application not found by fixture' >&2; exit 4")
        output = self.run_script("14-open-terminal.sh", expected=4, args=("cmux",))
        self.assertIn("application not found", output)

    def test_empty_manifests_do_not_call_brew(self):
        self.install_fake_brew()
        for name in ("11-install-applications.sh", "11-install-cli-tools.sh"):
            self.assertIn("Nothing to install yet", self.run_script(name))
        self.assertEqual(self.log.read_text(), "")

    def test_independent_manifests_are_used_from_another_directory(self):
        self.install_fake_brew()
        for category in ("applications", "cli-tools"):
            manifest = self.checkout / "config" / ("Brewfile." + category)
            manifest.write_text('brew "fixture-package"\n')
        for category in ("cli-tools", "applications"):
            self.run_script("11-install-" + category + ".sh")
            manifest = self.checkout / "config" / ("Brewfile." + category)
            self.assertIn(
                "brew:bundle install --file=" + str(manifest)
                + " --no-upgrade;auto_update=1;cleanup=1\n",
                self.log.read_text(),
            )
        self.assertEqual(len(self.log.read_text().splitlines()), 2)

    def test_package_failure_propagates(self):
        self.install_fake_brew()
        (self.checkout / "config" / "Brewfile.applications").write_text('cask "fixture-app"\n')
        self.env["TEST_BUNDLE_INSTALL"] = "9"
        output = self.run_script("11-install-applications.sh", expected=9)
        self.assertIn("Homebrew: fixture-package could not be downloaded.", output)
        self.assertIn("rerun this step", output)
        self.assertNotIn("Your selected applications are ready", output)

    def test_missing_manifest_is_not_treated_as_empty(self):
        self.install_fake_brew()
        (self.checkout / "config" / "Brewfile.applications").unlink()
        output = self.run_script("11-install-applications.sh", expected=1)
        self.assertIn("package list is missing", output)
        self.assertEqual(self.log.read_text(), "")

    def test_verification_reports_empty_selections_and_its_limits(self):
        self.install_fake_brew()
        output = self.run_script("40-verify.sh")
        self.assertEqual(output.count("picked yet"), 2)
        self.assertIn("does not mark the whole laptop as finished", output)

    def test_verification_uses_check_not_install_and_reports_missing_packages(self):
        self.install_fake_brew()
        for category in ("applications", "cli-tools"):
            (self.checkout / "config" / ("Brewfile." + category)).write_text('brew "fixture-package"\n')
        self.env["TEST_BUNDLE_CHECK"] = "1"
        output = self.run_script("40-verify.sh", expected=1)
        self.assertIn("Homebrew: fixture-package needs to be installed.", output)
        self.assertIn("11-install-applications.sh", output)
        self.assertIn("11-install-cli-tools.sh", output)
        self.assertNotIn("automated checks look good", output)
        commands = self.log.read_text()
        self.assertEqual(commands.count("bundle check"), 4)
        self.assertNotIn("bundle install", commands)
        self.assertEqual(commands.count("--no-upgrade;auto_update=1"), 4)

    def test_verification_reports_all_missing_prerequisites(self):
        self.env["TEST_CLT"] = "0"
        output = self.run_script("40-verify.sh", expected=1)
        self.assertIn("developer tools are not ready", output)
        self.assertIn("Homebrew has not been installed", output)
        self.assertEqual(self.log.read_text(), "")

    def test_terminal_messages_adapt_to_capabilities_and_preferences(self):
        cases = (
            ({}, True, True),
            ({"NO_COLOR": "1"}, False, True),
            ({"DOTFILES_PLAIN": "1"}, False, False),
            ({"TERM": "dumb"}, False, False),
            ({"LC_ALL": "C"}, True, False),
        )
        baseline = dict(self.env, TERM="xterm-256color", LANG="en_US.UTF-8")
        # Exercise the shared renderer and the standalone copy independently.
        shutil.rmtree(self.checkout / "lib")
        for name in ("00-install-command-line-tools.sh", "00-configure-macos.sh"):
            if name == "00-configure-macos.sh":
                shutil.copytree(REPOSITORY / "lib", self.checkout / "lib")
            for overrides, color, emoji in cases:
                with self.subTest(script=name, overrides=overrides):
                    self.env = dict(baseline, **overrides)
                    output = self.run_script(name, terminal=True)
                    self.assertEqual("\033[" in output, color)
                    self.assertEqual("🚀" in output, emoji)
                    self.assertIn("00 /", output)

    def test_redirected_messages_are_plain_even_with_a_utf8_terminal_environment(self):
        self.env.update(TERM="xterm-256color", LANG="en_US.UTF-8")
        for name in ("00-install-command-line-tools.sh", "00-configure-macos.sh"):
            output = self.run_script(name)
            self.assertTrue(output.isascii(), output)
            self.assertNotIn("\033[", output)

    def test_unexpected_failure_keeps_the_original_error_and_explains_once(self):
        self.stub("mktemp", "echo 'mktemp: temporary directory is full' >&2; exit 8")
        output = self.run_script("10-install-homebrew.sh", expected=8)
        self.assertIn("mktemp: temporary directory is full", output)
        self.assertEqual(output.count("This step stopped before it could finish"), 1)
        self.assertIn("rerun this script", output)
        self.assertEqual(self.log.read_text(), "")

    def test_interrupt_leaves_a_resume_message(self):
        # Signal the waiting parent exactly as an interrupted tool would; no real install.
        self.stub("curl", 'kill -INT "$PPID"; exit 130')
        output = self.run_script("10-install-homebrew.sh", expected=130)
        self.assertIn("Paused", output)
        self.assertIn("rerun this step", output)
        self.assertNotIn("Homebrew is ready", output)
        self.assert_no_installer_temps()


if __name__ == "__main__":
    unittest.main()
