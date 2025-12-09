#!/bin/bash

# Quick Setup Script for Claude MCP Configuration
# Run this on a new Mac to replicate MCP setup

set -e  # Exit on any error

echo "==================================="
echo "Claude MCP Setup Script"
echo "==================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Installing via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install from https://brew.sh"
        exit 1
    fi
    brew install node
else
    echo "✅ Node.js found: $(node --version)"
fi

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. This should have been installed with Node.js"
    exit 1
else
    echo "✅ npm found: $(npm --version)"
fi

# Check Claude Desktop
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
    echo "❌ Claude Desktop config directory not found."
    echo "   Please install Claude Desktop first from https://claude.ai/download"
    exit 1
else
    echo "✅ Claude Desktop directory found"
fi

echo ""
echo "==================================="
echo "Configuration Setup"
echo "==================================="
echo ""

# Get GitHub token
echo "Please enter your GitHub Personal Access Token:"
echo "(Create one at: https://github.com/settings/tokens)"
read -s GITHUB_TOKEN

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ No token provided. Exiting."
    exit 1
fi

# Validate token format (basic check)
if [[ ! $GITHUB_TOKEN =~ ^ghp_ ]]; then
    echo "⚠️  Warning: Token doesn't start with 'ghp_'. Are you sure this is correct?"
    echo "Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create config file
CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"

echo ""
echo "Creating configuration file at:"
echo "$CONFIG_FILE"

# Backup existing config if present
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Existing config found. Backing up to:"
    echo "$BACKUP_FILE"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# Write config
cat > "$CONFIG_FILE" <<EOF
{
  "mcpServers": {
    "wpcom": {
      "command": "npx",
      "args": ["-y", "@automattic/mcp-wpcom-remote@latest"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_TOKEN",
        "GITHUB_MCP_SERVER_MODE": "remote"
      }
    }
  }
}
EOF

echo "✅ Configuration file created"

echo ""
echo "==================================="
echo "Next Steps"
echo "==================================="
echo ""
echo "1. Restart Claude Desktop (Cmd+Q, then reopen)"
echo "2. WordPress MCP will prompt for OAuth authentication in browser"
echo "3. Test connections with:"
echo "   - 'List my WordPress.com sites'"
echo "   - 'List my GitHub repositories'"
echo ""
echo "Setup complete! 🎉"
