# Notes Index

## Project Overview

Docker containerization for OpenCode to isolate AI code execution from the host system. Configured for EECC API with Claude Sonnet models.

## Project Structure

```
/
├── Dockerfile                      # Ubuntu 22.04 + OpenCode + dev tools
├── startup.sh                      # Container entrypoint (config init + OpenCode launch)
├── run_opencode_container.sh       # Build & run convenience script
├── .dockerignore                   # Optimizes Docker build context
├── README.md                       # User documentation
├── Changelog.md                    # Version history
└── .cursor/
    ├── notes/index.md              # This file
    └── rules/                      # AI conventions (copied to container)
        ├── notes.mdc
        └── changelog-conventions.mdc
```

## Key Components

### Dockerfile (`/app/Dockerfile`)

- **Base:** Ubuntu 22.04
- **Tools:** git, bash, openssh-client, curl, python3, npm, ripgrep, jq, wget, unzip, file
- **OpenCode:** Installed globally via `npm install -g opencode-ai` (better PATH handling than curl install)
- **Build optimization:** BuildKit cache mounts for apt packages (speeds up rebuilds)
- **Rules injection:** Copies `.cursor/rules/*.mdc` to `/cursor/rules/` in image
- **Entrypoint:** `/usr/local/bin/startup.sh` (allows arg forwarding to OpenCode)

### startup.sh (`/app/startup.sh`)

Container initialization with two main functions:

1. **check_config():**

   - Creates `~/.config/opencode/config.json` if missing
   - Preconfigured for EECC API (baseURL: `https://api.eecc.ai/v1`)
   - Models: `claude-sonnet-4-20250514`, `claude-sonnet-4-5-20250929`
   - Prompts for EECC API key if `~/.local/share/opencode/auth.json` missing
   - Key entry portal: `https://portal.eecc.ai/`

2. **init_rules():**
   - Checks each rule file individually and copies from `/cursor/rules/` only if missing
   - Ensures workdir has notes and changelog conventions without overwriting existing files

Then launches `opencode "$@"` with forwarded arguments.

### run_opencode_container.sh (`/app/run_opencode_container.sh`)

Wrapper script with:

- **Options:** `-b` (force rebuild), `-h` (help)
- **Logic:**
  - Detects script dir via `readlink -f` (follows symlinks)
  - Builds `opencode` image if missing or if `-b` specified
  - Uses `DOCKER_BUILDKIT=1` with `--progress=plain` for full build logs
  - Creates `~/.local/share/opencode` and `~/.config/opencode` on host
- **Volume mounts:**
  - `$(pwd) → /app` (working directory)
  - `~/.local/share/opencode → /root/.local/share/opencode` (auth persistence)
  - `~/.config/opencode → /root/.config/opencode` (config persistence)
- **Container:** Interactive (`-it`), auto-cleanup (`--rm`), named `opencode`
- **Args:** Forwards remaining positional args to container

### .dockerignore (`/app/.dockerignore`)

Excludes from build context:

- `.git`, documentation (README.md, Changelog.md)
- `run_opencode_container.sh` (not needed in image)
- Editor files (`.vscode/`, `*.swp`)
- Local config (`.env`, `*.log`)

**Purpose:** Prevents unnecessary layer invalidation when docs/scripts change.

## Security Model

- **Isolation:** AI commands execute inside container, not on host
- **Access control:** Only mounted directories accessible (current dir + OpenCode config)
- **State persistence:** Config/auth survive container restarts via volume mounts
- **No network restrictions:** Container has full network access for OpenCode operations

## Development Workflow

1. **Make changes** to Dockerfile, scripts, or rules
2. **Test locally:** `./run_opencode_container.sh -b` (force rebuild)
3. **Update Changelog.md** (see `changelog-conventions.mdc`)
4. **Update notes** (this file) if architecture changes
5. **Update README.md** for user-facing changes

## Typical User Workflow

1. Symlink script to PATH: `ln -s $(pwd)/run_opencode_container.sh ~/.local/bin/`
2. Nroject: `cd ~/my_project`
3. Run: `run_opencode_container.sh`
4. First run: Enter EECC API key when prompted
5. Container inits rules in workdir, launches OpenCode

## Troubleshooting Notes

- **PATHues:** npm global install preferred over curl (containerization)
- **Build caching:** `.dockerignore` critical for fast rebuilds
- **Symlinks:** Script uses `readlink -f` topath correctly
- **ENTRYPOINT vs CMD:** ENTRYPOINT allows `docker run` args to pass through
- **Rules initialization:** Each rule file checked individually, copied only if missing (won't overwrite existing files)

## Related Files

- `changelog-conventions.mdcg format rules
- `notes.mdc`: Notes maintenance guidelines
