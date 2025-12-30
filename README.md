# Dotfiles

Development environment setup for macOS with automated installation and update scripts.

## Quick Start

### Initial Installation

Run the installer using curl (non-sudo mode):

```bash
curl -fsSL https://raw.githubusercontent.com/munezaclovis/setup/refs/heads/main/install.sh | bash
```

**Important**: DO NOT run with sudo. The script will prompt for your password when needed for specific tasks.

If the installation fails due to interactive prompts, you can download and run locally:

```bash
curl -fsSL https://raw.githubusercontent.com/munezaclovis/setup/refs/heads/main/install.sh -o setup.sh
bash setup.sh
```

### Updating Packages

After installation, you can update all installed packages using:

```bash
./update.sh
```

This will update all Homebrew packages and dependencies to their latest versions.

## What the installer does

The installer will:

-   Install Xcode Command Line Tools (if not present)
-   Install Homebrew package manager
-   Install Oh My Zsh with plugins (zsh-autosuggestions, fzf-tab, etc...)
-   Install development tools:
    -   Docker Desktop and Docker Compose
    -   GitHub CLI (gh)
    -   AWS CLI
    -   Node.js tooling (fnm, pnpm, bun)
    -   Development utilities (fzf, eza, zoxide, starship)
-   Configure dnsmasq for `.test` domain resolution
-   Setup Docker networks (traefik, haproxy)
-   Copy configuration files (.zshrc, .env.sh)
-   Create symlinks for scripts in ./scripts to ~/.local/bin
-   Install OpenCode CLI tool
-   Create necessary directories (~/.local/bin, ~/.docker/completions, etc.)

## Post-installation

After installation:

1. Restart your terminal or run: `source ~/.zshrc`
2. Configure your `.env.sh` file with necessary environment variables
3. Test .test domain resolution: `dscacheutil -q host -a name test.test`
