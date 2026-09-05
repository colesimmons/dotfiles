# cole's dotfiles

A deliberate macOS setup, from a fresh laptop to a useful working environment.
Small, numbered scripts install prerequisites, selected software, and personal
configuration. Each script runs independently; there is no master installer.

## Status

- The prerequisite installers and Brewfile installers are implemented.
- Fish, Starship, iTerm2, Ghostty, cmux, and the selected terminal fonts are included.
- Fish, Starship, and terminal configuration are managed through symlinks.
- General application and CLI-tool lists are empty; remaining preferences are placeholders.

## Set up a fresh Mac

The rerun labels describe installed software and managed configuration. **Idempotent**
means repeating a completed step with unchanged inputs leaves that setup in the same
state. Output, downloads, prompts, and app opening can still repeat. Wait for any
running installer to finish before rerunning its step. **Do not re-run** means skip
that step once it is complete; it does not necessarily mean repeating it is destructive.

- Complete macOS Setup Assistant, connect to the internet, install system
updates, restart.
- Shouldn't need to run the numbered scripts with `sudo`; Apple's and Homebrew's
installers handle elevation when needed. Full Xcode is not required for this setup.

### Step 01: Install Command Line Tools

✅ **Idempotent – safe to re-run**

This script is standalone so you can download it before Git or Homebrew is available:

```sh
clt_script="$(mktemp -t dotfiles-clt)"
curl --fail --location --show-error --output "$clt_script" \
  https://raw.githubusercontent.com/colesimmons/dotfiles/master/scripts/00-install-command-line-tools.sh \
  && /bin/bash "$clt_script"
```

If the script opens Apple's installer, finish the installation, then verify it:

```sh
/bin/bash "$clt_script"
```

The script tells you when to finish Apple's installer and when the tools are ready.
If something goes wrong, it keeps Apple's message visible and suggests what to do next.
If you close Terminal, repeat the command to check again. An existing, usable
installation is recognized without reinstalling it.

### Step 02: Clone the repository

❌ **Do not re-run**

Once cloned, reuse the existing checkout. Cloning again into the same nonempty
directory fails; do not delete the checkout to repeat this step. To resume setup,
change into the existing directory with `cd "$HOME/dev/dotfiles"`.

Choose a permanent checkout location. This public HTTPS clone needs no GitHub login,
SSH key, or password manager:

```sh
mkdir -p "$HOME/dev"
git clone https://github.com/colesimmons/dotfiles.git "$HOME/dev/dotfiles"
cd "$HOME/dev/dotfiles"
```

Commands in the rest of this guide assume the repository is your working directory.

### Step 03: Install Homebrew

✅ **Idempotent – safe to re-run**

```sh
/bin/bash scripts/10-install-homebrew.sh
```

This downloads and runs the official Homebrew installer only if Homebrew is missing.
An existing installation is checked without being upgraded. Although Homebrew's
installer can also install Command Line Tools, this repository makes that prerequisite
a separate step so Git is available for cloning first.

The numbered scripts can find Homebrew at its standard native prefix without a
shell-profile change. The Fish configuration installed next sets up Homebrew's PATH.
On Apple Silicon, use a native Terminal session rather than Rosetta.

### Step 04: Install your terminals and Fish

✅ **Idempotent – safe to re-run**

These two steps require only Homebrew and can run in either order, one at a time:

```sh
./scripts/11-install-terminals.sh
./scripts/11-install-shell-tools.sh
```

The terminal manifest installs iTerm2, Ghostty, cmux, Monaspace, and Meslo for
Powerlevel10k. The shell manifest installs Fish and Starship. The other `11` scripts
share the Homebrew prerequisite but can wait until you are working in your chosen
terminal; no need to pick every application first.

### Step 05: Link your configuration

✅ **Idempotent – safe to re-run**

Keep this checkout in its permanent location. Preview the links, then apply them:

```sh
./scripts/12-link-dotfiles.sh --dry-run
./scripts/12-link-dotfiles.sh
```

The script checks Fish syntax and all link entries before changing files. Existing
links to this checkout are left alone. If a destination already contains something
else, it stops without replacing it. After reviewing that configuration, you can
explicitly save the existing files and create the links:

```sh
./scripts/12-link-dotfiles.sh --backup-existing
```

Backups go under `~/.local/state/dotfiles/backups/` (or `$XDG_STATE_HOME`) with a unique
directory for each run that needs one. The script prints each saved location. It
does not merge old configuration into the repository or delete the backups.
Rerunning with correct links creates no additional backups, including when you use
`--backup-existing` again.

### Step 06: Make Fish your login shell

✅ **Idempotent – safe to re-run**

```sh
./scripts/13-set-default-shell.sh
```

This registers the Homebrew Fish executable in `/etc/shells` if needed and uses
`chsh` to select it for your account. macOS may request your administrator or account
password. The script verifies the saved shell and does nothing if Fish is already
selected. Existing shell sessions keep running as they are.

### Step 07: Continue in your preferred terminal

✅ **Idempotent – safe to re-run**

This leaves your setup configuration unchanged. Repeating the launcher can open or
focus the app again; its window and session behavior is controlled by the terminal.

Choose one of these commands:

```sh
./scripts/14-open-terminal.sh iterm2
./scripts/14-open-terminal.sh ghostty
./scripts/14-open-terminal.sh cmux
```

The script opens the chosen app and prints how to return to this checkout. If the app
was already running, start a new session or relaunch it to load the configuration.
In iTerm2, choose **Profiles > Dotfiles - Fish** for the checked-in fonts and colors;
you can make that profile the default in iTerm2's settings. Its ordinary login-shell
profile also uses Fish after the shell change.

Run the remaining scripts directly from Fish, such as
`./scripts/11-install-applications.sh`. Their shebangs choose Bash for the installer
code while your interactive shell remains Fish. Do not `source` Bash scripts in Fish.

## Choose and install software

✅ **Idempotent – safe to re-run**

The early selections live in [config/Brewfile.terminals](config/Brewfile.terminals)
and [config/Brewfile.shell](config/Brewfile.shell). Edit the two optional manifests
when you are ready to install more software:

- [config/Brewfile.applications](config/Brewfile.applications): password manager,
  browser, editor, and other selected GUI applications.
- [config/Brewfile.cli-tools](config/Brewfile.cli-tools): selected command-line
  utilities and runtime managers.

Each file contains inactive examples and prompts for undecided categories. A file
containing only comments or blank lines installs nothing and reports that no packages
have been selected. Keep entries declarative: package selections, without shell hooks
or automatic service startup.

Run these scripts in either order, one at a time:

```sh
./scripts/11-install-applications.sh
./scripts/11-install-cli-tools.sh
```

Both require Homebrew. Their numbering expresses prerequisites, not concurrent
execution: package-manager operations should run sequentially.

Installation uses `brew bundle install --no-upgrade` with automatic metadata updates
and installation cleanup disabled. It installs missing selections without requesting
upgrades of already-installed selections or removing unlisted packages. Homebrew may
still make dependency changes required by a new installation. Software updates are a
separate maintenance action; applications may also have their own update mechanisms.
If Homebrew metadata needs refreshing, update it deliberately and rerun the stage.

After installing the password manager and browser, sign in and configure their
integration. Installing applications does not restore accounts, licenses, data, or
permissions. Add App Store applications as a separate stage once the choices and
the required `mas` installation and App Store sign-in are defined.

## Follow the script order

Scripts with the same number share a prerequisite stage and do not depend on one
another. A higher number waits for its stated prerequisites; optional stages can
be postponed. Run the executable scripts directly from Fish or another shell.

| Script | Prerequisites | Behavior | Rerun safety |
| --- | --- | --- | --- |
| `00-install-command-line-tools.sh` | Basic macOS setup | Requests Apple's installer or verifies existing tools; works before cloning. | ✅ Idempotent – safe to re-run |
| `00-configure-macos.sh` | Basic macOS setup | Placeholder for selected system preferences; independent of developer tools. | ✅ Idempotent – safe to re-run |
| `10-install-homebrew.sh` | Usable Command Line Tools or Xcode developer tools | Installs Homebrew if missing. Does not require the other `00` script. | ✅ Idempotent – safe to re-run |
| `11-install-terminals.sh` | Homebrew | Installs iTerm2, Ghostty, cmux, and selected fonts. | ✅ Idempotent – safe to re-run |
| `11-install-shell-tools.sh` | Homebrew | Installs Fish and Starship. | ✅ Idempotent – safe to re-run |
| `11-install-applications.sh` | Homebrew | Installs the optional applications manifest. | ✅ Idempotent – safe to re-run |
| `11-install-cli-tools.sh` | Homebrew | Installs the optional CLI-tools manifest. | ✅ Idempotent – safe to re-run |
| `12-link-dotfiles.sh` | Fish from stage `11` | Checks Fish syntax and links the reviewed configuration. | ✅ Idempotent – safe to re-run |
| `13-set-default-shell.sh` | Fish and the stage `12` links | Registers Fish and selects it as the account's login shell. | ✅ Idempotent – safe to re-run |
| `14-open-terminal.sh` | Terminals, links, and the Fish login shell | Opens or focuses one chosen terminal; setup configuration stays unchanged. | ✅ Idempotent – safe to re-run |
| `30-configure-applications.sh` | Selected optional applications and tools from stage `11` | Placeholder for additional application settings and extensions. | ✅ Idempotent – safe to re-run |
| `30-configure-git.sh` | Selected optional applications and tools from stage `11` | Placeholder for Git preferences, identity, authentication, and signing. | ✅ Idempotent – safe to re-run |
| `30-configure-runtimes.sh` | Selected optional applications and tools from stage `11` | Placeholder for runtime-manager configuration. | ✅ Idempotent – safe to re-run |
| `40-verify.sh` | Run after the selected setup stages | Checks tools, packages, links, and the login shell without installing anything. | ✅ Idempotent – safe to re-run |

All scripts are in [scripts/](scripts/). Unfinished configuration stages explain which
choices are waiting for you and leave your settings untouched. They reserve a place
for future implementation; running them does not complete that configuration. Runtime
versions and project dependencies belong in the relevant project repositories.
The placeholder scripts are safe to repeat because they do not change settings;
their green labels do not indicate that the configuration is implemented.

## Keep one source of truth

[config/links.tsv](config/links.tsv) maps files under [dotfiles/](dotfiles/) to their
normal locations. Paths are tab-separated, with no shell expansion or executable
hooks in the manifest. Add future reviewed dotfiles there and rerun stage `12`.

| Repository source | Linked destination |
| --- | --- |
| `dotfiles/fish/` | `~/.config/fish/` |
| `dotfiles/starship.toml` | `~/.config/starship.toml` |
| `dotfiles/starship/` | `~/.config/starship/` |
| `dotfiles/ghostty/` | `~/.config/ghostty/` and `~/Library/Application Support/com.mitchellh.ghostty/` |
| `dotfiles/cmux/` | `~/.config/cmux/` |
| `dotfiles/iterm2/profiles/` | `~/Library/Application Support/iTerm2/DynamicProfiles/` |
| `dotfiles/bin/dotfiles-fish` | `~/.local/bin/dotfiles-fish` |

The `config` destinations honor `XDG_CONFIG_HOME` when set. Both Ghostty config
locations share the same source, so a macOS-specific copy cannot silently override
another one. cmux reads the Ghostty settings, with its app-specific choices in
`cmux.json`. The terminal launcher finds Homebrew Fish on Apple Silicon or Intel
without depending on a GUI app's inherited PATH or shell environment.

Editing files through linked directories changes this checkout immediately, including
when an editor saves files by replacement. For single-file links, use an editor that
preserves symlinks or edit the repository file directly. The verification step detects
links that have been replaced. Review `git diff`, then commit and push the changes you
want to keep; there is no automatic commit or upload.

The iTerm2 profile is marked `Rewritable`, so supported iTerm2 profile edits can write
back into the linked profile directory. Global iTerm2 preferences and session state
stay in macOS's settings database. Review profile diffs before publishing them.

The Fish configuration retains the Git aliases, conditional Neovim shortcuts, colors,
Starship prompt, and optional fnm/rustup integration. `gc` takes a commit message;
`gwt name` creates a dated branch and worktree under the repository's `.worktrees/`;
`gwtr path` removes the worktree while keeping its branch. Git still refuses to remove
a dirty worktree. Add `.worktrees/` to a project's ignore rules if needed.

Private SSH/rsync shortcuts belong in the ignored `~/.config/fish/local.fish` file.
Fish's generated universal-variable files, history, migration snapshots, and unused
Fisher manager are not copied into version control. Keep durable aliases, abbreviations,
and settings in `.fish` files; interactive universal-variable changes are machine state.
History and caches normally remain under Fish's XDG data/cache locations.

## Read the terminal messages

Each stage has a heading, progress messages, and a next step. Green success messages
say what is ready; amber messages mark choices or actions still waiting for you.
Failures include guidance alongside the original tool's output. Apple and Homebrew
keep control of their own prompts and progress while they run.

Colors appear in supported terminals, and emoji appear when the terminal uses a UTF-8
locale. Redirected output and `TERM=dumb` use plain text. Set `NO_COLOR=1` to disable
our colors, or use `DOTFILES_PLAIN=1` to disable both colors and emoji:

```sh
DOTFILES_PLAIN=1 ./scripts/40-verify.sh
```

These preferences control this repository's messages; other tools format their own
output. Pressing Control-C leaves a reminder that you can rerun the step. Scripts
still report success or failure to the shell, so other programs can detect unfinished
work without anyone needing to interpret numbers on screen.

## Finish the interactive steps

Use this checklist alongside the scripts. These actions are not automated:

- [ ] Sign into the password manager and verify account recovery without the old laptop.
- [ ] Configure browser integration and required application accounts.
- [ ] Configure Touch ID, automatic locking, FileVault recovery, and Find My.
- [ ] Set up backups and confirm that a sample file can be restored.
- [ ] Restore active documents, notes, reference libraries, and local-only project files.
- [ ] Authenticate to GitHub for private repositories or pushing changes.
- [ ] Complete licenses and required macOS permission prompts.
- [ ] Clone and run a representative project with its dependencies and credentials.
- [ ] Add optional research, publishing, design, hardware, and personal tools as needed.
- [ ] Restart and confirm the chosen working environment still behaves as expected.

Check the automated portion with:

✅ **Idempotent – safe to re-run**

```sh
/bin/bash scripts/40-verify.sh
```

It explains which prerequisites, packages, links, or login-shell settings need attention and reports a
failure to the shell when a check fails. Empty manifests get a reminder to choose
packages. It does not validate unfinished configuration, accounts, backups, or a
working project; passing it is not full setup completion.

## Maintain the setup

Keep selected packages in manifests and focused behavior in scripts. Add optional
bundles only when their contents are chosen. Reuse a number for scripts with the same
prerequisites; give a dependent operation a later number. Do not add a master runner.

Keep secrets, session tokens, recovery codes, private keys, and private application
exports outside the repository. `.local/` is ignored for machine-only overrides;
scripts do not load it automatically. An ignore rule does not protect secrets already
tracked by Git.

Keep this README and [AGENTS.md](AGENTS.md) aligned with changes to behavior,
prerequisites, package choices, and verification. Agent-specific development guidance
belongs in `AGENTS.md`.

Run the isolated development checks on macOS with Python 3 available:

```sh
python3 -m unittest discover -s tests -v
```

These tests check Bash syntax and use fake system commands in temporary directories.
Fish configuration and worktree tests also run when Fish is available. A
`DOTFILES_TARGET_HOME` override stages link tests in a temporary home without changing
`HOME`; account-shell changes and terminal launches reject a staged home.
They do not install software or change host preferences. Python is a development-test
dependency, not a prerequisite for the numbered scripts. A clean-Mac installation
still needs to be verified separately.

References: [Homebrew installation](https://docs.brew.sh/Installation),
[Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile), and
[Apple Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/).
Configuration references: [Fish](https://fishshell.com/docs/current/),
[Starship](https://starship.rs/config/), [Ghostty](https://ghostty.org/docs/config),
[cmux](https://cmux.com/docs/configuration), and
[iTerm2 dynamic profiles](https://iterm2.com/documentation-dynamic-profiles.html).
