# Quick Start: Setting Up Mac Mini

**When you're sitting at your Mac Mini and ready to replicate the setup:**

## Option 1: Automated Setup (Recommended)

```bash
# 1. Clone this repository
git clone https://github.com/ludwa6/claude-mcp-setup.git
cd claude-mcp-setup

# 2. Run the setup script
./setup.sh
```

The script will:
- Check that Node.js is installed (install if needed)
- Prompt you for your GitHub token
- Create the Claude Desktop config file
- Back up any existing config

Then just restart Claude Desktop and you're done!

---

## Option 2: Manual Setup

If you prefer to do it manually or the script doesn't work:

### 1. Ensure Node.js is installed

```bash
node --version
npm --version
```

If not installed:
```bash
brew install node
```

### 2. Create GitHub Personal Access Token

Go to: https://github.com/settings/tokens

Create new token with scopes:
- `repo` (full repo access)
- `read:org` (if needed)
- `read:user` (user profile)

Copy the token (starts with `ghp_`)

### 3. Create Claude Desktop Config

```bash
# Edit the config file
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Paste this (replace YOUR_TOKEN with your actual GitHub token):

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
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_TOKEN",
        "GITHUB_MCP_SERVER_MODE": "remote"
      }
    }
  }
}
```

Save and exit (Ctrl+O, Enter, Ctrl+X in nano)

### 4. Restart Claude Desktop

Quit completely (Cmd+Q) and reopen

### 5. Authenticate WordPress

First time you use WordPress commands, you'll be prompted to log in via browser

---

## Testing the Setup

In Claude Desktop, try these commands:

```
List my WordPress.com sites
```

```
List my GitHub repositories
```

If both work, you're all set! 🎉

---

## Troubleshooting

**Can't find config directory:**
- Make sure Claude Desktop is installed
- Path should be: `~/Library/Application Support/Claude/`

**Node.js not found:**
```bash
brew install node
```

**GitHub connection fails:**
- Verify token at https://github.com/settings/tokens
- Check token has `repo` scope
- Ensure token hasn't expired

**WordPress connection fails:**
- Clear browser cache
- Make sure you're logged into WordPress.com
- Try the OAuth flow again

---

## What's Different on Mac Mini?

**Answer: Nothing!** 

The configuration is identical. Both Intel and Apple Silicon Macs use the same setup. The only machine-specific things are:

1. WordPress OAuth (need to authenticate once per machine)
2. GitHub token (can reuse same token or create new one per machine)

---

## Security Note

Your GitHub token is stored in plain text in the config file. This is convenient but has security implications:

- Anyone with access to your Mac can read it
- Don't share your config file
- Consider using environment variables instead (see README.md)
- Can revoke/regenerate token anytime at GitHub settings

---

## After Setup: Next Steps

Once both machines are configured:

1. Both can access same WordPress content ✅
2. Both can access same GitHub repos ✅
3. Still need to sync: Claude Desktop chats and artifacts between machines ⏳

For that next step, see the main README.md for the complete workflow plan.