# cole's dotfiles

A deliberate macOS setup, from a fresh laptop to a useful working environment.
Small, numbered scripts install prerequisites, selected software, and personal
configuration. Each script runs independently; there is no master installer.

## Status

- The prerequisite installers and Brewfile installers are implemented.
- Application lists are empty
- Preference and configuration scripts are explicit placeholders.

## Set up a fresh Mac

- Complete macOS Setup Assistant, connect to the internet, install system
updates, restart.
- Shouldn't need to run the numbered scripts with `sudo`; Apple's and Homebrew's
installers handle elevation when needed. Full Xcode is not required for this setup.

### Step 01: Install Command Line Tools

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

Choose a permanent checkout location. This public HTTPS clone needs no GitHub login,
SSH key, or password manager:

```sh
mkdir -p "$HOME/dev"
git clone https://github.com/colesimmons/dotfiles.git "$HOME/dev/dotfiles"
cd "$HOME/dev/dotfiles"
```

Commands in the rest of this guide assume the repository is your working directory.

### Step 03: Install Homebrew

```sh
/bin/bash scripts/10-install-homebrew.sh
```

This downloads and runs the official Homebrew installer only if Homebrew is missing.
An existing installation is checked without being upgraded. Although Homebrew's
installer can also install Command Line Tools, this repository makes that prerequisite
a separate step so Git is available for cloning first.

Follow Homebrew's printed `shellenv` instructions if you want to use `brew`
interactively. The numbered scripts can find Homebrew at its standard native prefix
without a shell-profile change. Persistent shell configuration is a separate choice.
On Apple Silicon, use a native Terminal session rather than Rosetta.

## Choose and install software

Edit the two manifests before installing software:

- [config/Brewfile.applications](config/Brewfile.applications): password manager,
  browser, terminal, editor, and other selected GUI applications.
- [config/Brewfile.cli-tools](config/Brewfile.cli-tools): selected command-line
  utilities, shells, and runtime managers.

Each file contains inactive examples and prompts for undecided categories. A file
containing only comments or blank lines installs nothing and reports that no packages
have been selected. Keep entries declarative: package selections, without shell hooks
or automatic service startup.

Run these scripts in either order, one at a time:

```sh
/bin/bash scripts/20-install-applications.sh
/bin/bash scripts/20-install-cli-tools.sh
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
be postponed. Run scripts with `/bin/bash`, including if your interactive shell is Fish.

| Script | Prerequisites | Behavior |
| --- | --- | --- |
| `00-install-command-line-tools.sh` | Basic macOS setup | Requests Apple's installer or verifies existing tools; works before cloning. |
| `00-configure-macos.sh` | Basic macOS setup | Placeholder for selected system preferences; independent of developer tools. |
| `10-install-homebrew.sh` | Usable Command Line Tools or Xcode developer tools | Installs Homebrew if missing. Does not require the other `00` script. |
| `20-install-applications.sh` | Homebrew | Installs the applications manifest. |
| `20-install-cli-tools.sh` | Homebrew | Installs the CLI-tools manifest. |
| `30-configure-applications.sh` | Selected applications and tools from stage `20` | Placeholder for settings, keybindings, fonts, and extensions. |
| `30-configure-git.sh` | Selected applications and tools from stage `20` | Placeholder for Git preferences, identity, authentication, and signing. |
| `30-configure-runtimes.sh` | Selected applications and tools from stage `20` | Placeholder for runtime-manager configuration. |
| `30-configure-shell.sh` | Selected applications and tools from stage `20` | Placeholder for shell selection, Homebrew integration, and shell settings. |
| `40-verify.sh` | Run after the selected setup stages | Checks developer tools, Homebrew, and populated manifests without installing packages. |

All scripts are in [scripts/](scripts/). Unfinished configuration stages explain which
choices are waiting for you and leave your settings untouched. They reserve a place
for future implementation; running them does not complete that configuration. Runtime
versions and project dependencies belong in the relevant project repositories.

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

```sh
/bin/bash scripts/40-verify.sh
```

It explains which prerequisites or selected packages need attention and reports a
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
They do not install software or change host preferences. Python is a development-test
dependency, not a prerequisite for the numbered scripts. A clean-Mac installation
still needs to be verified separately.

References: [Homebrew installation](https://docs.brew.sh/Installation),
[Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile), and
[Apple Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/).
