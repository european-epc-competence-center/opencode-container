#!/usr/bin/env bash

set -e

check_config() {
    if [ ! -f ~/.config/opencode/config.json ]; then
        echo "Config file not found, creating default config..."
        mkdir -p ~/.config/opencode
        echo '{
            "$schema": "https://opencode.ai/config.json",
            "provider": {
                "eecc": {
                    "npm": "@ai-sdk/openai-compatible",
                    "name": "EECC API",
                    "options": {
                        "baseURL": "https://api.eecc.ai/v1"
                    },
                    "models": {
                        "claude-sonnet-4-20250514": {
                            "name": "Claude Sonnet 4"
                        },
                        "claude-sonnet-4-5-20250929": {
                            "name": "Claude Sonnet 4.5"
                        }
                    }
                }
            }
        }
' >~/.config/opencode/config.json
    else
        echo "Config file already exists."
    fi

    if [ ! -f ~/.local/share/opencode/auth.json ]; then
        echo "Auth file not found."
        mkdir -p ~/.local/share/opencode

        echo -n "Please enter your EECC API key (generate at https://portal.eecc.ai/ ): "
        read -r api_key

        if [ -z "$api_key" ]; then
            echo "Error: API key cannot be empty."
            exit 1
        fi

        echo "Creating auth file with provided API key..."
        cat >~/.local/share/opencode/auth.json <<EOF
{
  "eecc": {
    "type": "api",
    "key": "$api_key"
  }
}
EOF
    else
        echo "Auth file already exists."
    fi

}

init_rules() {
    mkdir -p "$HOME/.cursor/rules"

    if [ ! -f "$HOME/.cursor/rules/notes.mdc" ]; then
        echo "Initializing notes.mdc rule..."
        cp "/cursor/rules/notes.mdc" "$HOME/.cursor/rules/notes.mdc"
    fi

    if [ ! -f "$HOME/.cursor/rules/changelog-conventions.mdc" ]; then
        echo "Initializing changelog-conventions.mdc rule..."
        cp "/cursor/rules/changelog-conventions.mdc" "$HOME/.cursor/rules/changelog-conventions.mdc"
    fi
}

main() {
    check_config
    init_rules

    opencode "$@"
}

main "$@"
