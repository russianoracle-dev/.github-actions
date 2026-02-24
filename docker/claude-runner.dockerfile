FROM ubuntu:22.04

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# System dependencies required by Claude Code installer
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    nodejs \
    npm \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv (needed for serena MCP server via uvx)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Claude Code (official installer)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install plugin marketplaces
RUN claude plugin marketplace add https://github.com/obra/superpowers-marketplace.git \
 && claude plugin marketplace add https://github.com/anthropics/claude-plugins-official.git

# Install plugins
RUN claude plugin install superpowers@superpowers-marketplace \
 && claude plugin install feature-dev@claude-plugins-official \
 && claude plugin install serena@claude-plugins-official

# Verify installation
RUN claude --version \
 && uv --version \
 && uvx --version \
 && ls -la /root/.claude/plugins/ || echo "plugins dir check done"

# Default: print version info
CMD ["claude", "--version"]
