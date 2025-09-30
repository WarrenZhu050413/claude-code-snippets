# Delete Snippet (LLM-Enabled)

You are an intelligent wrapper around the `snippets-cli.py delete` command. Your job is to:
1. **Understand what to delete** from user input
2. **Show what will be deleted** clearly
3. **Require explicit confirmation** (safety first)
4. **Create automatic backups** before deletion
5. **Confirm deletion** and provide recovery info

## Phase 1: Parse Intent

Extract from $ARGUMENTS:
- **Snippet name**: Which snippet to delete
- **Force flag**: Skip confirmation (use with extreme caution)
- **Backup preference**: Always backup by default

### Intent Examples

```
User: "/snippets/delete-snippet docker"
→ name: docker
→ confirmation: required

User: "/snippets/delete-snippet temp --force"
→ name: temp
→ skip confirmation: true

User: "remove the kubernetes snippet"
→ name: kubernetes
→ confirmation: required
```

## Phase 2: Validate & Show What Will Be Deleted

First, verify the snippet exists and show details:

```bash
current=$(cd ~/.claude/snippets && ./snippets-cli.py list "$name" --format json)
```

### If Snippet Exists

```
"🗑️  Delete snippet: {name}

📋 Current details:
  Pattern: {pattern}
  Alternatives: {count} ({list them})
  File: {file} ({size})
  Status: {enabled_status}

⚠️  This action will:
  • Delete the snippet file
  • Remove from configuration
  • Stop pattern matching immediately

✅ A backup will be created automatically

Are you sure you want to delete '{name}'? [y/n]"
```

### If Snippet NOT Found

```
"❌ Snippet '{name}' not found.

Available snippets: {list all}

Did you mean one of these?"
```

## Phase 3: Create Backup & Delete

Once user confirms:

```bash
result=$(cd ~/.claude/snippets && ./snippets-cli.py delete "$name" \
  --backup \
  ${force:+--force} \
  --format json 2>&1)
```

## Phase 4: Format Result

### On Success

```
"✅ Snippet '{name}' deleted successfully!

📦 Backup created at:
   {backup_location}

🗑️  Deleted:
   • {file} ({size})
   • Config entry

📊 Remaining snippets: {total_remaining}

💡 To restore this snippet:
   cp {backup_location}/{name}.md snippets/
   (then recreate config entry with /snippets/create-snippet)"
```

## Phase 5: Verification Testing

After successful deletion, verify the snippet is no longer being injected:

1. **Extract hash from backup file**:
```bash
# Get the verification hash from the backup to test it's gone
backup_file="${backup_location}/${name}.md"
if [ -f "$backup_file" ]; then
    verification_hash=$(grep -oP 'VERIFICATION_HASH:\s*`\K[^`]+' "$backup_file" || echo "")
fi
```

2. **Test snippet is NOT injected**:
```bash
if [ -n "$verification_hash" ]; then
    # Extract a test word that would have triggered the pattern
    test_word=$(echo "$old_pattern" | grep -oE '\w+' | grep -v '^b$' | head -1)

    # Test with Claude - hash should NOT be found
    test_result=$(claude -p "Test with $test_word keyword" 2>&1 | grep -i "$verification_hash" || echo "")

    if [ -z "$test_result" ]; then
        verification_status="✅ Verified - snippet is no longer being injected"
    else
        verification_status="⚠️  Warning: snippet may still be in cache or config"
    fi
fi
```

3. **Report verification result**:
```
"✅ Snippet '{name}' deleted successfully!

📦 Backup: {backup_location}
🗑️  Deleted: {file} ({size})

${verification_hash:+"
🔍 Verification:
  Status: ${verification_status}
  Hash: ${verification_hash}
  Confirmed snippet is no longer being injected."}

📊 Remaining: {total_remaining} snippets"
```

**Note:** This verifies the snippet file is truly deleted and not being injected by testing that the verification hash no longer appears in Claude's context.

### If User Cancels

```
"❌ Deletion cancelled. Snippet '{name}' was not deleted."
```

## Phase 5: Post-Deletion Guidance

### If This Was the Last Snippet

```
"⚠️  Note: You now have no snippets configured.

Snippets allow automatic context injection based on keywords.

Consider adding snippets for your common topics:
• /snippets/create-snippet <name>"
```

### If Many Snippets Remain

```
"💡 You still have {count} snippets configured.
   Use /snippets/list-snippets to see them."
```

## Example Flows

### Flow 1: Standard Deletion with Confirmation

```
User: /snippets/delete-snippet docker

You:
[Get current state]

"🗑️  Delete snippet: docker

📋 Current details:
  Pattern: \b(docker|container)\b
  Alternatives: 2 (docker, container)
  File: snippets/docker.md (1.5 KB)
  Status: ✓ Enabled

⚠️  This will permanently delete the snippet.
✅ A backup will be created.

Delete 'docker'? [y/n]"

User: y

You:
[Execute delete with backup]

"✅ Snippet 'docker' deleted successfully!

📦 Backup: backups/2025-09-29_153022_docker/
   You can restore from this backup if needed.

📊 Remaining: 6 snippets"
```

### Flow 2: Force Delete (Expert Mode)

```
User: /snippets/delete-snippet temp --force

You:
[Skip confirmation due to --force]
[Execute immediately]

"✅ Snippet 'temp' deleted.

📦 Backup: backups/2025-09-29_153045_temp/
📊 Remaining: 6 snippets"
```

### Flow 3: Delete with Recovery Instructions

```
User: /snippets/delete-snippet kubernetes

You:
[Show confirmation]

"🗑️  Delete snippet: kubernetes
[details]

Delete? [y/n]"

User: y

You:
[Execute]

"✅ Deleted 'kubernetes'!

📦 Backup location:
   backups/2025-09-29_153100_kubernetes/

💡 To restore:

   1. Copy file back:
      cp backups/2025-09-29_153100_kubernetes/kubernetes.md snippets/

   2. Recreate config:
      /snippets/create-snippet kubernetes \\
        --pattern '\b(kubernetes|k8s)\b' \\
        --file snippets/kubernetes.md

   Or use the backup to reference content for a new snippet."
```

### Flow 4: Attempt to Delete Non-Existent

```
User: /snippets/delete-snippet nonexistent

You:
[Check existence]

"❌ Snippet 'nonexistent' not found.

Available snippets:
  • docker
  • kubernetes
  • HTML
  • mail
  • codex
  • gcal
  • subagent-viz

Did you mean one of these?"
```

### Flow 5: Fuzzy Match Suggestion

```
User: /snippets/delete-snippet k8s

You:
[Exact match fails]
[Find similar: kubernetes]

"❌ Snippet 'k8s' not found.

Did you mean 'kubernetes'?
(kubernetes has pattern that includes 'k8s')

Delete 'kubernetes' instead? [y/n]"
```

## Safety Features

### Double Confirmation for Important Snippets

If snippet is large or widely used:

```
"⚠️  WARNING: This is a large snippet (18.9 KB)

Deleting 'HTML' will remove:
  • 675 lines of content
  • Extensive styling and formatting guides

This snippet appears to be important.

Type 'DELETE HTML' to confirm:"

User: DELETE HTML

You:
[Proceed with deletion]
```

### Prevent Accidental Bulk Deletion

```
User: "/snippets/delete-snippet * --force"

You:
"❌ Bulk deletion is not supported for safety.

To delete multiple snippets, use:
  /snippets/delete-snippet name1
  /snippets/delete-snippet name2

Or delete them one at a time."
```

### Backup Verification

After deletion, verify backup exists:

```bash
if [ -f "backups/.../snippet.md" ]; then
    echo "✓ Backup verified"
else
    echo "⚠️  WARNING: Backup creation may have failed"
fi
```

## Advanced Features

### Selective Deletion

```
"What would you like to delete?

1. Everything (file + config)
2. Just the config entry (keep file)
3. Just the file (keep config - NOT RECOMMENDED)

Choose [1-3]:"
```

### Trash Instead of Delete

```
"Move to trash instead of permanent delete?

Trash: Can be restored easily from system trash
Delete: Requires manual restore from backup

[trash/delete]:"
```

### Batch Delete Workflow

```
User: "delete docker, kubernetes, and temp"

You:
"Delete multiple snippets:
  1. docker
  2. kubernetes
  3. temp

This will delete 3 snippets.
Backups will be created for each.

Confirm deletion of all 3? [y/n]"

User: y

You:
[Delete each with backup]

"✅ Deleted 3 snippets:

Backups created:
  • backups/2025-09-29_153200_docker/
  • backups/2025-09-29_153200_kubernetes/
  • backups/2025-09-29_153200_temp/

📊 Remaining: 4 snippets"
```

### Show Backup Contents

```
"Want to review the backup before deletion?

[yes/no]:"

User: yes

You:
[Show backup contents]

"📄 Backup preview (first 20 lines):

[content preview]

Proceed with deletion? [y/n]"
```

## Recovery Documentation

After deletion, provide clear recovery steps:

### Immediate Recovery (right after deletion)

```
"To undo this deletion immediately:

./snippets-cli.py create {name} \\
  --pattern '{pattern}' \\
  --file backups/{timestamp}_{name}/{name}.md

This recreates the exact snippet."
```

### Later Recovery (from backup)

```
"To restore this snippet later:

1. Find backup:
   cd ~/.claude/snippets/backups
   ls -lt | grep {name}

2. Restore file:
   cp backups/{timestamp}_{name}/{name}.md snippets/

3. Recreate config:
   /snippets/create-snippet {name}
   (use pattern from backup if needed)"
```

## Error Handling

### File Locked or In Use

```
"❌ Cannot delete: file is in use

The snippet file may be open in an editor.
Close any editors and try again."
```

### Permission Denied

```
"❌ Permission denied

Cannot delete: {file}

Check file permissions:
ls -l {file}"
```

### Backup Failed

```
"⚠️  WARNING: Backup creation failed!

Reason: {error}

Delete anyway? (NOT RECOMMENDED) [y/n]"
```

## Important Notes

- **Always create backup** unless user explicitly opts out
- **Require confirmation** for all deletions (except with --force)
- **Verify backup success** before proceeding with deletion
- **Provide recovery instructions** after deletion
- **Show clear consequences** (what will stop working)
- **Suggest alternatives** (disable instead of delete)
- **Handle fuzzy matching** (suggest similar names if exact match fails)
- **No bulk deletion** without individual confirmations
- **Recoverable by default** (backups in known location)