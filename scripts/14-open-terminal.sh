#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
source "$DOTFILES_ROOT/lib/dotfiles.sh"
source "$DOTFILES_ROOT/lib/fish.sh"

ui heading '14 / Choose your cockpit'
require_macos
case "${1:-}" in
  iterm2) application=iTerm ;;
  ghostty) application=Ghostty ;;
  cmux) application=cmux ;;
  *) ui next 'Choose one: ./scripts/14-open-terminal.sh iterm2 | ghostty | cmux'; exit 2 ;;
esac
[[ "$#" -eq 1 ]] || { ui error 'Choose one terminal at a time.' >&2; exit 1; }
require_fish
if [[ "$DOTFILES_TARGET_HOME" != "$HOME" ]] || ! each_dotfile check_dotfile; then
  ui next 'Link your real configuration with step 12 before opening a terminal.' >&2
  exit 1
fi
if [[ "$(read_login_shell "$(id -un)")" != "$DOTFILES_FISH" ]]; then
  ui next 'Finish ./scripts/13-set-default-shell.sh first so new sessions use Fish.' >&2
  exit 1
fi
run_tool "Could not open $application." \
  'Run 11-install-terminals.sh and check the macOS message above.' open -a "$application"
ui success "$application is open. Continue in a new Fish session."
if [[ "$application" == iTerm ]]; then
  ui detail 'For your checked-in fonts and colors, choose Profiles > Dotfiles - Fish and make it the default.'
fi
ui detail 'If the app was already running, start a new session or relaunch it to load the new configuration.'
ui next 'In the new terminal, return to this checkout and choose any remaining apps or tools:'
printf '     cd -- %q\n' "$DOTFILES_ROOT"
ui detail './scripts/11-install-applications.sh and ./scripts/11-install-cli-tools.sh can run directly in Fish.'
