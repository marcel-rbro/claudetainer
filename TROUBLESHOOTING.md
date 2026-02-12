# Troubleshooting Guide

Common issues and solutions for claudetainer.

## Installation Issues

### "ANTHROPIC_API_KEY environment variable is not set"

**Cause**: No API key found in any of the supported environment variables.

**Solution**: Add to your shell config:

```bash
echo "export ANTHROPIC_API_KEY='your-api-key-here'" >> ~/.zshrc
source ~/.zshrc
```

### "docker command not found"

**Cause**: Docker is not installed or not in PATH.

**Solution**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) for macOS.

### "claudetainer: command not found"

**Cause**: Script not in PATH or symlink broken.

**Solution**:

```bash
# Check where it's installed
which claudetainer

# If nothing found, reinstall:
cd /path/to/claudetainer
./install.sh --update
```

### "Permission denied" when running claudetainer

**Cause**: Script is not executable.

**Solution**:

```bash
chmod +x /path/to/claudetainer/claudetainer
```

## Runtime Issues

### "unknown option '--skip-config'"

**Cause**: Using an old version of claudetainer.

**Solution**: Update claudetainer:

```bash
cd /path/to/claudetainer
git pull
./install.sh --update
```

### Script exits immediately with no output

**Possible causes and solutions:**

1. **Old version in PATH**: Check which version is being used:
   ```bash
   which claudetainer
   # Should point to your installation
   ```

2. **Missing API key**: Run `claudetainer --show-config` to verify API key is detected

3. **Docker not running**: Ensure Docker Desktop is running:
   ```bash
   docker ps
   ```

### claudetainer works with `./claudetainer` but not `claudetainer`

**Cause**: The version in your PATH is outdated or different from the project version.

**Solution**: Update the installed version:

```bash
# Find where it's installed
which claudetainer

# Re-install
cd /path/to/claudetainer
git pull
./install.sh --update
```

### GitHub token not detected

**Cause**: Environment variable not set in current shell session.

**Solution**:

1. Verify token is in shell config:
   ```bash
   cat ~/.zshrc | grep GH_TOKEN
   ```

2. Source the config:
   ```bash
   source ~/.zshrc
   ```

3. Verify it's set:
   ```bash
   claudetainer --show-config
   ```

## Docker Issues

### "error: unknown option" from docker sandbox

**Cause**: Docker sandbox doesn't recognize a flag we're passing.

**Solution**: Make sure you're using the latest version of claudetainer:

```bash
cd /path/to/claudetainer
git pull
./install.sh --update
```

### Docker permission errors

**Cause**: Docker daemon not running or permission issues.

**Solution**:

```bash
# Check Docker is running
docker ps

# If not, start Docker Desktop

# Test docker sandbox
docker sandbox run --help
```

### "agent exited with code 1"

**Cause**: Claude CLI encountered an error, often due to invalid flags.

**Solution**:

1. Check you're running the latest version
2. Verify your API key is valid:
   ```bash
   claudetainer --show-config
   ```

## Configuration Issues

### Default prompt not working

**Possible causes:**

1. **Not set in environment**: Check with `claudetainer --show-config`
2. **Wrong config file location**: Should be `~/.claudetainer/config`
3. **Syntax error in config**: Make sure it follows bash syntax

**Solution**:

```bash
# Use interactive setup
claudetainer --set-prompt

# Or set via environment
echo 'export CLAUDETAINER_DEFAULT_PROMPT="Your prompt"' >> ~/.zshrc
source ~/.zshrc
```

### Changes to shell config not taking effect

**Cause**: Shell config hasn't been reloaded.

**Solution**:

```bash
# Reload your shell config
source ~/.zshrc  # or ~/.bashrc

# Or restart your terminal
```

### Config file changes ignored

**Cause**: Environment variable takes precedence over config file.

**Solution**: Unset the environment variable if you want to use config file:

```bash
unset CLAUDETAINER_DEFAULT_PROMPT
```

Priority order:
1. Command line argument (highest)
2. Environment variable
3. Config file (lowest)

## Container-Specific Issues

### Claude crashes immediately (SIGKILL)

**Cause**: This shouldn't happen with current version, but if it does, it's usually a Docker resource issue.

**Solution**:

1. Check Docker has enough resources (Settings → Resources)
2. Restart Docker Desktop
3. Check system memory availability

### "--dangerously-skip-permissions cannot be used with root"

**Cause**: Using an old version of claudetainer that used the wrong permission flag.

**Solution**: Update to latest version:

```bash
cd /path/to/claudetainer
git pull
./install.sh --update
```

Current version uses `--allowedTools '*'` instead, which works with root.

## Getting Help

If you still have issues after trying these solutions:

1. Check `claudetainer --show-config` for configuration status
2. Run with `./claudetainer` directly to rule out PATH issues
3. Check Docker Desktop is running and healthy
4. Verify your API key is valid at <https://console.anthropic.com/settings/keys>
5. Report issues at: <https://github.com/marcel-rbro/claudetainer/issues>

When reporting issues, include:
- Output of `claudetainer --show-config`
- Output of `which claudetainer`
- Any error messages
- Your operating system
- Docker version: `docker --version`
