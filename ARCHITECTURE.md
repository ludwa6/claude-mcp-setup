# MCP Architecture Explained

**For:** Someone who's "just a monkey following commands" but wants to understand what's really happening

**Analogy:** Think of this like your firmware (training data) vs RAM (context window) analogy - but extended with external hard drives that Claude can access on-demand.

---

## The Big Picture

```
┌─────────────────────────────────────────────────────────────┐
│  YOU (Walt)                                                  │
│  ↓                                                           │
│  Claude Desktop (Your Mac)                                   │
│      ├── Built-in Knowledge (Training Data = "Firmware")    │
│      ├── Context Window (Current Chat = "RAM")              │
│      └── MCP Servers (Extended Access = "External Drives")  │
│           ├── WordPress MCP → Your WordPress.com Sites      │
│           └── GitHub MCP → Your GitHub Repositories         │
└─────────────────────────────────────────────────────────────┘
```

---

## What is MCP? (Model Context Protocol)

**Simple explanation:** A standardized way for AI assistants to access external data sources.

**Before MCP:** Claude could only work with:
- What it learned in training (frozen in time)
- What you paste into the chat (limited by context window)

**With MCP:** Claude can now:
- Read your WordPress posts/pages
- Browse your GitHub repositories  
- Access data that's too large for the context window
- Get current information (not frozen in training)

**The key:** Claude accesses this data *on-demand* only when needed, not loading everything at once.

---

## How Your Setup Works

### Component 1: npx (Node Package Execute)

**What it is:** A tool that comes with Node.js that runs JavaScript packages without installing them permanently.

**Why you're using it:** 
- MCP servers are JavaScript programs
- `npx -y` downloads and runs them on-demand
- No permanent installation needed = easier to keep in sync across machines

**The `-y` flag:** Means "yes, automatically use the package without asking me"

**Analogy:** Like streaming a movie vs downloading it. You use the software when needed, but don't store it permanently.

### Component 2: WordPress MCP Server

**Package name:** `@automattic/mcp-wpcom-remote@latest`

**What it does:**
1. Connects to WordPress.com API
2. Authenticates you via OAuth (browser login)
3. Gives Claude read/write access to your WordPress sites
4. Can list posts, pages, users, comments, etc.

**How authentication works:**
- First run: Opens browser, you log into WordPress.com
- WordPress gives Claude a special "token" (permission slip)
- Token stored securely by the MCP server
- Future runs: Uses stored token, no login needed

**Remote vs Local:** This is "remote" meaning it talks to WordPress.com servers over the internet, not local WordPress files on your Mac.

### Component 3: GitHub MCP Server

**Package name:** `@modelcontextprotocol/server-github`

**What it does:**
1. Connects to GitHub API
2. Uses your Personal Access Token (PAT) for authentication
3. Gives Claude read/write access to your repositories
4. Can browse code, read files, search repos, create issues, etc.

**How authentication works:**
- You create a PAT at GitHub (like a password, but limited in scope)
- PAT stored in config file (in plain text - which is a security consideration)
- GitHub checks the PAT on every request
- PAT can be revoked anytime at GitHub settings

**Remote mode:** The `GITHUB_MCP_SERVER_MODE: "remote"` setting means:
- Talks to GitHub.com API over internet
- Does NOT use local git repositories on your Mac
- Can access any repo you have permission to see on GitHub

---

## The Configuration File Explained

Location: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    // ^ This tells Claude Desktop: "Here are external data sources you can use"
    
    "wpcom": {
      // ^ Name for this MCP server (you can call it anything)
      
      "command": "npx",
      // ^ The program to run
      
      "args": ["-y", "@automattic/mcp-wpcom-remote@latest"]
      // ^ Arguments passed to npx:
      //   -y = don't ask for confirmation
      //   @automattic/mcp-wpcom-remote@latest = package to run (latest version)
    },
    
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      
      "env": {
        // ^ Environment variables (settings) for this MCP server
        
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxx",
        // ^ Your GitHub authentication token
        
        "GITHUB_MCP_SERVER_MODE": "remote"
        // ^ Use GitHub API, not local git repos
      }
    }
  }
}
```

---

## What Happens When Claude Desktop Starts

**Step 1:** Claude Desktop reads `claude_desktop_config.json`

**Step 2:** For each MCP server configured:
1. Runs the `command` with the `args`
2. This launches the MCP server as a separate process
3. The MCP server announces "I can provide these capabilities"

**Step 3:** MCP servers keep running in the background

**Step 4:** When you ask Claude something, it can:
- Answer from built-in knowledge (training data)
- Answer from current chat (context window)
- Ask an MCP server for additional information

---

## Example: What Happens When You Say "List My GitHub Repos"

```
You → Claude Desktop → "List my GitHub repos"

Claude thinks: "I need current GitHub data, not training data"

Claude → GitHub MCP Server → "Hey, get me this user's repositories"

GitHub MCP Server → GitHub.com API → "Here's a token, give me the repos"

GitHub.com API → "Here are the repos"

GitHub MCP Server → Claude → "Here's the data"

Claude → You → "Here are your repositories: [list]"
```

**Key point:** Claude never stores your GitHub data permanently. It asks the MCP server each time, and the server asks GitHub each time. This ensures you always get current data.

---

## Why This Solves Your Problem (Mostly)

**What it solves:**
- ✅ Both machines can access same WordPress content
- ✅ Both machines can access same GitHub repos
- ✅ No need to sync WordPress or GitHub data between machines
- ✅ Configuration is nearly identical (just copy config file)

**What it doesn't solve yet:**
- ❌ Syncing Claude Desktop chat history between machines
- ❌ Syncing artifacts created in Claude Desktop
- ❌ Syncing VS Code workspace/settings between machines

**Next step:** We need to build a system to capture Claude Desktop outputs and save them to GitHub automatically (or semi-automatically). This is the "flow out into directory stack of .md files" you mentioned.

---

## Architecture Advantages

**1. No permanent storage needed**
- `npx` runs on-demand
- MCP servers don't need installation
- Just need Node.js + config file

**2. Always current**
- MCP servers pull latest from npm
- Data pulled fresh from WordPress/GitHub
- No stale caches

**3. Platform independent**
- Works on Intel and Apple Silicon
- Same config on both machines
- Only Node.js needed as prerequisite

**4. Secure(ish)**
- WordPress uses OAuth (no passwords in config)
- GitHub token can be revoked anytime
- MCP servers are sandboxed processes

---

## Security Considerations

**The elephant in the room:** Your GitHub token is in plain text in the config file.

**What this means:**
- Anyone who can read that file can access your GitHub with your permissions
- If your Mac is compromised, so is your GitHub
- If you accidentally share that config, you've shared your token

**Better approaches (for future):**
1. Store token in macOS Keychain, reference it in config
2. Use environment variable instead of hardcoding
3. Create a token with minimal scopes (only what's needed)
4. Set token expiration and rotate regularly

**For now:** Just be aware that config file = sensitive data. Don't commit it to public GitHub repos (that's why I created .gitignore).

---

## What You Should Understand

**You don't need to understand:**
- How JavaScript works
- How npm packages are built
- MCP protocol internals
- OAuth flow details

**You should understand:**
- Config file tells Claude Desktop which external data sources to use
- npx runs MCP servers on-demand (no permanent installation)
- MCP servers authenticate to WordPress/GitHub on your behalf
- Claude asks MCP servers for data only when needed
- Configuration is nearly identical across machines

**Bottom line:** You've created a system where Claude can access your WordPress content and GitHub repos as if they were part of its memory, but without actually loading everything into its limited context window. It's like giving Claude the ability to "look things up" instead of having to "memorize everything."

---

## Next Steps: The Missing Piece

You mentioned wanting Claude Desktop artifacts and commands to flow into VS Code as .md files accessible everywhere.

**This requires:** Building a bridge between Claude Desktop (ephemeral, local) and your Git repository (persistent, synchronized).

**Two approaches:**

1. **Manual but structured:** Export artifacts manually into a Git repo after each session
2. **Automated:** Build a custom MCP server that watches Claude Desktop and auto-saves outputs

Let me know which direction interests you more.