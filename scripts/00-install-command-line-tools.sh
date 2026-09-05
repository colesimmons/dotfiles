#!/bin/bash
# Standalone: this file can be downloaded before Git or the repository exists.
set -Eeuo pipefail

# Intentionally inline: keep this renderer aligned with lib/ui.sh so downloading
# this single file still works before Git and the repository are available.
ui() {
  local kind="$1" message="$2" icon label shade color='' reset=''
  local charset="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
  case "$kind" in
    heading) icon='🚀'; label='==>'; shade='1;36' ;;
    info) icon='🔎'; label='...'; shade='36' ;;
    success) icon='✅'; label='OK'; shade='32' ;;
    pending) icon='🌱'; label='To do'; shade='33' ;;
    error) icon='🛑'; label='Oops'; shade='31' ;;
    next) icon='👉'; label='Next'; shade='1;36' ;;
    *) icon=' '; label=' '; shade='0' ;;
  esac
  if [[ -t 1 && "${TERM:-dumb}" != dumb && "${DOTFILES_PLAIN:-0}" != 1 ]]; then
    case "$charset" in
      *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) label="$icon" ;;
    esac
    if [[ -z "${NO_COLOR:-}" ]]; then
      color="$(printf '\033[%sm' "$shade")"
      reset=$'\033[0m'
    fi
  fi
  [[ "$kind" != heading ]] || printf '\n'
  printf '  %s%s  %s%s\n' "$color" "$label" "$message" "$reset"
  if [[ "$kind" == error ]]; then
    DOTFILES_ERROR_REPORTED=1
  fi
}

ui_unexpected_error() {
  local result="$1"
  if [[ "$BASH_SUBSHELL" -eq 0 && "${DOTFILES_ERROR_REPORTED:-0}" != 1 ]]; then
    ui error 'This step stopped before it could finish.' >&2
    ui next 'Check the message above, then rerun this script when you are ready.' >&2
  fi
  return "$result"
}

trap 'ui_unexpected_error "$?"' ERR
trap 'ui pending "Paused. You can rerun this step whenever you are ready." >&2; exit 130' INT

ui heading '00 / Developer tools'
ui detail 'A little groundwork for your new Mac.'

if [[ "$(uname -s)" != Darwin ]]; then
  ui error 'This setup is made for macOS.' >&2
  ui next 'Run this step from Terminal on your Mac.' >&2
  exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
  ui error "Let's keep this in your own account." >&2
  ui next 'Run the script without sudo. Apple will ask if it needs permission.' >&2
  exit 1
fi

ui info "Checking for Apple's developer tools..."
if xcode-select -p >/dev/null &&
  xcrun --find clang >/dev/null &&
  xcrun --find git >/dev/null; then
  ui success "Already good to go! Apple's developer tools are ready."
  ui next 'Clone the repository, then run ./scripts/10-install-homebrew.sh.'
  exit 0
fi

ui info "Let's get those tools installed. Apple may open an installation window."
if ! xcode-select --install; then
  ui error 'Apple could not start the installation.' >&2
  ui next 'Check System Settings > General > Software Update, or finish any installer already open.' >&2
  ui detail "Then rerun this script. Apple's original message is shown above." >&2
  exit 1
fi

ui pending 'Over to you: finish the Apple installer.'
ui next "When it finishes, rerun this script. We'll check that everything is ready."
# Opening the installer does not mean its asynchronous installation has finished.
exit 2
