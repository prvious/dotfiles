#!/bin/bash

# Laptop Setup Script
# This script sets up a development environment based on the configurations in this repo
# Usage: curl https://raw.githubusercontent.com/munezaclovis/setup/refs/heads/main/install.sh | bash

set -e  # Exit on any error

REPO_URL="https://github.com/munezaclovis/setup.git"
TEMP_DIR="/tmp/setup-$$"

echo "🚀 Starting laptop setup..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to cleanup temporary directory
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        echo "🧹 Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Function to clone setup repository
clone_setup_repo() {
    echo "📥 Downloading setup files..."
    
    # Install git first if not present
    if ! command_exists git; then
        echo "📦 Installing git..."
        if command_exists brew; then
            brew install git
        else
            # If Homebrew not available yet, install via Xcode command line tools
            xcode-select --install 2>/dev/null || true
            echo "⚠️  Please install Xcode command line tools and re-run this script"
            exit 1
        fi
    fi
    
    # Clone the repository to temp directory
    git clone "$REPO_URL" "$TEMP_DIR"
    cd "$TEMP_DIR"
}

# Function to install Homebrew if not present
install_homebrew() {
    if ! command_exists brew; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "✅ Homebrew already installed"
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🐚 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "✅ Oh My Zsh already installed"
    fi
}

# Function to install zsh plugins
install_zsh_plugins() {
    echo "🔌 Installing Zsh plugins..."
    
    # zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    
    # fzf-tab
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab" ]; then
        git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab
    fi
}

# Function to setup configuration files
setup_config_files() {
    echo "📝 Setting up configuration files..."
    
    # Backup and copy .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        echo "💾 Backed up existing .zshrc"
    fi
    cp "$TEMP_DIR/.zshrc" "$HOME/.zshrc"
    echo "✅ Copied .zshrc to home directory"
    
    # Copy .bash_aliases
    if [ -f "$TEMP_DIR/.bash_aliases" ]; then
        if [ -f "$HOME/.bash_aliases" ]; then
            cp "$HOME/.bash_aliases" "$HOME/.bash_aliases.backup.$(date +%Y%m%d_%H%M%S)"
            echo "💾 Backed up existing .bash_aliases"
        fi
        cp "$TEMP_DIR/.bash_aliases" "$HOME/.bash_aliases"
        echo "✅ Copied .bash_aliases to home directory"
    fi
    
    # Create placeholder files referenced in .zshrc
    touch "$HOME/.env" 2>/dev/null || true
    touch "$HOME/.fnm.sh" 2>/dev/null || true
    touch "$HOME/.functions.sh" 2>/dev/null || true
    
    # Create .env file with placeholder content if it doesn't exist
    if [ ! -f "$HOME/.env" ] || [ ! -s "$HOME/.env" ]; then
        echo "📝 Creating .env file..."
        cat > "$HOME/.env" << 'ENV_EOF'
# Environment variables
# Add your environment variables here
# Example: export DATABASE_URL="your-database-url"
ENV_EOF
    fi
}

# Main installation function
main() {
    echo "🔧 Installing development tools..."
    
    # Clone the setup repository first
    clone_setup_repo
    
    # Install Homebrew first
    install_homebrew
    
    # Update Homebrew
    echo "🔄 Updating Homebrew..."
    brew update
    
    # Install essential tools via Homebrew
    echo "📋 Installing essential tools..."
    
    # Core development tools
    brew_packages=(
        "git"
        "gh"           # GitHub CLI
        "awscli"       # AWS CLI
        "zoxide"       # Smart cd command
        "starship"     # Cross-shell prompt
        "eza"          # Modern ls replacement
        "fnm"          # Fast Node Manager
        "pnpm"         # Package manager
        "mysql-client" # MySQL client
        "composer"     # PHP package manager
        "fzf"          # Fuzzy finder
    )
    
    # Install Docker Desktop (includes daemon and CLI tools)
    if ! brew list --cask docker &>/dev/null; then
        echo "📦 Installing Docker Desktop..."
        brew install --cask docker
    else
        echo "✅ Docker Desktop already installed"
    fi
    
    for package in "${brew_packages[@]}"; do
        if ! brew list "$package" &>/dev/null; then
            echo "📦 Installing $package..."
            brew install "$package"
        else
            echo "✅ $package already installed"
        fi
    done
    
    # Install Bun (JavaScript runtime and package manager)
    if ! command_exists bun; then
        echo "📦 Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        # Add Bun to PATH for current session
        export PATH="$HOME/.bun/bin:$PATH"
    else
        echo "✅ Bun already installed"
    fi
    
    # Install Oh My Zsh and plugins
    install_oh_my_zsh
    install_zsh_plugins
    
    # Setup Docker networks for Traefik
    echo "🐳 Setting up Docker networks..."
    docker network create traefik 2>/dev/null || echo "✅ Traefik network already exists"
    docker network create haproxy 2>/dev/null || echo "✅ HAProxy network already exists"
    
    # Setup directories referenced in .zshrc
    echo "📁 Creating necessary directories..."
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.docker/completions"
    mkdir -p "$HOME/.eza/completions/zsh"
    
    # Setup configuration files
    setup_config_files
    
    # Setup FZF if not already done
    if [ ! -d "$HOME/.local/share/fzf" ]; then
        echo "🔍 Setting up FZF..."
        mkdir -p "$HOME/.local/share"
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.local/share/fzf"
        "$HOME/.local/share/fzf/install" --all
    fi
    
    # Install OpenCode if not present
    if ! command_exists opencode; then
        echo "💻 OpenCode not found. You may want to install it manually."
        echo "   Visit: https://github.com/sst/opencode for installation instructions"
    fi
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Configure your .env file with necessary environment variables"
    echo "3. Set up your .functions.sh with custom functions"
    echo "4. Clone this repo to ~/Apps/setup to access Traefik configs:"
    echo "   git clone $REPO_URL ~/Apps/setup"
    echo "5. Run 'docker-compose up -d' in the traefik directory to start services"
    echo "6. Configure DNS to use 127.0.0.1:53 for .local domains"
    echo ""
    echo "🔧 Tools installed:"
    echo "   • Homebrew package manager"
    echo "   • Oh My Zsh with plugins"
    echo "   • Docker and Docker Compose"
    echo "   • GitHub CLI (gh)"
    echo "   • AWS CLI"
    echo "   • Node.js tooling (fnm, pnpm, bun)"
    echo "   • Development utilities (fzf, eza, zoxide, starship)"
    echo "   • Traefik and HAProxy Docker networks"
    echo "   • Shell configuration files (.zshrc, .bash_aliases)"
    echo ""
    echo "Happy coding! 🚀"
}

# Run main function
main "$@"