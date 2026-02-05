# Claudetainer Troubleshooting

## Known Issues

### Claude `-p` (print) mode produces no output

**Status:** Unresolved

**Symptoms:**
- `claudetainer "prompt"` returns immediately with no output
- Exit code: 0 (success)
- No errors displayed
- Settings and API key configured correctly

**Debug logs show** (fixed):
- ~~Permission errors writing to HOME directory~~ FIXED in entrypoint.sh
- Claude runs successfully but produces no output

**Related GitHub Issues:**
- [#7263](https://github.com/anthropics/claude-code/issues/7263) - Empty output with large stdin (closed as "not planned")
- [#13747](https://github.com/anthropics/claude-code/issues/13747) - Container exits after shell commands
- [#16135](https://github.com/anthropics/claude-code/issues/16135) - Process termination in Docker

**Attempted Workarounds:**
1. ✗ File-based approach (write prompt to file) - still no output
2. ✗ `--output-format stream-json` - still no output
3. ✗ Bypassing entrypoint - still no output
4. ✓ Fixed HOME directory permissions - error gone but still no output

**Current Theory:**
Claude Code's `-p` (print) mode may have issues in Docker containers with:
- User ID mapping (`--user` flag)
- npm installation method
- Non-interactive terminal environment

**Infrastructure Status:**
All configuration is correct:
- ✅ Docker image builds
- ✅ API key saved properly
- ✅ Permissions configured
- ✅ Settings.json created
- ✅ Volume mounts work
- ✅ Container executes (exit code 0)

**Next Steps:**
- Create GitHub issue with full reproduction steps
- Test with official Claude installer (not npm)
- Try interactive mode instead of print mode
- Test on native Linux (not macOS with Docker)

## Fixed Issues

### 1. API Key Not Substituted in settings.json
**Fixed:** Changed heredoc from `<<'EOF'` to `<<EOF` to allow variable expansion

### 2. Permission Denied on Git Config
**Fixed:** Set `HOME=/tmp/home` with chmod 777 permissions

### 3. macOS Binary Incompatibility
**Fixed:** Switched from copying macOS binary to npm installation (`@anthropic-ai/claude-code`)

### 4. Missing `--dangerously-skip-permissions` Alternative
**Fixed:** Using `--permission-mode=bypassPermissions`

## Debug Commands

```bash
# Check Claude settings
cat ~/.claude/settings.json

# Check debug logs
ls -la ~/.claude/debug/
cat ~/.claude/debug/latest

# Test Docker image directly
docker run --rm claudetainer:latest claude --version

# Test with API key
docker run --rm \
  -e "ANTHROPIC_API_KEY=sk-ant-..." \
  claudetainer:latest \
  -p "hello"
```

## Environment Details

- **Claude Version:** 2.1.31
- **Installation Method:** npm (`@anthropic-ai/claude-code`)
- **Base Image:** node:20-slim
- **Docker:** 29.2.0
- **Platform:** macOS (arm64) with Docker Desktop
