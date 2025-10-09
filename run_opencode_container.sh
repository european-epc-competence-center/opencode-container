#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

IMAGE="opencode:local"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [-- OPENCODE_ARGS...]

Run the OpenCode container. Builds the image if it doesn't exist.

OPTIONS:
    -b          Force rebuild of the OpenCode image
    -h          Show this help message and exit

ARGUMENTS AFTER '--':
    All arguments after '--' are forwarded to opencode without interpretation.
    This allows passing options to opencode that would otherwise be interpreted
    by this script (e.g., -b, -h).

EXAMPLES:
    $(basename "$0")                    # Run the container (build if needed)
    $(basename "$0") -b                 # Force rebuild and run the container
    $(basename "$0") -- --version       # Pass --version to opencode
    $(basename "$0") -b -- --help       # Rebuild container, then pass --help to opencode

EOF
}

parse_args() {
    FORCE_BUILD=false
    POSITIONAL_ARGS=()

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
        DOCKER_BUILDKIT=1 docker build --progress=plain -t $IMAGE "$SCRIPT_DIR"
        return
    fi

    # Build the image if it doesn't exist
    if [ -z "$(docker images -q opencode 2>/dev/null)" ]; then
        echo "Building opencode image..."
        DOCKER_BUILDKIT=1 docker build --progress=plain -t $IMAGE "$SCRIPT_DIR"
    else
        echo "Using existing opencode image."
    fi
}

# Run the container
run_container() {
    # Create local opencode directories if they don't exist
    mkdir -p "$HOME/.local/share/opencode"
    mkdir -p "$HOME/.config/opencode"

    docker run -it --rm \
        --name opencode \
        -v "$(pwd):/app" \
        -v "$HOME/.local/share/opencode:/root/.local/share/opencode" \
        -v "$HOME/.config/opencode:/root/.config/opencode" \
        $IMAGE \
        "${POSITIONAL_ARGS[@]}"
}

main() {
    parse_args "$@"
    build_image "$FORCE_BUILD"
    run_container
}

main "$@"
