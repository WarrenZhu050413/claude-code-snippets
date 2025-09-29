# Snippet CRUD Commands

CRUD-based commands for managing Claude Code snippets.

## Installation

Run the installation script to symlink commands:

```bash
~/.claude/snippets/commands/install-commands.sh
```

This creates symlinks in `~/.claude/commands/snippets/` so commands are accessible via `/snippets/` prefix.

## Available Commands

### Create (C)
**Command:** `/snippets/create-snippet [name] [pattern]`

Create a new snippet interactively with testing and validation.

**Examples:**
```
/snippets/create-snippet
/snippets/create-snippet docker
/snippets/create-snippet docker "\b(docker|container)\b"
```

### Read (R)
**Command:** `/snippets/read-snippet [filter] [--format]`

View all snippets in an interactive HTML table.

**Examples:**
```
/snippets/read-snippet                  # Show all snippets
/snippets/read-snippet mail             # Filter for mail-related
/snippets/read-snippet --json           # JSON output
/snippets/read-snippet --markdown       # Markdown table
```

### Update (U)
**Command:** `/snippets/update-snippet <name> [--pattern|--content|--both]`

Edit existing snippet content and/or regex pattern.

**Examples:**
```
/snippets/update-snippet docker         # Interactive: choose what to edit
/snippets/update-snippet docker --pattern
/snippets/update-snippet docker --content
/snippets/update-snippet docker --both
```

### Delete (D)
**Command:** `/snippets/delete-snippet <name> [--force] [--backup]`

Remove a snippet with confirmation and backup.

**Examples:**
```
/snippets/delete-snippet docker         # With confirmation
/snippets/delete-snippet docker --force # Skip confirmation
/snippets/delete-snippet docker --backup # Keep backup
```

## File Structure

```
~/.claude/snippets/
├── commands/
│   ├── create-snippet.md      # C - Create new snippet
│   ├── read-snippet.md        # R - View all snippets
│   ├── update-snippet.md      # U - Edit snippet
│   ├── delete-snippet.md      # D - Remove snippet
│   ├── install-commands.sh    # Installation script
│   └── README.md              # This file
├── snippets-config.json       # Snippet mappings
├── *.md                       # Snippet files
└── tests/                     # Test files
```

## Command Design

All commands follow the four-section XML structure:
- `<input>` - Parse arguments, read context, build context
- `<workflow>` - Step-by-step execution phases
- `<output>` - Natural language response format
- `<clarification>` - When and how to ask questions

## Maintenance

To update commands after modifications:
```bash
~/.claude/snippets/commands/install-commands.sh
```

Symlinks ensure changes to source files are immediately reflected.