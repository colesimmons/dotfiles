#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"

ui heading '11 / Your command-line toolkit'
ui detail 'A few good tools go a long way.'
install_bundle "$DOTFILES_ROOT/config/Brewfile.cli-tools" 'command-line tools'
