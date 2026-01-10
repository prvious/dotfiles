#!/bin/bash

# Dotfiles Update Script
# Updates brew packages, bun, and opencode
# Also pulls latest dotfiles if running from the repo

set -e

# Logging
info()    { echo "=> $1"; }
success() { echo "✓ $1"; }
error()   { echo "✗ $1" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Detect dotfiles directory
detect_dotfiles_dir() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ -f "$script_dir/.zshrc" ]]; then
        DOTFILES_DIR="$script_dir"
    elif [[ -d "$HOME/.dotfiles" ]]; then
        DOTFILES_DIR="$HOME/.dotfiles"
    else
        DOTFILES_DIR=""
    fi
}

brew_packages=(
    git docker docker-compose dnsmasq gh awscli
    zoxide starship eza fnm pnpm fzf bat
)

main() {
    echo "Updating..."
    echo ""

    detect_dotfiles_dir

    # Update dotfiles repo if found
    if [[ -n "$DOTFILES_DIR" && -d "$DOTFILES_DIR/.git" ]]; then
        info "Updating dotfiles..."
        git -C "$DOTFILES_DIR" pull --ff-only 2>/dev/null && success "dotfiles" || success "dotfiles (already up to date)"
    fi

    # Homebrew packages
    info "Updating brew packages..."
    brew update

    for pkg in "${brew_packages[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            brew upgrade "$pkg" 2>/dev/null && success "$pkg" || success "$pkg (up to date)"
        fi
    done

    # Bun
    if command_exists bun; then
        info "Updating bun..."
        bun upgrade && success "bun"
    fi

    # OpenCode
    if command_exists opencode; then
        info "Updating opencode..."
        opencode upgrade && success "opencode"
    fi

    echo ""
    success "All updated!"
}

main "$@"
