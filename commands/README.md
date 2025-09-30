# Snippet Commands (LLM-Enabled)

This directory contains **LLM-enabled wrapper commands** that provide an intelligent, conversational interface to the `snippets-cli.py` tool.

## Architecture

```
┌─────────────────────────────────────────────┐
│  User (Natural Language Input)              │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│  LLM Wrapper (Claude Intelligence)          │
│  • Parse natural language                   │
│  • Format regex patterns                    │
│  • Resolve file paths                       │
│  • Guide interactively                      │
│  • Format output beautifully                │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│  CLI (snippets-cli.py)                      │
│  • Rigid, testable logic                    │
│  • CRUD operations                          │
│  • JSON output                              │
└─────────────────────────────────────────────┘
```

## Available Commands

### `/snippets/create-snippet` - Create New Snippet
**Purpose**: Intelligently create a new snippet with guided interaction

**Usage**:
```bash
/snippets/create-snippet [name] [pattern] [--file PATH | --content TEXT]
```

**Examples**:
```bash
# Fully guided
/snippets/create-snippet

# With name, will guide through pattern and content
/snippets/create-snippet docker

# Natural language
/snippets/create-snippet docker that matches docker or container

# Expert mode with flags
/snippets/create-snippet rust --pattern '\b(rust|cargo)\b' --file ~/rust.md
```

**What the Wrapper Does**:
- Parses natural language to extract name and pattern keywords
- Formats regex patterns intelligently (adds word boundaries, groups alternatives)
- Guides through missing information interactively
- Validates inputs before calling CLI
- Shows beautiful confirmation with details

---

### `/snippets/list-snippets` - List Snippets
**Purpose**: Display snippets in various formats with rich context

**Usage**:
```bash
/snippets/list-snippets [name] [HTML|--format]
```

**Examples**:
```bash
# List all snippets (text table)
/snippets/list-snippets

# Show specific snippet details
/snippets/list-snippets docker

# Interactive HTML table
/snippets/list-snippets HTML

# Show with full content
/snippets/list-snippets --show-content
```

**What the Wrapper Does**:
- Detects desired output format from context
- Creates formatted tables (text, HTML, markdown)
- Adds statistics and insights
- Provides contextual suggestions
- Opens HTML in browser automatically

---

### `/snippets/update-snippet` - Update Snippet
**Purpose**: Modify existing snippets with intelligent pattern merging and previews

**Usage**:
```bash
/snippets/update-snippet <name> [changes]
```

**Examples**:
```bash
# Interactive mode (choose what to update)
/snippets/update-snippet docker

# Add pattern alternatives (natural language)
/snippets/update-snippet docker add compose and dockerfile

# Update content from file
/snippets/update-snippet kubernetes --file ~/k8s-updated.md

# Disable/enable
/snippets/update-snippet HTML --disable

# Rename
/snippets/update-snippet gcal rename to google-calendar
```

**What the Wrapper Does**:
- Shows current state before changes
- Intelligently merges pattern alternatives
- Previews all changes before applying
- Provides undo instructions after changes
- Suggests related terms when adding alternatives

---

### `/snippets/delete-snippet` - Delete Snippet
**Purpose**: Safely delete snippets with automatic backups and recovery info

**Usage**:
```bash
/snippets/delete-snippet <name> [--force]
```

**Examples**:
```bash
# Delete with confirmation
/snippets/delete-snippet docker

# Force delete (skip confirmation)
/snippets/delete-snippet temp --force
```

**What the Wrapper Does**:
- Shows what will be deleted with full details
- Requires explicit confirmation (unless --force)
- Creates automatic backup before deletion
- Provides clear recovery instructions
- Verifies backup success

---

## Direct CLI Usage

For scripts, automation, or when you don't want LLM processing:

```bash
# Direct CLI commands (JSON output)
cd ~/.claude/snippets

# Create
./snippets-cli.py create docker \
  --pattern '\b(docker|container)\b' \
  --file ~/docker.md

# List (JSON)
./snippets-cli.py list --show-stats

# List specific (JSON)
./snippets-cli.py list docker

# Update pattern
./snippets-cli.py update docker \
  --pattern '\b(docker|container|compose)\b'

# Update content
./snippets-cli.py update docker \
  --file ~/new-docker.md

# Delete with backup
./snippets-cli.py delete docker --backup

# Validate
./snippets-cli.py validate

# Test pattern
./snippets-cli.py test docker "working with docker containers"
```

## Key Features

### LLM Wrapper Benefits

✅ **Natural Language Understanding**
- "create docker snippet for docker and containers"
- "add compose to docker"
- "show me all snippets in HTML"

✅ **Intelligent Pattern Formatting**
- User: "docker or container" → `\b(docker|container)\b`
- User: "kubernetes, k8s" → `\b(kubernetes|k8s)\b`
- Automatic word boundaries and grouping

✅ **Interactive Guidance**
- Prompts for missing information
- Provides examples and suggestions
- Shows previews before applying changes

✅ **Multi-Format Output**
- Text tables for terminal
- HTML for rich visualization
- JSON for scripting
- Markdown for documentation

✅ **Safety & Recovery**
- Automatic backups before changes
- Confirmation prompts for destructive operations
- Clear recovery instructions
- Undo guidance

### CLI Tool Benefits

✅ **Testable & Reliable**
- Unit tested core logic
- Predictable behavior
- Structured JSON output
- Clear error codes

✅ **Scriptable**
- Use in bash scripts
- Pipe-friendly JSON
- Exit codes for automation
- No interactive prompts

✅ **Standalone**
- Works outside Claude
- CI/CD integration
- API wrappable
- Composable

## File Structure

```
~/.claude/snippets/
├── snippets-cli.py          # Core CLI tool
├── snippet-injector.py      # Hook (injects snippets)
├── config.json              # Snippet configuration
├── commands/
│   ├── create-snippet.md    # LLM-enabled create wrapper
│   ├── list-snippets.md     # LLM-enabled list wrapper
│   ├── update-snippet.md    # LLM-enabled update wrapper
│   ├── delete-snippet.md    # LLM-enabled delete wrapper
│   ├── README.md            # This file
│   └── archive/             # Old command files
│       ├── create-snippet.md.old
│       ├── read-snippet.md.old
│       ├── update-snippet.md.old
│       └── delete-snippet.md.old
├── snippets/                # Snippet content files
│   ├── docker.md
│   ├── kubernetes.md
│   └── ...
└── backups/                 # Automatic backups
    └── YYYY-MM-DD_HHMMSS_name/
```

## Configuration File

`config.json` structure:

```json
{
  "mappings": [
    {
      "pattern": "\\b(docker|container)\\b",
      "snippet": "snippets/docker.md",
      "enabled": true
    }
  ]
}
```

## Workflow Examples

### Creating a Snippet from Scratch

```
User: /snippets/create-snippet

Claude: "Let's create a new snippet!
         What would you like to name it?"

User: terraform

Claude: "Great! What words should trigger 'terraform'?
         💡 Suggestions: terraform, tf, hcl"

User: terraform, tf, hcl

Claude: "Perfect! Pattern: \b(terraform|tf|hcl)\b
         How should I get the content?
         1. Template  2. File  3. Paste"

User: 2

Claude: "Which file?"

User: ~/terraform-notes.md

Claude: [validates file]
        [executes CLI]
        [shows confirmation]
        "✅ Snippet 'terraform' created!
         Pattern: \b(terraform|tf|hcl)\b
         Alternatives: 3
         File: snippets/terraform.md (2.3 KB)"
```

### Updating a Pattern

```
User: /snippets/update-snippet docker add compose

Claude: [gets current state]
        "Current: \b(docker|container)\b (2)
         New:     \b(docker|container|compose)\b (3)

         Added: compose

         Apply? [y/n]"

User: y

Claude: [executes]
        "✅ Pattern updated! Added 1 alternative."
```

### Viewing Snippets in HTML

```
User: /snippets/list-snippets HTML

Claude: [executes CLI]
        [generates HTML]
        [saves to file]
        [opens browser]
        "📊 Interactive HTML table generated.
         Saved as claude_snippets_list.html"
```

## Development

### Testing the CLI

```bash
cd ~/.claude/snippets

# Run tests
python -m pytest tests/

# Validate config
./snippets-cli.py validate

# Test pattern
./snippets-cli.py test docker "working with docker containers"
```

### Adding New Commands

1. Create new wrapper in `commands/<command-name>.md`
2. Follow the LLM-enabled wrapper pattern
3. Document phases: Parse → Guide → Execute → Format
4. Test with various input styles

## Migration from Old System

Old commands (archived):
- `create-snippet.md.old` - 100+ lines of XML
- `read-snippet.md.old` - Logic embedded in description
- `update-snippet.md.old` - No clear separation
- `delete-snippet.md.old` - Hard to test

New system:
- **CLI**: Testable Python logic (500 lines)
- **Wrappers**: 20-50 lines of intelligent guidance
- **Total**: Better organization, easier maintenance

## Best Practices

### For Users

1. **Use natural language** - Let Claude parse your intent
2. **Check previews** - Review changes before confirming
3. **Keep backups** - Automatic, but verify important snippets
4. **Test patterns** - Use validate or test commands

### For Developers

1. **CLI stays rigid** - Don't add LLM logic here
2. **Wrappers stay flexible** - Use Claude's intelligence
3. **JSON is the contract** - Clear interface between layers
4. **Test the CLI** - Unit tests for core logic
5. **Document wrappers** - Clear examples and flows

## Troubleshooting

### CLI Not Found

```bash
cd ~/.claude/snippets
chmod +x snippets-cli.py
```

### Config Issues

```bash
./snippets-cli.py validate
```

### Pattern Not Matching

```bash
./snippets-cli.py test <name> "<test text>"
```

### Restore from Backup

```bash
ls -lt backups/
cp backups/YYYY-MM-DD_HHMMSS_name/name.md snippets/
./snippets-cli.py create <name> --pattern '...' --file snippets/name.md
```

## Further Reading

- `../README.md` - System overview
- `snippets-cli.py --help` - CLI documentation
- Individual command files for detailed wrapper behavior