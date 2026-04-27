#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
IMAGE="${IMAGE:="opencode:local"}"
REMOTE_IMAGE="ghcr.io/european-epc-competence-center/opencode-container:main"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [-- OPENCODE_ARGS...]

Run the OpenCode container. By default, pulls and runs the pre-built image
from the GitHub Container Registry.

OPTIONS:
    --build         Build the local image before running (uses IMAGE env var
                    or "opencode:local" as the image name). Pass twice or
                    combine with -b to force a rebuild even if the image exists.
    -b              Force rebuild of the local OpenCode image (implies --build)
    -i IMAGE        Use specified Docker image name (default when --build is
                    used: opencode:local; otherwise uses the remote image)
    -v MOUNT        Mount additional volume (format: /host/path:/container/path)
                    Can be specified multiple times
    -h              Show this help message and exit

ARGUMENTS AFTER '--':
    All arguments after '--' are forwarded to opencode without interpretation.
    This allows passing options to opencode that would otherwise be interpreted
    by this script (e.g., -b, -h).

ENVIRONMENT VARIABLES:
    IMAGE                    Docker image name to use when --build is active
                             (default: opencode:local)
    OPENCODE_EXTRA_MOUNTS    Semicolon-separated list of volume mounts
                             (e.g., "/host/path1:/container/path1;/host/path2:/container/path2")

EXAMPLES:
    $(basename "$0")                        # Pull remote image and run
    $(basename "$0") --build                # Build local image if needed, then run
    $(basename "$0") --build -b             # Force rebuild local image, then run
    $(basename "$0") -b                     # Force rebuild local image, then run
    $(basename "$0") -i myimage:latest      # Use custom image name (pulls if no --build)
    $(basename "$0") --build -i myimage:latest      # Build custom image, then run
    $(basename "$0") -v /data:/data         # Mount additional volume
    $(basename "$0") -v /data:/data -v /logs:/logs  # Mount multiple volumes
    $(basename "$0") -- --version           # Pass --version to opencode
    $(basename "$0") --build -- --help      # Build container, then pass --help to opencode
    OPENCODE_EXTRA_MOUNTS="/data:/data;/logs:/logs" $(basename "$0")  # Mount via environment variable

EOF
}

parse_args() {
    BUILD=false
    FORCE_BUILD=false
    CUSTOM_IMAGE=false
    POSITIONAL_ARGS=()
    EXTRA_VOLUMES=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --)
            shift
            POSITIONAL_ARGS+=("$@")
            break
            ;;
        --build)
            BUILD=true
            shift
            ;;
        -b)
            BUILD=true
            FORCE_BUILD=true
            shift
            ;;
        -i)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: -i requires an image name argument" >&2
                show_help
                exit 1
            fi
            IMAGE="$2"
            CUSTOM_IMAGE=true
            shift 2
            ;;
        -v)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: -v requires a mount specification (format: /host/path:/container/path)" >&2
                show_help
                exit 1
            fi
            EXTRA_VOLUMES+=("$2")
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Invalid option $1" >&2
            show_help
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
        esac
    done
}

build_image() {
    echo "Build directory: $SCRIPT_DIR"

    if [ "$FORCE_BUILD" = true ]; then
        echo "Force rebuilding opencode image..."
        DOCKER_BUILDKIT=1 docker build --progress=plain -t "$IMAGE" "$SCRIPT_DIR"
        return
    fi

    if [ -z "$(docker images -q "$IMAGE" 2>/dev/null)" ]; then
        echo "Building opencode image..."
        DOCKER_BUILDKIT=1 docker build --progress=plain -t "$IMAGE" "$SCRIPT_DIR"
    else
        echo "Using existing opencode image."
    fi
}

run_container() {
    # Create local opencode directories if they don't exist
    mkdir -p "$HOME/.local/share/opencode"
    mkdir -p "$HOME/.config/opencode"
    mkdir -p "$HOME/.local/state/opencode"

    local volume_args=(
        -v "$(pwd):/app"
        -v "$HOME/.local/share/opencode:/home/opencode/.local/share/opencode"
        -v "$HOME/.config/opencode:/home/opencode/.config/opencode"
        -v "$HOME/.local/state/opencode:/home/opencode/.local/state/opencode"
    )

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

main() {
    parse_args "$@"

    if [ "$BUILD" = true ]; then
        build_image
    else
        # Use remote image unless a custom image was explicitly provided
        if [ "$CUSTOM_IMAGE" = false ]; then
            IMAGE="$REMOTE_IMAGE"
        fi
        echo "Pulling image: $IMAGE"
        docker pull "$IMAGE"
    fi

    run_container
}

main "$@"
