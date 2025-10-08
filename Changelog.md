# Changelog

## WIP

## 1.0.0+2025-10-08

- Modified `startup.sh` to prompt user for API key when auth file doesn't exist, instead of using hardcoded key
- Fixed syntax error in `startup.sh` (missing bracket in file check condition)
- Changed Dockerfile to use `ENTRYPOINT` instead of `CMD` to properly support argument forwarding to opencode
- Fixed `.dockerignore` to include `startup.sh` in build context (was being excluded by `*.sh` pattern)
- Initial project setup with OpenCode Docker container
- Created Dockerfile based on Ubuntu 22.04 with essential development tools
- Added convenience script `run_opencode_container.sh` with:
  - Automatic image building
  - Force rebuild option (`-b`)
  - Help documentation (`-h`)
  - Volume mounting for current directory and OpenCode config
- Enhanced README.md with comprehensive documentation:
  - Quick start guide
  - Usage examples
  - Security benefits explanation
  - Troubleshooting section
- Initialized AI notes in `.cursor/notes/index.md`
- Established changelog tracking
- Added `--progress=plain` flag to docker build commands for full build output
- Optimized Docker build caching:
  - Added `.dockerignore` to prevent unnecessary build context changes
  - Enabled BuildKit with cache mounts for apt packages
  - Ensures apt-get install layer is properly cached between builds
- Fixed OpenCode installation to use `npm install -g opencode-ai` instead of curl script for better PATH compatibility in containers
