# Delete Snippet Command

<input>
## Parse Arguments
Process $ARGUMENTS to extract:
- Snippet name (required)
- Optional flags: --force (skip confirmation), --backup (keep backup)

## Example Inputs
- `/snippets/delete-snippet docker` (interactive with confirmation)
- `/snippets/delete-snippet docker --force` (delete without confirmation)
- `/snippets/delete-snippet docker --backup` (keep backup files)

## Read Context
Read snippet information before deletion:
- ~/.claude/snippets/snippets-config.json (current pattern)
- ~/.claude/snippets/{name}.md (snippet file)
- ~/.claude/snippets/tests/test_{name}.sh (test file)

## Build Context
- Verify snippet exists
- List all files that will be deleted
- Show current configuration entry
</input>

<workflow>
## Phase 1: Validate Snippet Exists
Check if snippet exists:
- Verify snippet file exists
- Check if pattern entry exists in config
- Find associated test file

## Phase 2: Show What Will Be Deleted
Display information:
- Snippet file path and size
- Pattern from config
- Test file location
- Number of alternatives in pattern

## Phase 3: Create Backup
Before deletion:
- Create backup directory with timestamp
- Copy snippet file
- Copy config entry to backup
- Copy test file if exists

## Phase 4: Confirmation
Unless --force flag:
- Show summary of what will be deleted
- Display backup location
- Require explicit confirmation (y/n)

## Phase 5: Delete Files
Remove files:
- Delete snippet .md file
- Remove entry from snippets-config.json
- Delete test file
- Clean up empty directories

## Phase 6: Verify Deletion
Confirm deletion successful:
- Check files are gone
- Verify config no longer has entry
- Validate JSON structure still correct

## Phase 7: Summary
Show results:
- Files deleted
- Backup location (if created)
- Updated snippet count

## Tools to Use:
- Read: Get current snippet and config
- Edit: Update config to remove entry
- Bash: Delete files, create backups
- Write: Update config file
</workflow>

<output>
## Format
Clear, safe deletion process with confirmations:
- Show exactly what will be deleted
- Backup location prominently displayed
- Require explicit confirmation
- Success/failure summary

## Example Output:
"Preparing to delete snippet 'docker'

**Files to be deleted:**
- ~/.claude/snippets/docker.md (2.3 KB)
- ~/.claude/snippets/tests/test_docker.sh (1.1 KB)
- Config entry: `\b(docker|container)\b` → docker.md

**Backup created at:**
~/.claude/snippets/backups/2025-01-15_143022_docker/

This action will permanently delete the snippet. Continue? (y/n): y

**Deleting files...**
✓ Removed docker.md
✓ Removed test_docker.sh
✓ Updated snippets-config.json
✓ Validated JSON structure

**Summary:**
✅ Snippet 'docker' deleted successfully
📦 Backup available at: ~/.claude/snippets/backups/2025-01-15_143022_docker/
📊 Remaining snippets: 4"
</output>

<clarification>
## When to Ask Questions
Clarify when:
- Snippet name doesn't exist
- Multiple similar names found
- Config entry exists but file missing (or vice versa)
- User attempts to delete with --force

## Example Questions:
- "Snippet 'docker' not found. Did you mean 'docker-compose'?"
- "Found docker.md but no config entry. Delete file anyway?"
- "Using --force will skip confirmation. Are you sure?"
- "Backup directory already exists. Overwrite backup?"

## How to Ask
- Provide clear alternatives
- Emphasize safety (backups, confirmation)
- Show what's inconsistent
- Suggest corrective actions
</clarification>