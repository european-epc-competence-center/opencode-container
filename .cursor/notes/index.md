# Notes Index

## Project Overview

This project provides Docker containerization for OpenCode to isolate AI code execution from the host system.

## Project Structure

```
/
├── Dockerfile                      # Ubuntu 22.04 based image with OpenCode
├── run_opencode_container.sh       # Convenience script to build & run container
├── README.md                       # User-facing documentation
├── Changelog.md                    # Version history and changes
└── .cursor/
    ├── notes/                      # AI knowledge base
    └── rules/                      # AI behavior conventions
```

## Key Components

### Dockerfile

- Base: Ubuntu 22.04
- Installs common dev tools: git, bash, python3, npm, curl, jq, etc.
- Installs OpenCode via npm: `npm install -g opencode-ai` (ensures proper PATH setup in container)
- Default CMD: `opencode`

### run_opencode_container.sh

Bash script that:

- Parses command-line options (`-b` for rebuild, `-h` for help)
- Builds Docker image if missing (tag: `opencode`)
- Creates local config directories if needed
- Runs container with three volume mounts:
  - Current directory → `/app` (working directory)
  - `~/.local/share/opencode` → container (data persistence)
  - `~/.config/opencode` → container (config persistence)
- Runs interactively with automatic cleanup (`--rm`)

## Security Model

**Isolation Strategy:**

- OpenCode runs inside container with limited host access
- Only explicitly mounted directories are accessible
- AI bash commands execute in container, not on host
- Config persists across runs via volume mounts

## Development Guidelines

- Document all changes in `Changelog.md` (see `changelog-conventions.mdc`)
- Keep README.md updated for user-facing changes
- Maintain security isolation in any modifications
- Test both build and run scenarios after changes

## Related Files

- See `changelog-conventions.mdc` for Changelog.md format
- See `notes.mdc` for notes maintenance guidelines
