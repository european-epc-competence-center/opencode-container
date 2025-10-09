#!/usr/bin/env bash

set -e

# Run the container
run_container() {
    if [ -z "$IMAGE" ]; then
        echo "IMAGE is not set"
        exit 1
    fi

    # Create local opencode directories if they don't exist
    mkdir -p "$HOME/.local/share/opencode"
    mkdir -p "$HOME/.config/opencode"

    docker run -it --rm \
        --name opencode \
        -v "$(pwd):/app" \
        -v "$HOME/.local/share/opencode:/root/.local/share/opencode" \
        -v "$HOME/.config/opencode:/root/.config/opencode" \
        "$IMAGE" \
        "${POSITIONAL_ARGS[@]}"
}
