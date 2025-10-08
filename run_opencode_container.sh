#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Run the OpenCode container. Builds the image if it doesn't exist.

OPTIONS:
    -b          Force rebuild of the OpenCode image
    -h          Show this help message and exit

EXAMPLES:
    $(basename "$0")           # Run the container (build if needed)
    $(basename "$0") -b        # Force rebuild and run the container

EOF
}

parse_args() {
    FORCE_BUILD=false

    # Parse arguments using getopts (built-in bash)
    while getopts ":bh" opt; do
        case $opt in
        b)
            FORCE_BUILD=true
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Error: Invalid option -$OPTARG" >&2
            show_help
            exit 1
            ;;
        esac
    done

    shift $((OPTIND - 1))
}

build_image() {
    local force_build=$1

    echo "Building opencode image..."
    echo "Build directory: $SCRIPT_DIR"

    # Force rebuild if requested
    if [ "$force_build" = true ]; then
        echo "Force rebuilding opencode image..."
        DOCKER_BUILDKIT=1 docker build --progress=plain -t opencode "$SCRIPT_DIR"
        return
    fi

    # Build the image if it doesn't exist
    if [ -z "$(docker images -q opencode 2>/dev/null)" ]; then
        echo "Building opencode image..."
        DOCKER_BUILDKIT=1 docker build --progress=plain -t opencode "$SCRIPT_DIR"
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
        opencode
}

main() {
    parse_args "$@"
    build_image "$FORCE_BUILD"
    run_container
}

main "$@"
