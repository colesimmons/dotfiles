#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
ui heading '30 / Give your apps the finishing touches'
require_macos

# TODO: Restore selected app settings, keybindings, fonts, and extension lists.
# TODO: Decide whether each setting is managed here or by the app's own sync.
# Keep sign-ins, licenses, and interactive permission grants in the manual checklist.
ui pending 'Your app settings are waiting for your personal touches.'
ui detail 'Choose the shortcuts, fonts, extensions, and settings you want to bring along.'
ui next 'Add the selected setup here. No application settings have been changed.'
