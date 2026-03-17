# Project Instructions

## Sandbox Limitations

`git clone`, `git fetch`, and `git pull` do not work inside the Docker sandbox. The HTTPS filtering proxy at `host.docker.internal:3128` corrupts git's binary pack protocol.

**Workaround** — download tar.gz archives instead:

```bash
curl -L https://github.com/<org>/<repo>/archive/refs/heads/<branch>.tar.gz | tar xz
```

**Alternative** — if `GH_TOKEN` is configured:

```bash
gh repo clone <org>/<repo>
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#git-clone--git-fetch-fails-inside-the-sandbox) for details.
