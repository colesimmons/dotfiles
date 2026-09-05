#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"

ui heading '11 / Your applications'
ui detail 'Make room for the apps you actually want.'
install_bundle "$DOTFILES_ROOT/config/Brewfile.applications" applications
