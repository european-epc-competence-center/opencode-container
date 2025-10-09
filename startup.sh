#!/usr/bin/env bash

set -e

check_config() {
    if [ ! -f ~/.local/share/opencode/auth.json ]; then
        echo "Auth file not found."
        mkdir -p ~/.local/share/opencode

        echo ""
        echo -n "Do you want to connect to the EECC AI API at https://portal.eecc.ai/ ? (y/n): "
        read -r use_eecc

        if [ "$use_eecc" = "y" ] || [ "$use_eecc" = "Y" ] || [ "$use_eecc" = "yes" ] || [ "$use_eecc" = "Yes" ] || [ "$use_eecc" = "YES" ]; then
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
                        },
                        "qwen3-coder": {
                            "name": "Qwen3 Coder"
                        },
                        "qwen3-coder-max": {
                            "name": "Qwen3 Coder Max"
                        },
                        "claude-opus-4-1-20250805": {
                            "name": "Claude Opus 4.1"
                        }
                    }
                }
            }
        }
' >~/.config/opencode/config.json
            else
                echo "Config file already exists."
            fi

        else
            echo "Running standard OpenCode authentication..."
            opencode auth login
        fi
    else
        echo "Auth file already exists."
    fi

}

init_rules() {
    mkdir -p "/app/.cursor/rules"

    if [ ! -f "/app/.cursor/rules/notes.mdc" ]; then
        echo "Initializing notes.mdc rule..."
        cp "/cursor/rules/notes.mdc" "/app/.cursor/rules/notes.mdc"
    fi

    if [ ! -f "/app/.cursor/rules/changelog-conventions.mdc" ]; then
        echo "Initializing changelog-conventions.mdc rule..."
        cp "/cursor/rules/changelog-conventions.mdc" "/app/.cursor/rules/changelog-conventions.mdc"
    fi
}

main() {
    check_config
    init_rules

    opencode "$@"
}

main "$@"
