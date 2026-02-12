# Quickstart Guide

Get up and running with claudetainer in 5 minutes.

## Prerequisites

- macOS (or Linux with appropriate adjustments)
- Docker Desktop installed and running
- Bash or Zsh shell

## Installation

### 1. Get API Keys

**Required**: Get your Anthropic API key from <https://console.anthropic.com/settings/keys>

**Optional**: Get a GitHub token for gh CLI support from <https://github.com/settings/tokens>

### 2. Configure Your Shell

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

### 3. Install Claudetainer

```bash
# Download or clone the claudetainer repo
cd /path/to/claudetainer

# Make executable
chmod +x claudetainer

# Copy to PATH
cp claudetainer /usr/local/bin/claudetainer
```

That's it! The script is now available globally.

### 4. Verify Installation

```bash
# Check it works
claudetainer --help

# Check configuration
claudetainer --show-config
```

Expected output:

```text
Anthropic API Key:
  ✓ ANTHROPIC_API_KEY is set

GitHub Token (for gh CLI):
  ✓ GH_TOKEN is set (if you configured it)

Default Prompt:
  Value: Read the .claude instructions. (if you configured it)
```

### 5. Use It!

```bash
cd ~/your-project
claudetainer "Review this code"
```

## Common Usage

```bash
# Use default prompt (if configured)
claudetainer

# Provide specific prompt
claudetainer "Review this codebase for security issues"

# Use with GitHub CLI
claudetainer "List open PRs using gh pr list"

# Set default prompt interactively
claudetainer --set-prompt
```

## Updating

To update to the latest version:

```bash
cd /path/to/claudetainer
git pull
cp claudetainer /usr/local/bin/claudetainer
```

## Troubleshooting

### "claudetainer: command not found"

```bash
# Check if it's installed
which claudetainer

# If not found, reinstall:
cd /path/to/claudetainer
cp claudetainer /usr/local/bin/claudetainer
```

### "ANTHROPIC_API_KEY not set"

```bash
# Add to shell config
echo "export ANTHROPIC_API_KEY='your-key'" >> ~/.zshrc
source ~/.zshrc

# Verify
claudetainer --show-config
```

### "error: unknown option '--skip-config'"

You have an old version. Update it:

```bash
cd /path/to/claudetainer
git pull
cp claudetainer /usr/local/bin/claudetainer
```

### "Permission denied"

```bash
chmod +x /path/to/claudetainer/claudetainer
```

## Full Example Shell Config

Complete `~/.zshrc` example:

```bash
# Claudetainer setup
export ANTHROPIC_API_KEY='sk-ant-api03-...'
export GH_TOKEN='ghp_...'
export CLAUDETAINER_DEFAULT_PROMPT='Read the .claude instructions.'

# Optional: Convenient aliases
alias claude-review='claudetainer "Review this code"'
alias claude-docs='claudetainer "Update documentation"'
```

## Next Steps

- Read the full [README.md](README.md) for advanced configuration
- Set up `.claude/` directories in your projects with guidelines
- Try it on a test project first

---

**Need help?** Check `claudetainer --help` or read the full README.md

**Contributing?** See the README.md for developer setup with symlinks.
