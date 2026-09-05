#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
ui heading '30 / A shell that feels like home'
require_macos

# TODO: Choose Fish or Zsh and implement its Homebrew shellenv integration.
# TODO: Add selected completions, history settings, aliases, prompt, and navigation.
# Preserve existing files and report conflicts; do not append duplicate startup lines.
ui pending 'Your shell setup is waiting for your picks.'
ui detail 'Choose your shell, prompt, shortcuts, and history preferences.'
ui next 'Add those choices to this script. No startup files have been changed.'
