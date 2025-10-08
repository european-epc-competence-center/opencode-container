echo '{
{
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
}' >~/.config/opencode/config.json

opencode
