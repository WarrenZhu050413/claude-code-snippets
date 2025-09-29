#!/bin/bash

# Install CRUD snippet commands by symlinking to ~/.claude/commands/snippets/

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
COMMANDS_SOURCE="$HOME/.claude/snippets/commands"
COMMANDS_TARGET="$HOME/.claude/commands/snippets"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Snippet CRUD Commands Installer      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo

# Create target directory if it doesn't exist
mkdir -p "$COMMANDS_TARGET"

# Function to create symlink
create_symlink() {
    local source_file=$1
    local target_file=$2
    local command_name=$3

    if [ -L "$target_file" ]; then
        echo -e "${BLUE}↻${NC} Updating: $command_name"
        rm "$target_file"
    elif [ -f "$target_file" ]; then
        echo -e "${BLUE}⚠${NC}  Backing up existing: $command_name"
        mv "$target_file" "${target_file}.backup"
    else
        echo -e "${GREEN}+${NC} Installing: $command_name"
    fi

    ln -s "$source_file" "$target_file"
}

# Install all CRUD commands
create_symlink "$COMMANDS_SOURCE/create-snippet.md" "$COMMANDS_TARGET/create-snippet.md" "create-snippet"
create_symlink "$COMMANDS_SOURCE/read-snippet.md" "$COMMANDS_TARGET/read-snippet.md" "read-snippet"
create_symlink "$COMMANDS_SOURCE/update-snippet.md" "$COMMANDS_TARGET/update-snippet.md" "update-snippet"
create_symlink "$COMMANDS_SOURCE/delete-snippet.md" "$COMMANDS_TARGET/delete-snippet.md" "delete-snippet"

echo
echo -e "${GREEN}✅ Installation complete!${NC}"
echo
echo -e "${BLUE}Available commands:${NC}"
echo "  /snippets/create-snippet   - Create a new snippet"
echo "  /snippets/read-snippet     - View all snippets (HTML)"
echo "  /snippets/update-snippet   - Edit existing snippet"
echo "  /snippets/delete-snippet   - Remove a snippet"
echo
echo -e "${BLUE}Example usage:${NC}"
echo "  /snippets/read-snippet"
echo "  /snippets/update-snippet docker"
echo "  /snippets/delete-snippet docker"