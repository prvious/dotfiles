#!/bin/bash

set -e

# Logging
info()    { echo "=> $1"; }
success() { echo "✓ $1"; }
warn()    { echo "! $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Symlink helper - backs up existing files
symlink() {
    local src="$1"
    local dest="$2"

    [[ ! -f "$src" ]] && return

    # Backup if regular file exists
    [[ -f "$dest" && ! -L "$dest" ]] && mv "$dest" "$dest.backup.$(date +%Y%m%d_%H%M%S)"

    # Remove existing symlink
    [[ -L "$dest" ]] && rm "$dest"

    ln -s "$src" "$dest"
    success "$(basename "$dest")"
}

main() {
    info "Creating symlinks..."

    # Config files
    symlink "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
    symlink "$SCRIPT_DIR/.env.sh" "$HOME/.env.sh"
    symlink "$SCRIPT_DIR/.bash_aliases" "$HOME/.bash_aliases"

    # Scripts to ~/.local/bin
    if [[ -d "$SCRIPT_DIR/scripts" ]]; then
        mkdir -p "$HOME/.local/bin"

        for script in "$SCRIPT_DIR/scripts"/*; do
            [[ -f "$script" ]] || continue
            chmod +x "$script"
            symlink "$script" "$HOME/.local/bin/$(basename "$script")"
        done
    fi

    # Claude skills
    if [[ -d "$SCRIPT_DIR/claude/skills" ]]; then
        mkdir -p "$HOME/.claude"
        if [[ -L "$HOME/.claude/skills" ]]; then
            rm "$HOME/.claude/skills"
        elif [[ -d "$HOME/.claude/skills" ]]; then
            mv "$HOME/.claude/skills" "$HOME/.claude/skills.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -s "$SCRIPT_DIR/claude/skills" "$HOME/.claude/skills"
        success "claude/skills"
    fi

    echo ""
    success "Symlinks created"
}

main "$@"
