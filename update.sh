#!/bin/bash

set -e

# Helper functions for consistent messaging
success() {
    echo "✅ $1"
}

error() {
    echo "❌ $1" >&2
}

info() {
    echo "🚀 $1"
}

warning() {
    echo "⚠️  $1"
}

package_info() {
    echo "📦 $1"
}

not_found() {
    echo "❌ Package $1 not found. Please run the install(install.sh) script instead" >&2
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

upgrade_brew_packages(){
    # Define packages to manage
    brew_packages=(
        "git"
        "docker"
        "docker-compose"
        "dnsmasq"
        "gh"
        "awscli"
        "zoxide"
        "starship"
        "eza"
        "fnm"
        "pnpm"
        "fzf"
    )

    for package in "${brew_packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            package_info "Updating $package..."
            
            if brew upgrade "$package" 2>/dev/null; then
                success "$package updated successfully"
            else
                warning "$package is already up to date"
            fi
        else
            not_found "$package"
            exit 1
        fi
    done
}

upgrade_bun() {
    if command_exists bun; then
        package_info "Upgrading bun packages..."
        bun upgrade
        success "Bun packages upgraded successfully"
    else
        not_found "bun"
        exit 1
    fi
}

upgrade_opencode() {
    if command_exists opencode; then
        package_info "Upgrading opencode packages..."
        opencode upgrade
        success "Opencode packages upgraded successfully"
    else
        not_found "opencode"
        exit 1
    fi
}

main() {
    info "Starting brew package updates..."
    
    upgrade_brew_packages

    info "Running other upgrade..."

    upgrade_bun

    upgrade_opencode

    success "All packages updated successfully!"
}

main "$@"