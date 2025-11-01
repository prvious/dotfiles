#!/bin/bash

# Laptop Setup Script
# This script sets up a development environment based on the configurations in this repo
# Usage: curl https://raw.githubusercontent.com/prvious/dotfiles/refs/heads/main/install.sh | bash

set -e  # Exit on any error

REPO_URL="https://github.com/prvious/dotfiles.git"
TEMP_DIR="/tmp/setup-$$"

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

docker_info() {
    echo "🐳 $1"
}

config_info() {
    echo "📝 $1"
}

download_info() {
    echo "📥 $1"
}

cleanup_info() {
    echo "🧹 $1"
}

test_info() {
    echo "🔍 $1"
}

plugin_info() {
    echo "🔌 $1"
}

shell_info() {
    echo "🐚 $1"
}

network_info() {
    echo "🌐 $1"
}

folder_info() {
    echo "📁 $1"
}

backup_info() {
    echo "💾 $1"
}

code_info() {
    echo "💻 $1"
}

celebrate() {
    echo "🎉 $1"
}

list_info() {
    echo "📋 $1"
}

wrench_info() {
    echo "🔧 $1"
}

update_info() {
    echo "🔄 $1"
}

info "Starting laptop setup..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed for macOS"
    exit 1
fi

# Check if running as root/sudo
if [ "$EUID" -eq 0 ]; then
    error "This script should NOT be run with sudo or as root"
    echo "   Homebrew installation requires a regular user account"
    echo "   Please run without sudo: curl -fsSL https://raw.githubusercontent.com/prvious/dotfiles/refs/heads/main/install.sh | bash"
    echo ""
    echo "   Note: The script will prompt for sudo password when needed for specific tasks"
    echo "   (e.g., dnsmasq setup), but the script itself should run as a regular user."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to cleanup temporary directory
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        cleanup_info "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Function to check and install Xcode Command Line Tools
ensure_xcode_tools() {
    # Check if Xcode Command Line Tools are installed
    if ! xcode-select -p &>/dev/null; then
        package_info "Xcode Command Line Tools are required but not installed"
        echo "   Installing Xcode Command Line Tools..."
        echo "   This is required for Homebrew and other development tools"
        
        # Trigger the installation
        xcode-select --install 2>/dev/null || true
        
        echo ""
        warning "IMPORTANT: A dialog box has appeared to install Xcode Command Line Tools"
        echo "   Please click 'Install' and wait for the installation to complete"
        echo "   This may take several minutes depending on your internet connection"
        echo ""
        echo "   After installation completes, please re-run this script:"
        echo "   curl -fsSL https://raw.githubusercontent.com/prvious/dotfiles/refs/heads/main/install.sh | bash"
        echo ""
        exit 1
    else
        success "Xcode Command Line Tools already installed"
    fi
}

# Function to clone setup repository
clone_setup_repo() {
    download_info "Downloading setup files..."
    
    # Install git first if not present
    # Git should be available with Xcode Command Line Tools, but check anyway
    if ! command_exists git; then
        package_info "Installing git..."
        brew install git
    fi
    
    # Clone the repository to temp directory
    git clone "$REPO_URL" "$TEMP_DIR"
    cd "$TEMP_DIR"
}

# Function to install Homebrew if not present
install_homebrew() {
    if ! command_exists brew; then
        package_info "Installing Homebrew..."
        
        # Check if running in non-interactive mode
        if [ ! -t 0 ]; then
            echo ""
            warning "WARNING: Running in non-interactive mode (stdin is not a TTY)"
            echo "   Homebrew installation requires sudo access and needs to prompt for your password."
            echo ""
            echo "   If the installation fails, please run this script interactively:"
            echo "   1. Download: curl -fsSL https://raw.githubusercontent.com/prvious/dotfiles/refs/heads/main/install.sh -o setup.sh"
            echo "   2. Run: bash setup.sh"
            echo ""
            echo "   Attempting Homebrew installation anyway..."
            sleep 2
        fi
        
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        success "Homebrew already installed"
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        shell_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        success "Oh My Zsh already installed"
    fi
}

# Function to setup dnsmasq for .test domains
setup_dnsmasq() {
    network_info "Setting up dnsmasq for .test domain resolution..."
    echo "   Note: This step requires sudo access to modify system configuration"
    
    # Create config directory if it doesn't exist
    mkdir -p "$(brew --prefix)/etc/"
    
    # Configure dnsmasq for .test domains
    if ! grep -q "address=/.test/127.0.0.1" "$(brew --prefix)/etc/dnsmasq.conf" 2>/dev/null; then
        config_info "Configuring dnsmasq for .test domains..."
        echo 'address=/.test/127.0.0.1' >> "$(brew --prefix)/etc/dnsmasq.conf"
        echo 'port=53' >> "$(brew --prefix)/etc/dnsmasq.conf"
    else
        success "dnsmasq already configured for .test domains"
    fi
    
    # Create resolver directory
    sudo mkdir -p /etc/resolver
    
    # Add .test resolver
    if [ ! -f /etc/resolver/test ]; then
        config_info "Adding .test resolver..."
        echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/test > /dev/null
    else
        success ".test resolver already exists"
    fi
    
    # Start dnsmasq service
    if ! brew services list | grep -q "dnsmasq.*started"; then
        info "Starting dnsmasq service..."
        sudo brew services start dnsmasq
    else
        success "dnsmasq service already running"
    fi
    
    # Test DNS resolution
    test_info "Testing .test domain resolution..."
    if dscacheutil -q host -a name test.test >/dev/null 2>&1; then
        success ".test domain resolution working"
    else
        warning ".test domain resolution may need a moment to activate"
        echo "   Try: dscacheutil -q host -a name test.test"
    fi
}

# Function to install zsh plugins
install_zsh_plugins() {
    plugin_info "Installing Zsh plugins..."
    
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
    config_info "Setting up configuration files..."
    
    # Backup and copy .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        backup_info "Backed up existing .zshrc"
    fi
    cp "$TEMP_DIR/.zshrc" "$HOME/.zshrc"
    success "Copied .zshrc to home directory"
    
    # Copy .bash_aliases
    if [ -f "$TEMP_DIR/.bash_aliases" ]; then
        if [ -f "$HOME/.bash_aliases" ]; then
            cp "$HOME/.bash_aliases" "$HOME/.bash_aliases.backup.$(date +%Y%m%d_%H%M%S)"
            backup_info "Backed up existing .bash_aliases"
        fi
        cp "$TEMP_DIR/.bash_aliases" "$HOME/.bash_aliases"
        success "Copied .bash_aliases to home directory"
    fi
    
    # Create placeholder files referenced in .zshrc
    cp "$TEMP_DIR/.env.sh" "$HOME/.env.sh" 2>/dev/null || true
    cp "$TEMP_DIR/.functions.sh" "$HOME/.functions.sh" 2>/dev/null || true
}

# Main installation function
main() {
    wrench_info "Installing development tools..."
    
    # Check for Xcode Command Line Tools first
    ensure_xcode_tools
    
    # Install Homebrew first
    install_homebrew

    # Clone the setup repository first
    clone_setup_repo
    
    # Update Homebrew (skip in CI for speed)
    if [ -z "${GITHUB_ACTIONS}" ]; then
        update_info "Updating Homebrew..."
        brew update
    else
        info "Skipping Homebrew update in CI for performance"
    fi
    
    # Install essential tools via Homebrew
    list_info "Installing essential tools..."
    
    if command_exists jq; then
        success "jq already installed"
    else
        package_info "Installing jq..."
        brew install jq
    fi
    
    if command_exists json5; then
        success "json5 already installed"
    else
        package_info "Installing json5..."
        brew install json5
    fi
    
    # Core development tools
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
    
    # Install Docker Desktop (includes daemon, buildx, and more)
    # Check if Docker is already available (from any source)
    if command_exists docker; then
        success "Docker already installed"
    elif ! brew list --cask docker &>/dev/null; then
        package_info "Installing Docker Desktop..."
        brew install --cask docker
    else
        success "Docker Desktop already installed via Homebrew"
    fi
    
    for package in "${brew_packages[@]}"; do
        if command_exists "$package"; then
            success "$package already installed"
        elif ! brew list "$package" &>/dev/null; then
            package_info "Installing $package..."
            brew install "$package"
        else
            success "$package already installed via Homebrew"
        fi
    done
    
    # Install Bun (JavaScript runtime and package manager)
    if ! command_exists bun; then
        package_info "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        # Add Bun to PATH for current session
        export PATH="$HOME/.bun/bin:$PATH"
    else
        success "Bun already installed"
    fi
    
    # Install Oh My Zsh and plugins
    install_oh_my_zsh
    install_zsh_plugins
    
    # Setup dnsmasq for .test domains
    setup_dnsmasq
    
    # Setup Docker networks for Traefik
    docker_info "Setting up Docker networks..."
    docker network create traefik 2>/dev/null || success "Traefik network already exists"
    docker network create haproxy 2>/dev/null || success "HAProxy network already exists"
    
    # Setup directories referenced in .zshrc
    folder_info "Creating necessary directories..."
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.docker/completions"
    mkdir -p "$HOME/.eza/completions/zsh"
    
    # Setup configuration files
    setup_config_files
    
    # Install OpenCode if not present
    if ! command_exists opencode; then
        code_info "Installing OpenCode..."
        curl -fsSL https://opencode.ai/install | bash
    fi
    
    echo ""
    celebrate "Setup complete!"
    echo ""
    list_info "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Configure your .env file with necessary environment variables"
    echo "3. Set up your .functions.sh with custom functions"
    echo "4. Clone this repo to access Traefik configs:"
    echo "   git clone $REPO_URL traefik"
    echo "5. Run 'docker-compose up -d' in the traefik directory to start services"
    echo "6. Test .test domain resolution: dscacheutil -q host -a name test.test"
    echo ""
    wrench_info "Tools installed:"
    echo "   • Homebrew package manager"
    echo "   • Oh My Zsh with plugins"
    echo "   • Docker and Docker Compose"
    echo "   • dnsmasq for .test domain resolution"
    echo "   • GitHub CLI (gh)"
    echo "   • AWS CLI"
    echo "   • Node.js tooling (fnm, pnpm, bun)"
    echo "   • Development utilities (fzf, eza, zoxide, starship)"
    echo "   • Traefik and HAProxy Docker networks"
    echo "   • Shell configuration files (.zshrc, .env.sh)"
    echo ""
    info "Happy coding!"
}

# Run main function
main "$@"