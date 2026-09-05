#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"

ui heading '11 / Fish, with a little Starship'
install_bundle "$DOTFILES_ROOT/config/Brewfile.shell" 'shell tools'
ui next 'Run ./scripts/12-link-dotfiles.sh to put your checked-in configuration to work.'
