#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
source "$DOTFILES_ROOT/lib/dotfiles.sh"
source "$DOTFILES_ROOT/lib/fish.sh"

ui heading '12 / One home for your dotfiles'
require_macos
case "${1:-}" in
  '') mode=apply ;;
  --dry-run) mode=preview ;;
  --backup-existing) mode=backup ;;
  *) ui next 'Use ./scripts/12-link-dotfiles.sh [--dry-run | --backup-existing]'; exit 1 ;;
esac
[[ "$#" -le 1 ]] || { ui error 'Choose one mode at a time.' >&2; exit 1; }

require_fish
# Syntax checking must not initialize Fish state in the user's home or repository.
scratch="$(mktemp -d -t dotfiles-fish-check)"
trap 'rm -rf -- "$scratch"' EXIT
ui info 'Checking your Fish configuration before linking anything...'
for file in "$DOTFILES_ROOT/dotfiles/fish/config.fish" "$DOTFILES_ROOT"/dotfiles/fish/{conf.d,functions}/*.fish; do
  run_tool 'A Fish configuration file needs a fix.' 'Fix the syntax message above, then retry this step.' \
    env XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" XDG_CACHE_HOME="$scratch/cache" \
    "$DOTFILES_FISH" --no-config --no-execute "$file"
done
link_dotfiles "$mode"
if [[ "$mode" != preview ]]; then
  ui success 'Your configuration now lives in this repository.'
  ui next 'Run ./scripts/13-set-default-shell.sh, then open your preferred terminal.'
fi
