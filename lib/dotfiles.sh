# Map reviewed configuration to its normal locations. HOME itself is never changed.
DOTFILES_TARGET_HOME="${DOTFILES_TARGET_HOME:-$HOME}"
DOTFILES_CONFIG_HOME="${XDG_CONFIG_HOME:-$DOTFILES_TARGET_HOME/.config}"
DOTFILES_STATE_HOME="${XDG_STATE_HOME:-$DOTFILES_TARGET_HOME/.local/state}"

each_dotfile() {
  local callback="$1" relative base destination extra target
  while IFS=$'\t' read -r relative base destination extra || [[ -n "$relative" ]]; do
    [[ -n "$relative" && "$relative" != \#* ]] || continue
    if [[ -z "$base" || -z "$destination" || -n "$extra" || "$relative" == /* || "$destination" == /* ]]; then
      ui error 'A link entry is incomplete. Use source, destination base, and relative path separated by tabs.' >&2
      return 1
    fi
    case "/$relative/$destination/" in
      */../*|*/./*) ui error 'Link entries must stay inside their declared directories.' >&2; return 1 ;;
    esac
    case "$base" in
      home) target="$DOTFILES_TARGET_HOME/$destination" ;;
      config) target="$DOTFILES_CONFIG_HOME/$destination" ;;
      *) ui error "Unknown link destination base: $base" >&2; return 1 ;;
    esac
    "$callback" "$DOTFILES_ROOT/dotfiles/$relative" "$target" "$base/$destination" || return
  done < "$DOTFILES_ROOT/config/links.tsv"
}

link_is_current() {
  [[ -L "$2" && "$1" -ef "$2" ]]
}

preflight_link() {
  local source="$1" destination="$2"
  if [[ ! -e "$source" ]]; then
    ui error "The repository is missing a link source: $source" >&2
    return 1
  fi
  if link_is_current "$source" "$destination"; then
    return 0
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ "$DOTFILES_LINK_MODE" != backup ]]; then
      ui pending "Existing configuration needs your attention: $destination"
      ui next 'Review it, then use 12-link-dotfiles.sh --backup-existing to save it before linking.'
      return 1
    fi
  fi
  ui info "Link $destination -> $source"
}

apply_link() {
  local source="$1" destination="$2" backup_relative="$3" saved='' link_status
  if link_is_current "$source" "$destination"; then
    ui success "Already linked: $destination"
    return 0
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ -z "$DOTFILES_BACKUP_ROOT" ]]; then
      run_tool 'Could not prepare a backup directory.' 'Check its permissions, then retry.' \
        mkdir -p "$DOTFILES_STATE_HOME/dotfiles/backups" || return
      DOTFILES_BACKUP_ROOT="$(run_tool 'Could not create a backup directory.' 'Check its permissions, then retry.' \
        mktemp -d "$DOTFILES_STATE_HOME/dotfiles/backups/backup.XXXXXX")" || return
    fi
    saved="$DOTFILES_BACKUP_ROOT/$backup_relative"
    run_tool 'Could not prepare the backup location.' 'Check its permissions, then retry.' \
      mkdir -p "$(dirname -- "$saved")" || return
    run_tool 'Could not save the previous configuration.' 'Check the filesystem error before retrying.' \
      mv -- "$destination" "$saved" || return
    ui info "Saved the previous configuration to $saved"
  fi
  run_tool 'Could not prepare a configuration directory.' 'Check its permissions, then retry.' \
    mkdir -p "$(dirname -- "$destination")" || return
  if ln -s -- "$source" "$destination"; then
    ui success "Linked: $destination"
  else
    link_status=$?
    if [[ -n "$saved" && ! -e "$destination" && ! -L "$destination" ]]; then
      run_tool 'Could not restore the previous configuration.' \
        "Your saved copy is at $saved. Restore it before retrying." \
        mv -- "$saved" "$destination" || return
      ui info "Restored your previous configuration at $destination."
    fi
    ui error "Could not create the link at $destination." >&2
    ui next 'Check the filesystem error above before retrying this step.' >&2
    return "$link_status"
  fi
}

link_dotfiles() {
  DOTFILES_LINK_MODE="$1"
  DOTFILES_BACKUP_ROOT=''
  # Check every entry before making any changes, including missing source files.
  each_dotfile preflight_link || return
  if [[ "$DOTFILES_LINK_MODE" == preview ]]; then
    ui success 'Preview complete. No files changed.'
    return 0
  fi
  (umask 077; each_dotfile apply_link)
}

check_dotfile() {
  if ! link_is_current "$1" "$2"; then
    ui pending "This configuration is not linked to the repository: $2"
    return 1
  fi
}
