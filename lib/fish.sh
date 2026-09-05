require_fish() {
  local prefix
  require_brew
  prefix="$(run_tool 'Homebrew could not locate its installation.' \
    'Follow its message above, then rerun this step.' "$DOTFILES_BREW" --prefix)" || return
  DOTFILES_FISH="$prefix/bin/fish"
  if [[ ! -x "$DOTFILES_FISH" ]]; then
    ui error 'Fish is not installed yet.' >&2
    ui next 'Run ./scripts/11-install-shell-tools.sh, then return here.' >&2
    return 1
  fi
}

read_login_shell() {
  dscl . -read "/Users/$1" UserShell | awk '/^UserShell: / {print $2}'
}

set_fish_login_shell() {
  local fish_binary="$1" account="$2" shells_file="$3" current
  current="$(read_login_shell "$account")" || return
  if ! grep -Fxq "$fish_binary" "$shells_file"; then
    ui info 'Registering Fish as an allowed shell. macOS may ask for your administrator password.'
    printf '\n%s\n' "$fish_binary" | run_tool 'Fish could not be registered as a login shell.' \
      'Check the permission message above and rerun this step.' sudo tee -a "$shells_file" >/dev/null || return
  fi
  if [[ "$current" == "$fish_binary" ]]; then
    ui success 'Fish is already your login shell.'
    return 0
  fi
  ui info 'Making Fish your login shell. Follow the macOS password prompt if it appears.'
  run_tool 'macOS could not change your login shell.' \
    'Follow the message above, then rerun this step.' chsh -s "$fish_binary" || return
  current="$(read_login_shell "$account")" || return
  if [[ "$current" != "$fish_binary" ]]; then
    ui error 'macOS has not saved Fish as your login shell yet.' >&2
    ui next 'Finish the account prompts and rerun this step before opening a new terminal.' >&2
    return 1
  fi
  ui success 'Fish is your login shell. Welcome aboard!'
}
