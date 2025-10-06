# Claude Snippets

Claude Snippets is created to enable precise context control for Claude Code. I think slash commands are helpful. However, it is currently impossible to pull in snippets from different commands together for Claude Code. This is why Claude Snippets is created. I hope it is helpful!

## Setup Instructions

### Prerequisites
- Claude Code CLI installed
- Python 3.x
- `gh` CLI (for GitHub operations, optional)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/WarrenZhu050413/claude-code-snippets.git ~/.claude/snippets
   ```

2. **Install the CRUD commands:**
   ```bash
   cd ~/.claude/snippets
   ./commands/install-commands.sh
   ```

   This creates symlinks in `~/.claude/commands/snippets/` making the commands available via the `/snippets/` prefix.

3. **Configure Claude Code to use the snippet injector:**

   Add this to your Claude Code configuration (typically `~/.claude/config.json` or project-level `.claude/config.json`):

   ```json
   {
     "hooks": {
       "userPromptSubmit": {
         "command": "python3 ~/.claude/snippets/snippet-injector.py"
       }
     }
   }
   ```

   This enables automatic snippet injection based on regex patterns in your prompts.

4. **Verify installation:**
   ```bash
   # Run all tests
   cd ~/.claude/snippets/tests
   ./run_all_tests.sh

   # View your snippets
   /snippets/read-snippet
   ```

### How It Works

1. **Snippet Injection**: When you type a prompt, the `snippet-injector.py` hook scans for regex patterns defined in `snippets-config.json`
2. **Pattern Matching**: If a pattern matches (e.g., "email", "HTML", "codex"), the corresponding snippet is automatically injected into your prompt
3. **Context Control**: This allows you to pull in multiple snippets from different commands together, giving you precise context control

### Example Usage

```bash
# Typing: "Help me send an email about docker containers"
# Automatically injects: mail.md snippet (matches "email")

# Typing: "Search for HTML templates using codex"
# Automatically injects: HTML.md + codex.md snippets (matches both patterns)
```

### Directory Structure

```
~/.claude/snippets/
├── commands/               # CRUD command definitions
│   ├── create-snippet.md  # Create new snippets
│   ├── read-snippet.md    # View all snippets (HTML)
│   ├── update-snippet.md  # Edit existing snippets
│   └── delete-snippet.md  # Remove snippets
├── snippets-config.json   # Pattern → snippet mappings
├── *.md                   # Snippet files
├── snippet-injector.py    # Hook script for injection
├── tests/                 # Test suite
└── install.sh             # Legacy installer
```

### Managing Snippets

Use the CRUD commands to manage your snippets:

```bash
# Create a single-file snippet
/snippets/create-snippet docker "\b(docker|container)\b"

# View all snippets in interactive HTML
/snippets/read-snippet

# Update an existing snippet
/snippets/update-snippet docker --pattern

# Delete a snippet
/snippets/delete-snippet docker
```

### Multi-File Snippets

Snippets can now reference multiple files that are concatenated when injected:

```bash
# Create a multi-file snippet using CLI
python3 ~/.claude/snippets/snippets_cli.py create mysnippet \
  --pattern '\b(mysnippet)\b' \
  --files snippets/part1.md snippets/part2.md \
  --separator '\n\n---\n\n'

# Or manually edit config.json
{
  "name": "mysnippet",
  "pattern": "\\b(mysnippet)\\b",
  "snippet": [
    "snippets/part1.md",
    "snippets/part2.md"
  ],
  "separator": "\n\n---\n\n",
  "enabled": true
}
```

**Features:**
- All snippets now use array format: `"snippet": ["file.md"]`
- Multiple files are concatenated with a configurable separator (default: `\n`)
- Backward compatible with single-file snippets
- Custom separators allow for visual breaks between files

See `commands/README.md` for detailed command documentation.
