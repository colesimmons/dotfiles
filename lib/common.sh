# Shared checks for scripts that run from a repository checkout. Bash 3.2 compatible.
DOTFILES_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_ROOT/lib/ui.sh"

require_macos() {
  if [[ "$(uname -s)" != Darwin ]]; then
    ui error 'This setup is made for macOS.' >&2
    ui next 'Run this step from Terminal on your Mac.' >&2
    exit 1
  fi
  if [[ "$EUID" -eq 0 ]]; then
    ui error "Let's keep this in your own account." >&2
    ui next 'Run the script without sudo. The installers will ask if they need permission.' >&2
    exit 1
  fi
}

developer_tools_available() {
  xcode-select -p >/dev/null &&
    xcrun --find clang >/dev/null &&
    xcrun --find git >/dev/null
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi

  # Later scripts work even before a shell profile adds Homebrew to PATH.
  case "$(uname -m)" in
    arm64) [[ -x /opt/homebrew/bin/brew ]] && printf '/opt/homebrew/bin/brew\n' ;;
    x86_64) [[ -x /usr/local/bin/brew ]] && printf '/usr/local/bin/brew\n' ;;
    *) return 1 ;;
  esac
}

require_brew() {
  if ! DOTFILES_BREW="$(find_brew)"; then
    ui error 'Homebrew has not arrived yet.' >&2
    ui next 'Run ./scripts/10-install-homebrew.sh, then come back to this step.' >&2
    exit 1
  fi
}

manifest_has_entries() {
  LC_ALL=C grep -Eq '^[[:space:]]*[^#[:space:]]' "$1"
}

install_bundle() {
  local manifest="$1"
  local selection="$2"
  require_macos
  require_brew
  if [[ ! -f "$manifest" ]]; then
    ui error "The package list is missing: $manifest" >&2
    ui next 'Restore that file from the repository, then try again.' >&2
    exit 1
  fi
  if ! manifest_has_entries "$manifest"; then
    ui pending "Your $selection list is a blank canvas. Nothing to install yet."
    ui next "Add your picks to $manifest, then rerun this step."
    return
  fi
  ui info "Getting your selected $selection ready. Homebrew will show its progress below."
  run_tool "Homebrew could not finish setting up your $selection." \
    "Check Homebrew's message above, resolve the issue, and rerun this step." \
    env HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 \
    "$DOTFILES_BREW" bundle install --file="$manifest" --no-upgrade
  ui success "Your selected $selection are ready."
}
