# Terminal messages only: no dependencies beyond Bash, no captured tool output.
# The standalone Command Line Tools script carries its own copy of this renderer.
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

run_tool() {
  local failure="$1" next_step="$2" result
  shift 2
  # Leave stdin, stdout, and stderr attached: prompts and diagnostics stay visible.
  if "$@"; then
    return 0
  else
    result=$?
    ui error "$failure" >&2
    ui next "$next_step" >&2
    return "$result"
  fi
}
