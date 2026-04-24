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
    mkdir -p "$HOME/.local/state/opencode"

    # Build array of volume mounts
    local volume_args=(
        -v "$(pwd):/app"
        -v "$HOME/.local/share/opencode:/home/opencode/.local/share/opencode"
        -v "$HOME/.config/opencode:/home/opencode/.config/opencode"
        -v "$HOME/.local/state/opencode:/home/opencode/.local/state/opencode"
    )

    # Add extra volumes from command line arguments (via EXTRA_VOLUMES array)
    if [ ${#EXTRA_VOLUMES[@]} -gt 0 ]; then
        for mount in "${EXTRA_VOLUMES[@]}"; do
            volume_args+=(-v "$mount")
        done
    fi

    # Add extra volumes from environment variable OPENCODE_EXTRA_MOUNTS
    # Format: /host/path1:/container/path1;/host/path2:/container/path2
    if [ -n "$OPENCODE_EXTRA_MOUNTS" ]; then
        IFS=';' read -ra MOUNTS <<< "$OPENCODE_EXTRA_MOUNTS"
        for mount in "${MOUNTS[@]}"; do
            if [ -n "$mount" ]; then
                volume_args+=(-v "$mount")
            fi
        done
    fi

    docker run -it --rm \
        --name opencode \
        -e HOST_UID="$(id -u)" \
        -e HOST_GID="$(id -g)" \
        "${volume_args[@]}" \
        "$IMAGE" \
        "${POSITIONAL_ARGS[@]}"
}
