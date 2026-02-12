# Installation Guide

Complete installation instructions for claudetainer.

## Quick Installation

See [QUICKSTART.md](QUICKSTART.md) for the fastest way to get started.

## Installation Methods

### Method 1: Automated Installation (Recommended)

Use the included install script:

```bash
git clone https://github.com/marcel-rbro/claudetainer.git
cd claudetainer

# Basic installation
./install.sh --api-key "sk-ant-api03-your-key-here"

# With all options
./install.sh \
  --api-key "sk-ant-api03-..." \
  --github-token "ghp_..." \
  --default-prompt "Read the .claude instructions."
```

The install script will:
- Install claudetainer to /usr/local/bin
- Configure your shell environment automatically
- Set up default prompt (if provided)
- Test the installation
- Create backups before modifying files

### Method 2: Manual Installation

#### Step 1: Get API Keys

**Required**: Get your Anthropic API key from <https://console.anthropic.com/settings/keys>

**Optional**: Get a GitHub token for gh CLI support from <https://github.com/settings/tokens>

#### Step 2: Configure Shell Environment

Add to `~/.zshrc` (or `~/.bashrc` for Bash):

```bash
# Required: Anthropic API Key
export ANTHROPIC_API_KEY='sk-ant-api03-your-key-here'

# Optional: GitHub Token (for gh CLI support)
export GH_TOKEN='ghp_your-token-here'

# Optional: Default prompt
export CLAUDETAINER_DEFAULT_PROMPT='Read the .claude instructions.'
```

Apply changes:

```bash
source ~/.zshrc
```

#### Step 3: Install Binary

**For most users:**

```bash
cd /path/to/claudetainer
chmod +x claudetainer
cp claudetainer /usr/local/bin/claudetainer
```

**For contributors (symlink method):**

```bash
mkdir -p ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
cd /path/to/claudetainer
ln -s "$(pwd)/claudetainer" ~/.local/bin/claudetainer
```

Benefits of symlink:
- Auto-updates when you `git pull`
- Useful when developing or testing changes
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup

## Updating

### Using Install Script

```bash
cd /path/to/claudetainer
git pull
./install.sh --update
```

### Manual Update

```bash
cd /path/to/claudetainer
git pull
cp claudetainer /usr/local/bin/claudetainer
```

## Uninstalling

### Remove Binary Only

```bash
./install.sh --uninstall
```

This removes claudetainer but preserves your configuration.

### Complete Removal

```bash
./install.sh --uninstall --remove-config
```

This removes:
- claudetainer binary
- Shell configuration
- ~/.claudetainer directory

## Verification

After installation, verify it works:

```bash
# Check version
claudetainer --help

# Check configuration
claudetainer --show-config

# Test in a project
cd ~/your-project
claudetainer "Hello, can you see this project?"
```

## Installation Locations

### Default Location

`/usr/local/bin/claudetainer`

This is usually in your PATH by default on macOS and Linux.

### Custom Location

Use the `--path` flag with install script:

```bash
./install.sh --api-key "..." --path ~/.local/bin
```

Make sure your custom path is in your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Requirements

- **Docker Desktop or Docker CLI** with `docker sandbox` support
- **Anthropic API key** (required)
- **GitHub Personal Access Token** (optional - for `gh` CLI support)
- **Bash or Zsh shell**
- **macOS or Linux** (Windows via WSL may work but untested)

## Next Steps

- Read [QUICKSTART.md](QUICKSTART.md) for basic usage
- See [CONFIGURATION.md](CONFIGURATION.md) for advanced configuration
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if you encounter issues
