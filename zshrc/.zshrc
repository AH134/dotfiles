# Note: bob is the name I use for my PC
# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/bob/.zsh/completions:"* ]]; then export FPATH="/home/bob/.zsh/completions:$FPATH"; fi
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/bob/.zshrc'

autoload -Uz compinit
compinit

# Source
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Path
path+=('/snap/bin:/usr/local/go/bin')
export PATH

# Alias
alias ls="eza --icons"
alias lsa="eza -a --icons"
alias hw="cd"

# Starship
eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "/home/bob/.deno/env"
# Created by `pipx` on 2025-01-18 19:05:34
export PATH="$PATH:/home/bob/.local/bin"
