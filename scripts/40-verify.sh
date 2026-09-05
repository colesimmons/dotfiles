#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
ui heading '40 / Time for a check-in'
ui detail "Let's see what is ready and what still needs a little attention."
require_macos

failed=0
if developer_tools_available; then
  ui success "Apple's developer tools are ready."
else
  ui error "Apple's developer tools are not ready yet." >&2
  ui next 'Run ./scripts/00-install-command-line-tools.sh and finish its installer.' >&2
  failed=1
fi

if DOTFILES_BREW="$(find_brew)"; then
  ui info 'Checking that Homebrew responds...'
  if run_tool 'Homebrew could not start.' \
    'Use its message above to repair the installation, then rerun this check.' \
    "$DOTFILES_BREW" --version; then
    ui success 'Homebrew is ready.'
  else
    failed=1
  fi
  for manifest in "$DOTFILES_ROOT/config/Brewfile.applications" "$DOTFILES_ROOT/config/Brewfile.cli-tools"; do
    case "$manifest" in
      *.applications) selection='applications'; install_script='20-install-applications.sh' ;;
      *) selection='command-line tools'; install_script='20-install-cli-tools.sh' ;;
    esac
    if [[ ! -f "$manifest" ]]; then
      ui error "Your $selection list is missing: $manifest" >&2
      ui next 'Restore that file from the repository, then rerun this check.' >&2
      failed=1
    elif manifest_has_entries "$manifest"; then
      ui info "Checking your selected $selection..."
      if run_tool "The check for your $selection did not pass." \
        "Follow Homebrew's message above. For missing packages, run ./scripts/$install_script." \
        env HOMEBREW_NO_AUTO_UPDATE=1 "$DOTFILES_BREW" bundle check --file="$manifest" --no-upgrade; then
        ui success "Your selected $selection are in place."
      else
        failed=1
      fi
    else
      ui pending "No $selection picked yet. Add your choices to $manifest."
    fi
  done
else
  ui error 'Homebrew has not been installed yet.' >&2
  ui next 'Run ./scripts/10-install-homebrew.sh, then rerun this check.' >&2
  failed=1
fi

printf '\n'
if [[ "$failed" == 0 ]]; then
  ui success 'The automated checks look good.'
else
  ui pending 'A few things need attention. Work through the messages above, then check again.' >&2
fi
ui detail 'This checks tools and selected packages; it does not mark the whole laptop as finished.'
ui next 'Use the README checklist for remaining choices, sign-ins, backups, and a working project.'
exit "$failed"
