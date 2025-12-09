# Claude MCP Setup Documentation

**Purpose:** Replicate Claude Desktop MCP configuration across multiple machines (Intel MacBook, Apple Silicon Mac Mini, and future devices)

**Owner:** Walt (65, IT/WebDev manager since mid-90s)

**Last Updated:** December 9, 2024

---

## Overview

This setup bridges three key platforms:
- **WordPress.com** - CMS for human-readable content
- **GitHub** - Repository for AI-readable documentation (80% markdown, 20% code)
- **Claude Desktop** - AI assistant with MCP access to both platforms

The goal is to use MCP as an extended "file system" that bridges AI's limited context window with extensive, current, relevant data.

---

## Current Configuration

### Prerequisites

Both machines need:
- **Node.js and npm** (for running MCP servers via npx)
- **Claude Desktop** installed
- **GitHub Personal Access Token** (for GitHub MCP)
- **WordPress.com account** (authenticated via OAuth)

### MCP Servers Configured

#### 1. WordPress.com MCP Server
- **Package:** `@automattic/mcp-wpcom-remote@latest`
- **Authentication:** OAuth (browser-based, first run)
- **Access:** Remote connection to WordPress.com sites

#### 2. GitHub MCP Server  
- **Package:** `@modelcontextprotocol/server-github`
- **Authentication:** Personal Access Token (PAT)
- **Mode:** Remote (GitHub API, not local repos)

---

## Setup Instructions for New Machine

### Step 1: Install Node.js (if not already installed)

**For Intel Mac:**
```bash
# Check if already installed
node --version
npm --version

# If not installed, use Homebrew
brew install node
```

**For Apple Silicon Mac:**
```bash
# Same as Intel - Homebrew handles architecture
brew install node
```

### Step 2: Get GitHub Personal Access Token

You'll need to create a new token for each machine (or use a shared token - see Security Considerations below).

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Set expiration (recommend 90 days, with calendar reminder to regenerate)
4. Select scopes:
   - `repo` (all repo access)
   - `read:org` (if you work with org repos)
   - `read:user` (user profile info)
5. Generate and **copy the token immediately** (you can't see it again)

### Step 3: Configure Claude Desktop

Create/edit the configuration file:

```bash
# Open the config file in your preferred editor
code ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Or use nano if you prefer
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Paste this configuration (replace `YOUR_GITHUB_TOKEN_HERE` with your actual token):

```json
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
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE",
        "GITHUB_MCP_SERVER_MODE": "remote"
      }
    }
  }
}
```

### Step 4: Restart Claude Desktop

1. Quit Claude Desktop completely (Cmd+Q)
2. Reopen Claude Desktop
3. First time running, WordPress MCP will prompt for OAuth authentication in your browser
4. GitHub MCP should work immediately with the token

### Step 5: Verify Setup

In a new Claude chat, test both connections:

```
For WordPress: "List my WordPress.com sites"
For GitHub: "List my GitHub repositories"
```

---

## Differences Between Intel and Apple Silicon

**Good news:** None! 

The `npx` approach downloads the appropriate binaries for each architecture automatically. Both machines use identical configuration.

---

## Security Considerations

### GitHub Token Storage

**Current approach:** Token stored in plain text in config file

**Security implications:**
- Anyone with access to your Mac can read this token
- Token has full repo access
- If token is compromised, revoke it immediately at GitHub settings

**Better approach (optional):**
- Use environment variables instead of hardcoding token
- Store token in macOS Keychain
- Use different tokens per machine (easier to track/revoke)

**To use environment variable instead:**

1. Add to your `~/.zshrc`:
   ```bash
   export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"
   ```

2. Modify config to reference it:
   ```json
   "env": {
     "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}",
     "GITHUB_MCP_SERVER_MODE": "remote"
   }
   ```

---

## Troubleshooting

### MCP Servers Not Showing Up

1. Check Node.js is installed: `node --version`
2. Check config file syntax (valid JSON)
3. Restart Claude Desktop completely
4. Check Console.app for Claude errors

### GitHub Connection Fails

1. Verify token is valid at https://github.com/settings/tokens
2. Check token has correct scopes (repo, read:org, read:user)
3. Ensure token hasn't expired
4. Test token manually:
   ```bash
   curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
   ```

### WordPress Connection Fails

1. Clear browser cache and try OAuth flow again
2. Check you're logged into WordPress.com in your browser
3. Ensure you have sites associated with your account

### npx Fails or Hangs

1. Clear npm cache: `npm cache clean --force`
2. Check internet connection
3. Try running manually: `npx -y @modelcontextprotocol/server-github`

---

## File Locations Reference

| Item | Path |
|------|------|
| Claude config | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| MCP cache (temp) | `~/.npm/_npx/` |
| Node.js | `/usr/local/bin/node` (Intel) or `/opt/homebrew/bin/node` (Apple Silicon) |

---

## Next Steps

### Immediate
- [ ] Replicate setup on Mac Mini
- [ ] Test both MCP connections on Mac Mini
- [ ] Document any additional steps needed

### Future Enhancements
- [ ] Create automation script for setup
- [ ] Build custom MCP server to capture Claude Desktop outputs
- [ ] Implement secure token management via Keychain
- [ ] Add iPad/iPhone access strategy

---

## Notes

- Both MCP servers use `npx -y` which means they run on-demand, no permanent installation
- Configuration is identical across Intel and Apple Silicon
- Only the GitHub token needs to be kept secret/secure
- WordPress OAuth is machine-specific (need to authenticate on each device)