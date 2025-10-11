# Docker devcontainer helper function
# Run commands in the Docker container specified in .devcontainer/devcontainer.json
d() {
    # Check if .devcontainer/devcontainer.json exists
    if [ ! -f ".devcontainer/devcontainer.json" ]; then
        echo "❌ .devcontainer/devcontainer.json not found"
        return 1
    fi

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "❌ jq is required but not installed"
        echo "💡 Install with: brew install jq"
        return 1
    fi

    # Extract service and remoteUser from devcontainer.json using jq
    local service=$(json5 .devcontainer/devcontainer.json | jq -r '.service')
    local remote_user=$(json5 .devcontainer/devcontainer.json | jq -r '.remoteUser')

    # If service is not found, error out
    if [ -z "$service" ]; then
        echo "❌ Could not find 'service' in .devcontainer/devcontainer.json"
        return 1
    fi

    # Build the docker compose exec command
    local docker_cmd="docker-compose exec"
    
    # Add user flag if remoteUser is specified
    if [ -n "$remote_user" ]; then
        docker_cmd="$docker_cmd -u $remote_user"
    fi

    # If no arguments, open an interactive shell
    if [ $# -eq 0 ]; then
        eval "$docker_cmd $service zsh"
    else
        # Add service and use interactive shell to load aliases
        docker_cmd="$docker_cmd $service zsh -i -c"

        # Execute the command
        eval "$docker_cmd \"$*\""
    fi
}
