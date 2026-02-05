# Claudetainer - Dockerized Claude Code using Node.js
FROM node:20-slim

# Install required dependencies
RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally via npm
RUN npm install -g @anthropic-ai/claude-code@latest

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /workspace

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
