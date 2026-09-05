#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"

ui heading '10 / Homebrew'
ui detail 'One home for your selected apps and tools.'
require_macos
ui info 'Checking the groundwork...'
if ! developer_tools_available; then
  ui error "Apple's developer tools need to be ready first." >&2
  ui next 'Run ./scripts/00-install-command-line-tools.sh and finish its installer, then return here.' >&2
  exit 1
fi

if [[ "$(sysctl -in sysctl.proc_translated 2>/dev/null || true)" == 1 ]]; then
  ui error 'This Terminal session is running through Rosetta.' >&2
  ui next "Open Terminal without Rosetta so Homebrew can use your Mac's native architecture." >&2
  exit 1
fi

if DOTFILES_BREW="$(find_brew)"; then
  ui info "Found Homebrew at $DOTFILES_BREW. Checking that it responds..."
else
  installer="$(mktemp -t dotfiles-homebrew)"
  trap 'rm -f -- "$installer"' EXIT
  ui info 'Fetching the official Homebrew installer...'
  run_tool 'The Homebrew installer could not be downloaded.' \
    'Check your connection and the download message above, then try this step again.' \
    curl --fail --location --show-error --output "$installer" \
    https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  ui info 'Homebrew, coming right up. Its installer will take it from here.'
  ui detail 'It may ask for your administrator password; follow the prompts below.'
  run_tool "Homebrew's installation did not finish." \
    "Follow the installer's message above, then rerun this step when you are ready." \
    /bin/bash "$installer"
  require_brew
fi

run_tool 'Homebrew is installed, but it could not start.' \
  "Check Homebrew's message above and repair that installation before continuing." \
  "$DOTFILES_BREW" --version
ui success 'Homebrew is ready. Cheers!'
ui next 'Start with 11-install-terminals.sh and 11-install-shell-tools.sh, then link your dotfiles at step 12.'
ui detail 'The scripts can find Homebrew already. Your linked Fish configuration will set up its PATH.'
