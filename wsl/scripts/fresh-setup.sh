#!/bin/bash

# Personal WSL setup script - Run once to set up a complete WSL development environment
# Usage: ./wsl-setup.sh
# For non-interactive mode: echo 'password' | ./wsl-setup.sh

set -euo pipefail  # Improved error handling: exit on error, undefined vars, pipe failures

# =============================================================================
# USER INPUT
# =============================================================================

get_user_email() {
    while [[ -z "$EMAIL_FOR_GIT" ]]; do
        echo
        log_info "Git configuration required"
        read -p "Enter your email address for Git/GitHub: " EMAIL_FOR_GIT
        
        # Basic email validation
        if [[ "$EMAIL_FOR_GIT" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            log_success "Email set to: $EMAIL_FOR_GIT"
        else
            log_warning "Invalid email format. Please enter a valid email address."
            EMAIL_FOR_GIT=""
        fi
    done
}

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly SCRIPT_NAME="AH134 WSL Setup"
readonly PREFIX="[🗿 ${SCRIPT_NAME}]"
readonly SETUP_MARKER="$HOME/.wsl_setup_complete"

# Global variable for email (set by user input)
EMAIL_FOR_GIT=""

# Package arrays
readonly APT_PACKAGES=(
    "zsh"
    "build-essential" 
    "curl"
    "git"
    "unzip"
)

readonly HOMEBREW_PACKAGES=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "nvm"
    "eza"
    "gcc"
    "nvim"
)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log() {
    echo "$PREFIX $*" >&2
}

log_info() {
    log "ℹ️  $*"
}

log_success() {
    log "✅ $*"
}

log_warning() {
    log "⚠️  $*"
}

log_error() {
    log "❌ $*"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if package is installed (apt)
package_installed() {
    dpkg -l "$1" >/dev/null 2>&1
}

# Verify installation was successful
verify_installation() {
    local item="$1"
    local check_command="$2"
    
    if eval "$check_command" >/dev/null 2>&1; then
        log_success "$item installed successfully"
        return 0
    else
        log_error "$item installation failed"
        return 1
    fi
}

# =============================================================================
# SETUP COMPLETION MANAGEMENT
# =============================================================================

check_setup_complete() {
    if [[ -f "$SETUP_MARKER" ]]; then
        log_warning "WSL setup already completed (marker found: $SETUP_MARKER)"
        log_info "To re-run setup, delete: rm $SETUP_MARKER"
        exit 0
    fi
}

create_setup_marker() {
    log_info "Creating setup completion marker..."
    {
        echo "# WSL Setup completed on $(date)"
        echo "# Script: $0"
        echo "# User: $(whoami)"
        echo "# Hostname: $(hostname)"
    } > "$SETUP_MARKER"
    log_success "Setup marker created: $SETUP_MARKER"
}

# =============================================================================
# SYSTEM UPDATE AND PACKAGE INSTALLATION
# =============================================================================

update_system() {
    log_info "Updating package lists and upgrading system..."
    
    sudo apt-get update -y
    sudo apt-get upgrade -y
    
    log_success "System update completed"
}

install_apt_packages() {
    log_info "Installing APT packages: ${APT_PACKAGES[*]}"
    
    local packages_to_install=()
    
    # Check which packages need installation
    for package in "${APT_PACKAGES[@]}"; do
        if ! package_installed "$package"; then
            packages_to_install+=("$package")
        else
            log_info "$package already installed, skipping"
        fi
    done
    
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        sudo apt-get install -y "${packages_to_install[@]}"
        log_success "APT packages installed: ${packages_to_install[*]}"
    else
        log_info "All APT packages already installed"
    fi
}

# =============================================================================
# ZSH SETUP
# =============================================================================

setup_zsh() {
    log_info "Setting up Zsh..."
    
    # Verify zsh is installed
    if ! command_exists zsh; then
        log_error "Zsh not found. Please install it first."
        return 1
    fi
    
    # Create basic .zshrc
    log_info "Creating basic .zshrc configuration..."
    {
        echo "# Basic Zsh configuration"
        echo "HISTFILE=~/.histfile"
        echo "HISTSIZE=10000"
        echo "SAVEHIST=10000"
        echo "setopt HIST_IGNORE_DUPS"
        echo "setopt HIST_IGNORE_SPACE"
        echo "setopt SHARE_HISTORY"
        echo ""
        echo "# Use vi key bindings"
        echo "bindkey -v"
        echo ""
    } > "$HOME/.zshrc"
    
    # Set zsh as default shell
    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    local zsh_path
    zsh_path=$(which zsh)
    
    if [[ "$current_shell" != "$zsh_path" ]]; then
        log_info "Setting Zsh as default shell..."
        chsh -s "$zsh_path"
        log_success "Default shell changed to Zsh"
    else
        log_info "Zsh already set as default shell"
    fi
}

# =============================================================================
# RUST INSTALLATION
# =============================================================================

install_rust() {
    log_info "Installing Rust and Cargo..."
    
    if command_exists cargo; then
        log_info "Rust already installed, skipping"
        return 0
    fi
    
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # Source cargo environment
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    
    # Add to .zshrc
    log_info "Adding Rust/Cargo to .zshrc..."
    {
        echo "# Rust/Cargo"
        echo "if [[ -f \"\$HOME/.cargo/env\" ]]; then"
        echo "    source \"\$HOME/.cargo/env\""
        echo "fi"
        echo ""
    } >> "$HOME/.zshrc"
    
    verify_installation "Rust" "command_exists cargo"
}

# =============================================================================
# HOMEBREW INSTALLATION
# =============================================================================

install_homebrew() {
    log_info "Installing Homebrew..."
    
    if command_exists brew; then
        log_info "Homebrew already installed, skipping"
        return 0
    fi
    
    # Install Homebrew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to PATH
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # Add to .zshrc
    log_info "Adding Homebrew to .zshrc..."
    {
        echo "# Homebrew"
        echo "if [[ -x \"/home/linuxbrew/.linuxbrew/bin/brew\" ]]; then"
        echo "    eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
        echo "fi"
        echo ""
    } >> "$HOME/.zshrc"
    
    verify_installation "Homebrew" "command_exists brew"
}

install_homebrew_packages() {
    log_info "Installing Homebrew packages: ${HOMEBREW_PACKAGES[*]}"
    
    if ! command_exists brew; then
        log_error "Homebrew not found. Cannot install packages."
        return 1
    fi
    
    for package in "${HOMEBREW_PACKAGES[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed via Homebrew"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done
    
    log_success "Homebrew packages installation completed"
}

# =============================================================================
# STARSHIP PROMPT
# =============================================================================

install_starship() {
    log_info "Installing Starship prompt..."
    
    if command_exists starship; then
        log_info "Starship already installed, skipping"
        return 0
    fi
    
    # Install via cargo
    cargo install starship
    
    # Add to .zshrc
    log_info "Adding Starship to .zshrc..."
    {
        echo "# Starship prompt"
        echo "if command -v starship >/dev/null 2>&1; then"
        echo "    eval \"\$(starship init zsh)\""
        echo "fi"
        echo ""
    } >> "$HOME/.zshrc"
    
    # Create config directory and file
    log_info "Creating Starship configuration..."
    mkdir -p "$HOME/.config"
    starship preset nerd-font-symbols -o "$HOME/.config/starship.toml"
    
    verify_installation "Starship" "command_exists starship"
}

# =============================================================================
# GIT AND SSH SETUP
# =============================================================================

setup_git_ssh() {
    log_info "Setting up Git and SSH..."
    
    # Create .ssh directory with proper permissions
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate SSH key if it doesn't exist
    local ssh_key_path="$HOME/.ssh/github"
    if [[ ! -f "$ssh_key_path" ]]; then
        log_info "Generating SSH key for GitHub..."
        ssh-keygen -t ed25519 -C "$EMAIL_FOR_GIT" -f "$ssh_key_path" -N ""
        chmod 600 "$ssh_key_path"
        chmod 644 "${ssh_key_path}.pub"
        log_success "SSH key generated: $ssh_key_path"
    else
        log_info "SSH key already exists: $ssh_key_path"
    fi
    
    # Add SSH agent setup to .zshrc
    log_info "Adding SSH agent setup to .zshrc..."
    {
        echo "# SSH Agent"
        echo "if ! pgrep -u \"\$USER\" ssh-agent > /dev/null; then"
        echo "    ssh-agent -s > \"\$HOME/.ssh/ssh-agent-env\""
        echo "fi"
        echo "if [[ -f \"\$HOME/.ssh/ssh-agent-env\" ]]; then"
        echo "    source \"\$HOME/.ssh/ssh-agent-env\" > /dev/null"
        echo "fi"
        echo "if [[ -f \"\$HOME/.ssh/github\" ]]; then"
        echo "    ssh-add \"\$HOME/.ssh/github\" 2>/dev/null"
        echo "fi"
        echo ""
    } >> "$HOME/.zshrc"
    
    log_success "Git and SSH setup completed"
}

# =============================================================================
# ZSH PLUGINS AND TOOLS
# =============================================================================

configure_zsh_plugins() {
    log_info "Configuring Zsh plugins and tools..."
    
    # Add plugin configurations
    {
        echo "# Zsh plugins"
        echo "if [[ -f \"\$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh\" ]]; then"
        echo "    source \"\$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh\""
        echo "fi"
        echo ""
        echo "if [[ -f \"\$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\" ]]; then"
        echo "    source \"\$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\""
        echo "fi"
        echo ""
        echo "# NVM setup"
        echo "export NVM_DIR=\"\$HOME/.nvm\""
        echo "if [[ -s \"/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh\" ]]; then"
        echo "    source \"/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh\""
        echo "fi"
        echo "if [[ -s \"/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm\" ]]; then"
        echo "    source \"/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm\""
        echo "fi"
        echo ""
        echo "# Eza (modern ls replacement)"
        echo "if command -v eza >/dev/null 2>&1; then"
        echo "    alias ls='eza --icons --group-directories-first'"
        echo "    alias lsa='eza -a --icons --group-directories-first'"
        echo "    alias ll='eza -l --icons --group-directories-first'"
        echo "    alias lla='eza -la --icons --group-directories-first'"
        echo "    alias tree='eza --tree'"
        echo "fi"
        echo ""
    } >> "$HOME/.zshrc"
    
    log_success "Zsh plugins and tools configured"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

print_completion_message() {
    echo
    log_success "=== WSL Setup Complete! ==="
    echo
    log_info "Next steps:"
    log_info "1. Add your SSH key to GitHub:"
    log_info "   cat ~/.ssh/github.pub"
    log_info "   Then add this key to https://github.com/settings/keys"
    echo
    log_info "2. Restart your terminal or run: exec zsh"
    echo
    log_info "3. Optionally install Node.js LTS:"
    log_info "   nvm install --lts"
    log_info "   nvm use --lts"
    echo
    log_info "Setup marker created at: $SETUP_MARKER"
    echo
}

main() {
    log_info "Starting $SCRIPT_NAME..."
    echo
    
    # Get user input
    get_user_email
    
    # System setup
    update_system
    install_apt_packages
    
    # Shell setup
    setup_zsh
    
    # Development tools
    install_rust
    install_homebrew
    install_homebrew_packages
    install_starship
    
    # Git and SSH
    setup_git_ssh
    
    # Zsh configuration
    configure_zsh_plugins
    
    # Completion
    create_setup_marker
    print_completion_message
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================

# Check if setup already completed
check_setup_complete

# Run main setup
main "$@"
