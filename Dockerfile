# Claudetainer - Dockerized Claude Code
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Claude binary from staging directory
COPY tmp/claude /usr/local/bin/claude
RUN chmod +x /usr/local/bin/claude

# Create Claude config directory
RUN mkdir -p /root/.claude

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /workspace

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
