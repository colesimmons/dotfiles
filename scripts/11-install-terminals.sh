#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"

ui heading '11 / Pick your cockpit'
ui detail 'iTerm2, Ghostty, and cmux, with your terminal fonts.'
install_bundle "$DOTFILES_ROOT/config/Brewfile.terminals" terminals
ui next 'Install the shell tools with 11-install-shell-tools.sh, then link your dotfiles at step 12.'
