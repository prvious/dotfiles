# Docker devcontainer helper function
# Run commands in the Docker container specified in .devcontainer/devcontainer.json
x() {
    # Handle special subcommands first
    if [ $# -gt 0 ]; then
        case "$1" in
            "code"|"open")
                "$HOME/.local/bin/devcontainer-insiders" open
                return $?
                ;;
        esac
    fi

    # Validate environment
    if [ ! -f ".devcontainer/devcontainer.json" ]; then
        echo "❌ .devcontainer/devcontainer.json not found"
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "❌ jq is required but not installed"
        echo "💡 Install with: brew install jq"
        return 1
    fi

    # Parse devcontainer config
    local service=$(json5 .devcontainer/devcontainer.json | jq -r '.service')
    local remote_user=$(json5 .devcontainer/devcontainer.json | jq -r '.remoteUser')

    if [ -z "$service" ]; then
        echo "❌ Could not find 'service' in .devcontainer/devcontainer.json"
        return 1
    fi

    # Build docker command
    local docker_cmd="docker-compose exec"
    [ -n "$remote_user" ] && docker_cmd="$docker_cmd -u $remote_user"

    # Execute command or start shell
    if [ $# -eq 0 ]; then
        eval "$docker_cmd $service zsh"
    else
        eval "$docker_cmd $service zsh -i -c \"$*\""
    fi
}

wip() {
    git add .
    git commit -m "🏃🏾‍♂️💨 wip"
    git push origin HEAD
}