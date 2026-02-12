# Claudetainer

A simple wrapper for running Claude CLI in a Docker sandbox with automatic API key validation and default prompt support.

## Security Model

Docker sandbox runs each session in a **lightweight microVM** — not a standard container. This provides hardware-level isolation with a dedicated kernel per sandbox:

| Layer | Protection |
|-------|-----------|
| **Process** | Separate kernel space — agent cannot see or signal host processes |
| **Filesystem** | Only the current workspace is synced in; no access to `~/.ssh`, browser cookies, or other host files |
| **Network** | Outbound traffic goes through an HTTP/HTTPS filtering proxy (`host.docker.internal:3128`); no access to host localhost or other sandboxes |
| **Docker** | Private Docker daemon — no access to host images, containers, or volumes |

When a sandbox is removed, everything inside is destroyed: installed packages, built images, and any state not synced back to the workspace.

> Traditional container hardening (`--cap-drop`, `USER`, `--security-opt`) is unnecessary here — isolation happens at the hypervisor level via macOS `virtualization.framework` or Windows Hyper-V.

## What it does

`claudetainer` is a convenience script that:

- Checks if your Anthropic API key is configured
- Validates Docker is installed
- Supports default prompts via config file or environment variable
- Runs Claude in a Docker sandbox with permissions pre-approved
- Equivalent to: `docker sandbox run claude . -- --allowedTools '*'`

**Note**: Uses `--allowedTools '*'` instead of `--dangerously-skip-permissions` because the latter is blocked when running as root (which Docker containers often do for isolation).

## Quick Start

See **[QUICKSTART.md](QUICKSTART.md)** for a simple 5-minute setup guide.

**TL;DR:**

```bash
git clone https://github.com/marcel-rbro/claudetainer.git
cd claudetainer
./install.sh --api-key "sk-ant-api03-your-key-here"
source ~/.zshrc  # or ~/.bashrc

cd ~/your-project
claudetainer "Review the code in this repository"
```

## Installation

For detailed installation instructions, see **[INSTALL.md](INSTALL.md)**.

Installation methods:
- **Automated**: Use `./install.sh` with parameters
- **Manual**: Copy to `/usr/local/bin`
- **Development**: Symlink method for contributors

Update existing installation:
```bash
./install.sh --update
```

Uninstall:
```bash
./install.sh --uninstall
```

## Requirements

- **Docker Desktop or Docker CLI** with `docker sandbox` support
- **Anthropic API key** (required) - Get yours at [console.anthropic.com](https://console.anthropic.com/settings/keys)
- **GitHub Personal Access Token** (optional - for `gh` CLI support)
- **Bash or Zsh shell**

## Usage

### Basic Commands

```bash
claudetainer                        # Run with default prompt (if set)
claudetainer "your prompt"          # Run with specific prompt
claudetainer --set-prompt           # Set default prompt
claudetainer --show-config          # Show current configuration
claudetainer --help                 # Show help message
```

### Examples

```bash
cd ~/your-project
claudetainer "Review the code in this repository"
claudetainer "Help me debug the authentication issue"
claudetainer "Read the .claude instructions and help me"
```

### Setting a Default Prompt

**Interactive (recommended):**
```bash
claudetainer --set-prompt
```

**Environment variable:**
```bash
export CLAUDETAINER_DEFAULT_PROMPT="Read the .claude instructions."
```

**Config file:**
```bash
echo "DEFAULT_PROMPT='Your prompt here'" > ~/.claudetainer/config
```

For advanced configuration options, see **[CONFIGURATION.md](CONFIGURATION.md)**.

## Troubleshooting

For common issues and solutions, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**.

Quick checks:
- Run `claudetainer --show-config` to verify configuration
- Ensure Docker Desktop is running: `docker ps`
- Check installation path: `which claudetainer`
- Update to latest version: `./install.sh --update`

## How It Works

Claudetainer wraps the Docker sandbox command to:
1. Detect your Anthropic API key from multiple environment variable names
2. Detect optional GitHub token for `gh` CLI support
3. Load default prompts from config file or environment
4. Execute: `docker sandbox run claude . -- --allowedTools '*' [prompt]`

The Docker sandbox automatically inherits environment variables and mounts your current directory as the workspace.

## Security

Claude runs in a microVM sandbox with access to **current directory only** (see [Security Model](#security-model) above).

**Best practices:**

- Only run in directories you trust — the workspace is fully accessible to the agent
- Never commit API keys or tokens to version control
- Store credentials in shell config files (`~/.zshrc`, `~/.bashrc`)
- For GitHub tokens, use minimal necessary scopes (`repo`, `read:org`)
- Per-sandbox resource limits (memory/CPU) are not supported; set global limits in [Docker Desktop Settings](https://docs.docker.com/desktop/settings-and-maintenance/settings/)

For details on the isolation architecture, see the [Docker Sandboxes documentation](https://docs.docker.com/ai/sandboxes/architecture/).

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute setup guide
- **[INSTALL.md](INSTALL.md)** - Detailed installation instructions
- **[CONFIGURATION.md](CONFIGURATION.md)** - Advanced configuration options
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development and contribution guide

## Project Structure

```text
claudetainer/
├── claudetainer           # Main executable script
├── install.sh             # Installation automation
├── README.md              # Project overview (this file)
├── QUICKSTART.md          # Quick 5-minute setup
├── INSTALL.md             # Detailed installation
├── CONFIGURATION.md       # Configuration guide
├── TROUBLESHOOTING.md     # Common issues
├── CONTRIBUTING.md        # Development guide
├── config.example         # Example config
└── .gitignore             # Git ignore rules
```

## Contributing

Contributions welcome! See **[CONTRIBUTING.md](CONTRIBUTING.md)** for:

- Development setup (symlink method)
- Testing procedures
- Pull request process
- Code style guidelines

## Features

- ✅ Auto-detects API keys from multiple environment variables
- ✅ Optional GitHub token support for `gh` CLI
- ✅ Default prompt configuration (persistent)
- ✅ Works from any directory
- ✅ Automated installation script
- ✅ Update and uninstall commands
- ✅ Root-compatible permission handling

## References

- [Claude Code Documentation](https://code.claude.com/docs)
- [Docker Sandbox](https://docs.docker.com/desktop/features/sandbox/)
- [Anthropic API Keys](https://console.anthropic.com/settings/keys)

---

**License**: MIT
**Last Updated**: 2026-02-12
