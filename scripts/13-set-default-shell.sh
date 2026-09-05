#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
source "$DOTFILES_ROOT/lib/dotfiles.sh"
source "$DOTFILES_ROOT/lib/fish.sh"

ui heading '13 / Make Fish feel at home'
require_macos
require_fish
if [[ "$DOTFILES_TARGET_HOME" != "$HOME" ]]; then
  ui error 'A staged home can test links, but cannot change the current account shell.' >&2
  exit 1
fi
if ! each_dotfile check_dotfile; then
  ui next 'Run ./scripts/12-link-dotfiles.sh before changing your login shell.' >&2
  exit 1
fi
set_fish_login_shell "$DOTFILES_FISH" "$(id -un)" /etc/shells
ui next 'Run ./scripts/14-open-terminal.sh iterm2, ghostty, or cmux.'
ui detail 'Existing shell sessions stay as they are. New sessions can start in Fish.'
