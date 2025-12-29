#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${SCRIPT_DIR}"/common.sh

parse_args() {
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
        -v)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: -v requires a mount specification (format: /host/path:/container/path)" >&2
                exit 1
            fi
            EXTRA_VOLUMES+=("$2")
            shift 2
            ;;
        *)
            # Non-option argument
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
        esac
    done
}

main() {
    parse_args "$@"
    IMAGE="ghcr.io/european-epc-competence-center/opencode-container:main"
    docker pull "$IMAGE"
    run_container
}

main "$@"
