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

link_info() {
    echo "🔗 $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

info "Setting up symlinks..."

# Create symlink for .zshrc to home directory
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    warning "Backing up existing .zshrc to .zshrc.backup"
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

if [ -L "$HOME/.zshrc" ]; then
    warning ".zshrc symlink already exists, removing old symlink"
    rm "$HOME/.zshrc"
fi

link_info "Creating symlink: $HOME/.zshrc -> $SCRIPT_DIR/.zshrc"
ln -s "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
success ".zshrc symlinked to home directory"

# Create symlinks for all scripts in ./scripts to ~/.local/bin
if [ -d "$SCRIPT_DIR/scripts" ]; then
    info "Symlinking scripts to ~/.local/bin..."
    
    # Ensure ~/.local/bin exists
    if [ ! -d "$HOME/.local/bin" ]; then
        info "Creating ~/.local/bin directory..."
        mkdir -p "$HOME/.local/bin"
    fi
    
    for script in "$SCRIPT_DIR/scripts"/*; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            target="$HOME/.local/bin/$script_name"
            
            # Remove existing symlink if it exists
            if [ -L "$target" ]; then
                warning "Removing old symlink: $target"
                rm "$target"
            elif [ -f "$target" ]; then
                warning "File exists at $target, backing it up"
                mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            
            link_info "Creating symlink: $target -> $script"
            ln -s "$script" "$target"
            
            # Make sure the script is executable
            chmod +x "$script"
            success "$script_name symlinked to ~/.local/bin"
        fi
    done
else
    error "scripts directory not found at $SCRIPT_DIR/scripts"
    exit 1
fi

echo ""
success "All symlinks created successfully!"
echo ""
info "Symlinked files:"
echo "  • ~/.zshrc -> $SCRIPT_DIR/.zshrc"
for script in "$SCRIPT_DIR/scripts"/*; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        echo "  • ~/.local/bin/$script_name -> $script"
    fi
done
