#!/bin/bash

# Dotfiles Setup Script
# Usage:
#   curl install:  curl -fsSL https://raw.githubusercontent.com/prvious/dotfiles/refs/heads/main/install.sh | bash
#   custom dir:    DOTFILES_DIR=~/my-dotfiles curl -fsSL ... | bash
#   local install: ./install.sh

set -e

REPO_URL="https://github.com/prvious/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Logging
info()    { echo "=> $1"; }
success() { echo "✓ $1"; }
error()   { echo "✗ $1" >&2; exit 1; }
warn()    { echo "! $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Detect if running from existing repo or via curl
detect_source() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check if we're in a repo with .zshrc (local install)
    if [[ -f "$script_dir/.zshrc" && -f "$script_dir/.env.sh" ]]; then
        DOTFILES_DIR="$script_dir"
        FROM_REPO=true
    else
        FROM_REPO=false
    fi
}

# Clone repo if running via curl
setup_dotfiles_dir() {
    if [[ "$FROM_REPO" == true ]]; then
        success "Running from existing repo: $DOTFILES_DIR"
        return
    fi

    # Running via curl - need to clone
    if [[ -d "$DOTFILES_DIR" ]]; then
        error "Directory $DOTFILES_DIR already exists. Remove it first or set DOTFILES_DIR to a different path."
    fi

    info "Cloning dotfiles to $DOTFILES_DIR..."
    git clone --depth 1 "$REPO_URL" "$DOTFILES_DIR"
    success "Dotfiles cloned to $DOTFILES_DIR"
}

# Validate environment
validate_env() {
    [[ "$OSTYPE" != "darwin"* ]] && error "This script is for macOS only"
    [[ "$EUID" -eq 0 ]] && error "Don't run as root. Script will prompt for sudo when needed."
}

# Xcode CLI tools
ensure_xcode() {
    if ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install 2>/dev/null || true
        warn "Please complete the Xcode installation dialog, then re-run this script"
        exit 1
    fi
    success "Xcode CLI tools"
}

# Homebrew
install_homebrew() {
    if ! command_exists brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew"
}

# Zinit
install_zinit() {
    local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
    if [[ ! -d "$zinit_home" ]]; then
        info "Installing Zinit..."
        mkdir -p "$(dirname "$zinit_home")"
        git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$zinit_home"
    fi
    success "Zinit"
}

# Brew package installer
brew_install() {
    local name=$1
    local cmd=${2:-$1}
    if command_exists "$cmd" || brew list "$name" &>/dev/null; then
        success "$name"
    else
        info "Installing $name..."
        brew install "$name"
    fi
}

brew_install_cask() {
    local name=$1
    if brew list --cask "$name" &>/dev/null; then
        success "$name (cask)"
    else
        info "Installing $name..."
        brew install --cask "$name"
    fi
}

# dnsmasq for .test domains
setup_dnsmasq() {
    info "Configuring dnsmasq..."
    local conf="$(brew --prefix)/etc/dnsmasq.conf"
    mkdir -p "$(brew --prefix)/etc/"

    if ! grep -q "address=/.test/127.0.0.1" "$conf" 2>/dev/null; then
        echo -e "address=/.test/127.0.0.1\nport=53" >> "$conf"
    fi

    sudo mkdir -p /etc/resolver
    [[ ! -f /etc/resolver/test ]] && echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/test > /dev/null

    brew services list | grep -q "dnsmasq.*started" || sudo brew services start dnsmasq
    success "dnsmasq (.test domains)"
}

main() {
    echo "Setting up development environment..."
    echo ""

    validate_env
    detect_source
    ensure_xcode
    install_homebrew

    # Ensure git is available before cloning
    command_exists git || brew install git

    setup_dotfiles_dir
    cd "$DOTFILES_DIR"

    # Update brew (skip in CI)
    [[ -z "${GITHUB_ACTIONS}" ]] && brew update

    # Install packages
    echo ""
    info "Installing packages..."

    brew_install git
    brew_install jq
    brew_install json5
    brew_install dnsmasq
    brew_install gh
    brew_install awscli aws
    brew_install zoxide
    brew_install starship
    brew_install eza
    brew_install fnm
    brew_install pnpm
    brew_install fzf
    brew_install bat

    # Docker Desktop (cask)
    command_exists docker || brew_install_cask docker
    success "Docker"

    # Bun
    if ! command_exists bun; then
        info "Installing Bun..."
        BUN_INSTALL="$HOME/.bun" curl -fsSL https://bun.sh/install | bash
    fi
    success "Bun"

    # OpenCode
    if ! command_exists opencode; then
        info "Installing OpenCode..."
        INSTALL_DIR="$HOME/.opencode" curl -fsSL https://opencode.ai/install | bash
    fi
    success "OpenCode"

    echo ""
    install_zinit
    setup_dnsmasq

    # Docker networks
    docker network create traefik 2>/dev/null || true
    docker network create haproxy 2>/dev/null || true
    success "Docker networks"

    # Directories
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.eza/completions/zsh" "$HOME/.docker/completions"
    docker completion zsh > "$HOME/.docker/completions/_docker" 2>/dev/null || true

    # Symlink config files and scripts
    bash "$DOTFILES_DIR/symlink.sh"

    echo ""
    echo "========================================"
    success "Setup complete!"
    echo "========================================"
    echo ""
    echo "Dotfiles installed to: $DOTFILES_DIR"
    echo ""
    echo "Next steps:"
    echo "  1. Restart terminal or: source ~/.zshrc"
    echo "  2. Test .test domains: ping test.test"
    echo ""
}

main "$@"
