# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.dotfiles/oh-my-zsh

export ZSH_THEME="powerlevel9k/powerlevel9k"
# if you want to use this, change your non-ascii font to Droid Sans Mono for Awesome
POWERLEVEL9K_MODE='awesome-patched'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
# https://github.com/bhilburn/powerlevel9k#customizing-prompt-segments
# https://github.com/bhilburn/powerlevel9k/wiki/Stylizing-Your-Prompt
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_VCS_GIT_HOOKS=(git-remotebranch vcs-detect-changes)
POWERLEVEL9K_HIDE_BRANCH_ICON=true
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# disable colors in ls
# export DISABLE_LS_COLORS="true"

# disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

plugins=(
    colorize
    compleat    # tab autocompletion
    dirpersist  # persist dir in new tab
    autojump    # autojump -s, then j <dirspec>
    git         # git aliases
    history     # aliases for history (type "h")
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

source /usr/local/opt/nvm/nvm.sh

autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use &> /dev/null
  elif [[ $(nvm version) != $(nvm version default)  ]]; then
    nvm use default &> /dev/null
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Customize to your needs...
unsetopt correct
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
export MAGICK_HOME=/usr/local/opt/imagemagick@6

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/cs/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/cs/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/cs/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/cs/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
