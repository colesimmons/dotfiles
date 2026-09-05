status is-interactive; or return

alias skim 'open -a Skim'
alias gs 'git status'
alias ga 'git add'
alias gaa 'git add -A'
alias gp 'git push'
alias gd 'git diff'
alias gco 'git checkout'
alias gb 'git branch'

# Keep macOS vim usable before an optional Neovim installation exists.
if type -q nvim
    alias vim nvim
    alias v nvim
end
