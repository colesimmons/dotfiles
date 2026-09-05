# Agent guidance

## Purpose and scope

This public repository defines a deliberate macOS laptop setup. Optimize for getting
from a fresh laptop to a working project with understandable, repeatable steps.
The machine used to develop this repository is evidence of past choices, not the
desired state. Do not export its installed packages or copy its dotfiles wholesale.

The public remote is `https://github.com/colesimmons/dotfiles.git`. The README's
standalone download uses the `master` branch; keep that URL aligned with any branch
change. Public HTTPS cloning must work before GitHub authentication or SSH setup.

## Established decisions

- Use small, focused Bash scripts, not a master installer or implicit run-all loop.
- Prefix script filenames with two-digit numbers. Scripts with the same number share
  prerequisites and must work in either order. This does not authorize concurrent
  package-manager operations. Renumber a script when it gains a new dependency.
- Separate Command Line Tools, Homebrew, package installation, configuration, and
  verification. Keep `00-install-command-line-tools.sh` standalone: no repository
  helper, Git, Homebrew, Python, or custom shell may be needed to run it.
- Use Homebrew and curated Brewfiles for selected applications and CLI tools.
- Keep routine setup distinct from upgrading or removing existing software.
- Scaffold undecided choices instead of silently choosing applications or preferences.

Application selections, shell choice, Git identity and signing, runtime ownership,
settings restoration, and macOS preferences remain undecided until explicitly chosen.
Mise and uv are candidates, not approved package selections. Prefer project-owned
runtime versions over a large set of global installations.

## Repository map

- `scripts/00-*`: independent operations requiring only basic macOS setup. The tools
  installer can run before cloning; the preferences placeholder runs from a checkout.
- `scripts/10-*`: Homebrew installation after usable Apple developer tools exist.
- `scripts/20-*`: independent package manifests requiring Homebrew.
- `scripts/30-*`: configuration after selected stage `20` apps and tools are installed.
  These scripts must not assume another `30-*` script has initialized the shell.
- `scripts/40-verify.sh`: checks implemented prerequisites and populated manifests.
- `config/Brewfile.*`: deliberate package selections. Comments and blank lines mean
  no selection. Keep these declarative; avoid hooks and automatic service startup.
- `lib/common.sh`: shared prerequisite checks, Homebrew discovery, and Bundle behavior.
- `lib/ui.sh`: shared terminal styling, friendly error handling, and tool-output passthrough.
- `tests/`: isolated behavior checks using temporary fixtures and fake commands.
- `README.md`: public description, fresh-Mac instructions, script order, and manual
  finish checklist.

## Implementation conventions

- Target macOS's built-in `/bin/bash` 3.2 and standard macOS utilities. Do not require
  a Homebrew Bash, GNU utilities, Python, Node, or a selected interactive shell.
- Use `#!/bin/bash`, `set -Eeuo pipefail`, quoted expansions, and script-relative paths.
  Check behavior from a different working directory and a checkout path with spaces.
- Keep shared code small. Do not build a configuration framework or introduce a
  dotfile manager before a concrete requirement warrants one.
- Check prerequisites and print an actionable next step. Do not hide failures.
- Installers must tolerate reruns. Opening an asynchronous installer is not completion;
  the standalone CLT script uses exit code `2` to request completion and a rerun.
- Keep Homebrew's installer interactive. Do not run the whole setup as root, suppress
  required prompts, or store administrator credentials. Delegate elevation to the
  official installer when necessary.
- Preserve user files. Detect conflicts before writing configuration and avoid duplicate
  startup entries. Do not overwrite existing files or remove unlisted software by default.
- Keep package setup on `bundle install --no-upgrade`, disable automatic metadata updates
  and installation cleanup there, and keep verification on `bundle check --no-upgrade`.
  Do not add cleanup, uninstallation, service startup, or broad upgrades as side effects.
- An empty manifest must explain that no packages were selected. A placeholder must
  identify itself and do no work. Verification must distinguish limited checks from a
  completely configured laptop.
- Never commit credentials, tokens, private keys, recovery codes, machine dumps, or
  private app exports. Keep machine-specific values outside tracked files; `.local/`
  is ignored but is not automatically read by the scripts.

## Design the terminal experience

- Keep messages friendly, lively, and readable. Give each stage a heading, say what
  is happening, and end with a useful result or next action. Small touches of fun are
  welcome; avoid fake progress, distracting animation, and jokes in serious errors.
- Use `ui` from `lib/ui.sh` through the shared helpers for repository messages. The
  standalone CLT script intentionally includes a small copy of the renderer and traps;
  keep its behavior consistent without adding a dependency on a checkout or download.
- Color terminal output only when its destination supports it. Use emoji only with a
  UTF-8 locale and terminal output. Honor `NO_COLOR` for colors and `DOTFILES_PLAIN=1`
  for colors and emoji; redirected output and `TERM=dumb` must remain plain.
- Never rely on color or icons alone to communicate status. Unselected packages and
  unimplemented configuration are pending choices, not completed work or failures.
- Keep original tool diagnostics and interactive prompts visible. Use `run_tool` to
  add context and a concrete recovery step without piping, swallowing, or reformatting
  the tool's output. Routine failed prerequisite checks should preserve useful stderr.
- Preserve exit statuses for automation, including the CLT pending status. Explain the
  outcome in words rather than displaying numeric statuses to users. Unexpected errors
  and Control-C should leave understandable guidance without duplicate summaries.

## Use current documentation

Use Context7 when working with library, framework, SDK, API, CLI-tool, or cloud-service
syntax, configuration, installation, migration, or tool-specific debugging—even for
familiar tools. Prefer it over web search for those docs. General shell logic,
refactoring, and code review do not require a documentation lookup by themselves.

1. Start with `resolve-library-id`, using the library/tool name and the actual question,
   unless the user supplied an exact `/org/project` library ID.
2. Select the best match by exact name, relevance, source reputation, snippet coverage,
   and benchmark score. Use a version-specific ID when the requested version exists.
   Retry with a better name or query if the results do not match.
3. Call `query-docs` with the selected ID and a specific, complete question.
4. If the answer is insufficient, use the tool's research retry when available
   (`researchMode: true` if supported by its exposed schema). If unavailable, verify
   against official documentation or source; do not invent unsupported tool arguments.
5. Base the implementation on the retrieved documentation and record useful primary
   links in the relevant public documentation. Do not send secrets or private data in
   documentation queries.

## Validate changes

When developing installers, test with mocked commands instead of running live installs
or changing host settings. A request to edit these scripts does not by itself request
applying the laptop setup. Follow any existing session authorization for actual setup
work; do not add approval gates to routine repository edits.

Run `python3 -m unittest discover -s tests -v` on macOS. The suite uses `/bin/bash` for
syntax checks and temporary command stubs for behavior checks. Extend it for meaningful
failure paths and side-effect risks, especially prerequisite detection, reruns, failed
downloads, package selection, and read-only verification. Do not test every placeholder
line or add tests that simply duplicate implementation.

Do not claim a real installation, account recovery, application integration, or clean-Mac
validation passed based only on mocked tests. Report the actual validation and its limits.

## Keep documentation aligned

Review both `README.md` and `AGENTS.md` with every change. Update them in the same change
when script names, numbering, prerequisites, behavior, chosen tools, manual actions,
verification, or development conventions change. Keep the script-order table accurate.
Replace resolved decisions and implemented-placeholder descriptions rather than
appending contradictory notes. Avoid documenting transient inventories or test counts.

Write public-facing documentation for someone who has not read the conversation.
Explain what the repository does, how to run it, what is selected, and what still needs
manual attention. Keep agent-specific context and implementation rules in this file.
