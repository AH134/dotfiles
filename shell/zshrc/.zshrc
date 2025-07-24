HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v

# Rust/Cargo
source $HOME/.cargo/env

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# zsh plugins
source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# NVM setup
export NVM_DIR="/home/andy/.nvm"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"

# eza setup
alias ls='eza --icons --group-directories-first'
alias lsa='eza -a --icons --group-directories-first'
alias lt='eza --tree --icons'
alias lta='eza --tree -a --icons --git-ignore'
alias tree='eza --tree -a --icons'

# nvim into .zshrc
alias zh="vim ~/.zshrc"

# ssh agent
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add ~/.ssh/github > /dev/null 2>&1

# Starship prompt
eval "$(starship init zsh)"

