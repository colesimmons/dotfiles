#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
ui heading '00 / Make this Mac yours'
require_macos

# TODO: Implement only selected, documented macOS preferences.
# TODO: Decide keyboard, Finder, Dock, screenshots, notifications, and workspaces.
# Keep account sign-ins, FileVault recovery, and permissions in the manual checklist.
ui pending 'Your macOS preferences are still yours to choose.'
ui detail 'Keyboard, Finder, Dock, screenshots, and notifications can all live here.'
ui next 'Choose your preferences, then fill in this script. Your settings are untouched.'
