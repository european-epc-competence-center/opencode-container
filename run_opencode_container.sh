#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${SCRIPT_DIR}"/common.sh

main() {
    IMAGE="ghcr.io/european-epc-competence-center/opencode-container:main"
    POSITIONAL_ARGS=("$@")
    run_container
}

main "$@"
