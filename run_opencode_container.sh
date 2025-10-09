#!/usr/bin/env bash

source ./common.sh

main() {
    IMAGE="ghcr.io/european-epc-competence-center/opencode-container:main"
    POSITIONAL_ARGS=("$@")
    run_container
}

main "$@"
