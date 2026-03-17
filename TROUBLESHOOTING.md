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

### git clone / git fetch fails inside the sandbox

**Cause**: The Docker sandbox routes HTTPS traffic through a filtering proxy at `host.docker.internal:3128`. This proxy corrupts git's binary pack protocol, breaking `git clone`, `git fetch`, and `git pull`.

**Symptoms** (observed across 7 attempts, 4 distinct error patterns):

1. `inflate: data stream error (unknown compression method)` + `fatal: serious inflate inconsistency` — most common; returned by default, depth-limited, and HTTP/1.1 clones
2. `unknown object type 0 at offset ...` / `fatal: bad tree object` — partial data gets through but is corrupted (seen after adding the proxy CA cert)
3. `fatal: 'origin' does not appear to be a git repository` — proxy blocks smart-HTTP negotiation entirely (seen with `GIT_HTTP_NO_COMPRESS=1` and `--filter=blob:none`)
4. `fatal: bad config line 6` — proxy writes garbage into `.git/config`

**Workaround** — download a tar.gz archive instead of cloning:

```bash
curl -L https://github.com/<org>/<repo>/archive/refs/heads/<branch>.tar.gz | tar xz
```

This bypasses git's pack protocol entirely and works reliably through the proxy.

**Alternative** — the `gh` CLI may work if `GH_TOKEN` is configured in the sandbox environment:

```bash
gh repo clone <org>/<repo>
```

**Note**: This is a Docker Desktop sandbox limitation, not a claudetainer bug. The proxy is part of the sandbox's network isolation layer and cannot be bypassed or reconfigured.

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
