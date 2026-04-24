#!/usr/bin/env bash

set -e

IMAGE="${IMAGE:="opencode:local"}"

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${SCRIPT_DIR}"/common.sh

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [-- OPENCODE_ARGS...]

Run the OpenCode container. Builds the image if it doesn't exist.

OPTIONS:
    -b              Force rebuild of the OpenCode image
    -i IMAGE        Use specified Docker image name (default: opencode:local)
    -v MOUNT        Mount additional volume (format: /host/path:/container/path)
                    Can be specified multiple times
    -h              Show this help message and exit

ARGUMENTS AFTER '--':
    All arguments after '--' are forwarded to opencode without interpretation.
    This allows passing options to opencode that would otherwise be interpreted
    by this script (e.g., -b, -h).

ENVIRONMENT VARIABLES:
    OPENCODE_EXTRA_MOUNTS    Semicolon-separated list of volume mounts
                             (e.g., "/host/path1:/container/path1;/host/path2:/container/path2")

EXAMPLES:
    $(basename "$0")                        # Run the container (build if needed)
    $(basename "$0") -b                     # Force rebuild and run the container
    $(basename "$0") -i myimage:latest      # Use custom image name
    $(basename "$0") -v /data:/data         # Mount additional volume
    $(basename "$0") -v /data:/data -v /logs:/logs  # Mount multiple volumes
    $(basename "$0") -- --version           # Pass --version to opencode
    $(basename "$0") -b -- --help           # Rebuild container, then pass --help to opencode
    $(basename "$0") -i "ghcr.io/european-epc-competence-center/opencode-container:main" -b        # Use the github image instead of the local one
    OPENCODE_EXTRA_MOUNTS="/data:/data;/logs:/logs" $(basename "$0")  # Mount via environment variable

EOF
}

parse_args() {
    FORCE_BUILD=false
    POSITIONAL_ARGS=()
    EXTRA_VOLUMES=()

    # Parse arguments manually to properly handle '--' separator
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --)
            # Everything after '--' goes to positional args (forwarded to opencode)
            shift
            POSITIONAL_ARGS+=("$@")
            break
            ;;
        -b)
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
        -h)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Invalid option $1" >&2
            show_help
            exit 1
            ;;
        *)
            # Non-option argument
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
        esac
    done
}

build_image() {
    local force_build=$1

    echo "Building opencode image..."
    echo "Build directory: $SCRIPT_DIR"

    # Force rebuild if requested
    if [ "$force_build" = true ]; then
        echo "Force rebuilding opencode image..."
        DOCKER_BUILDKIT=1 docker build --progress=plain -t "$IMAGE" "$SCRIPT_DIR"
        return
    fi

    # Build the image if it doesn't exist
    if [ -z "$(docker images -q "$IMAGE" 2>/dev/null)" ]; then
        echo "Building opencode image..."
        DOCKER_BUILDKIT=1 docker build --progress=plain -t "$IMAGE" "$SCRIPT_DIR"
    else
        echo "Using existing opencode image."
    fi
}

main() {
    parse_args "$@"
    build_image "$FORCE_BUILD"
    run_container
}

main "$@"
