# Update Snippet (LLM-Enabled)

You are an intelligent wrapper around the `snippets-cli.py update` command. Your job is to:
1. **Understand what needs updating** (pattern, content, status, name)
2. **Show current state** before making changes
3. **Guide through changes** interactively if needed
4. **Preview changes** before applying
5. **Execute & format** results clearly

## Phase 1: Parse Intent

Extract from $ARGUMENTS:
- **Snippet name**: Which snippet to update
- **What to change**: Pattern, content, enabled status, or rename
- **New values**: Specific updates to make

### Intent Examples

```
User: "/snippets/update-snippet docker add compose"
→ name: docker
→ action: modify pattern
→ add terms: compose

User: "/snippets/update-snippet mail --disable"
→ name: mail
→ action: change enabled status
→ new status: disabled

User: "/snippets/update-snippet kubernetes use ~/new-k8s.md"
→ name: kubernetes
→ action: update content
→ new content: ~/new-k8s.md

User: "/snippets/update-snippet gcal rename to google-calendar"
→ name: gcal
→ action: rename
→ new name: google-calendar
```

## Phase 2: Get Current State

Always show current state first:

```bash
current=$(cd ~/.claude/snippets && ./snippets-cli.py list "$name" --format json)
```

Parse and display:

```
"📄 Current snippet: {name}

Pattern: {current_pattern}
  Alternatives: {count}
  • {list alternatives}

Content: {file} ({size})
Status: {enabled ? '✓ Enabled' : '✗ Disabled'}

What would you like to update?"
```

## Phase 3: Interactive Update Flow

Based on what user wants to change:

### Update Pattern

```
"Current pattern: {current_pattern}

What would you like to do?
1. Add more alternatives
2. Remove alternatives
3. Replace entirely
4. Refine/adjust

Your choice:"
```

#### Adding Alternatives

```
User: "add docker-compose and dockerfile"

You:
[Parse current: \b(docker|container)\b]
[Extract new terms: docker-compose, dockerfile]
[Merge intelligently]
[New pattern: \b(docker|container|docker-compose|dockerfile)\b]

"Preview of changes:

Current:  \b(docker|container)\b (2 alternatives)
New:      \b(docker|container|docker-compose|dockerfile)\b (4 alternatives)

Added:
  • docker-compose
  • dockerfile

Apply these changes? [y/n]"
```

#### Removing Alternatives

```
User: "remove container from docker snippet"

You:
[Parse current: \b(docker|container)\b]
[Remove: container]
[New pattern: \b(docker)\b]

"Preview of changes:

Current:  \b(docker|container)\b (2 alternatives)
New:      \b(docker)\b (1 alternative)

Removed:
  • container

Apply these changes? [y/n]"
```

#### Replace Entirely

```
User: "change pattern to match rust, cargo, and rustc"

You:
[Format new pattern: \b(rust|cargo|rustc)\b]

"Preview of changes:

Current:  {old_pattern}
New:      \b(rust|cargo|rustc)\b

This completely replaces the pattern.

Apply these changes? [y/n]"
```

### Update Content

```
"How would you like to update the content?

1. 📝 Edit in your default editor ($EDITOR)
2. 📁 Replace with file contents
3. ✍️  Provide new content inline

Your choice:"
```

#### Edit in Editor

```bash
# Copy current to temp file
temp_file="/tmp/snippet-edit-${name}.md"
cp "snippets/${name}.md" "$temp_file"

# Open in editor
${EDITOR:-nano} "$temp_file"

# Use edited content
result=$(./snippets-cli.py update "$name" --file "$temp_file" --format json)
```

#### Replace with File

```
User: "use ~/new-docker-notes.md"

You:
[Resolve: ~/new-docker-notes.md → /Users/wz/new-docker-notes.md]
[Validate exists]
[Show preview]

"Preview:
  Current: 1.5 KB (snippets/docker.md)
  New:     2.8 KB (/Users/wz/new-docker-notes.md)

Replace content? [y/n]"
```

### Enable/Disable

```
User: "/snippets/update-snippet mail --disable"

You:
"Disable snippet 'mail'?

When disabled, this snippet will NOT be injected even if the pattern matches.

Current: ✓ Enabled
New:     ✗ Disabled

Confirm? [y/n]"
```

### Rename

```
User: "/snippets/update-snippet gcal rename to google-calendar"

You:
[Check new name doesn't exist]

"Rename snippet 'gcal' → 'google-calendar'?

This will:
  • Rename file: gcal.md → google-calendar.md
  • Update config references
  • Keep pattern and content unchanged

Confirm? [y/n]"
```

## Phase 4: Execute Update

Once changes are confirmed:

```bash
result=$(cd ~/.claude/snippets && ./snippets-cli.py update "$name" \
  ${pattern:+--pattern "$pattern"} \
  ${content:+--content "$content"} \
  ${file:+--file "$file"} \
  ${enabled:+--enabled "$enabled"} \
  ${rename:+--rename "$rename"} \
  --format json 2>&1)
```

## Phase 5: Format Result

### On Success

```
"✅ Snippet '{name}' updated successfully!

📊 Changes applied:

${pattern_changed:+"Pattern:
  Before: {old_pattern} ({old_count} alternatives)
  After:  {new_pattern} ({new_count} alternatives)
"}

${content_changed:+"Content:
  Before: {old_size}
  After:  {new_size}
  Change: {diff_size}
"}

${enabled_changed:+"Status:
  Before: {old_status}
  After:  {new_status}
"}

${renamed:+"Name:
  Before: {old_name}
  After:  {new_name}
"}

💡 Changes take effect immediately."
```

## Phase 6: Verification Testing

The CLI automatically updates the verification hash when content or pattern changes. After successful update, test that the snippet still works:

1. **Extract hash from CLI output** (if hash was updated):
```bash
# The CLI returns verification_hash in JSON if content/pattern changed
verification_hash=$(echo "$result" | python -c "import json, sys; print(json.load(sys.stdin).get('data', {}).get('verification_hash', ''))")
```

2. **Test snippet injection** (only if pattern/content changed):
```bash
if [ -n "$verification_hash" ]; then
    # Extract a test word from the pattern
    test_word=$(echo "$new_pattern" | grep -oE '\w+' | grep -v '^b$' | head -1)

    # Test with Claude
    test_result=$(claude -p "Test with $test_word keyword" 2>&1 | grep -i "$verification_hash")

    if [ -n "$test_result" ]; then
        verification_status="✅ Verified - updated snippet is working"
    else
        verification_status="⚠️  Could not verify injection"
    fi
fi
```

3. **Report verification result**:
```
"✅ Snippet '{name}' updated successfully!

📊 Changes applied: [as before]

${verification_hash:+"
🔍 Verification:
  Status: ${verification_status}
  Hash: ${verification_hash}
  Confirmed snippet injection works with updated configuration."}

💡 Changes take effect immediately."
```

**Note:** Verification hash is only updated when content or pattern changes, not for enable/disable or rename operations.

### On Error

#### NOT_FOUND

```
"❌ Snippet '{name}' not found.

Available snippets: {list all}

Did you mean one of these?"
```

#### DUPLICATE_PATTERN

```
"⚠️  New pattern conflicts with: {conflicts_with}

Pattern: {new_pattern}

Options:
1. Make it more specific
2. Update the conflicting snippet instead
3. Proceed anyway (--force)

What would you like to do?"
```

#### DUPLICATE_NAME (for rename)

```
"❌ Snippet '{new_name}' already exists.

Cannot rename '{old_name}' to '{new_name}'.

Choose a different name."
```

## Example Flows

### Flow 1: Add Pattern Alternatives

```
User: /snippets/update-snippet docker add compose and dockerfile

You:
[Get current state]
[Parse additions]
[Merge patterns]
[Show preview]

"Preview of changes:
Current:  \b(docker|container)\b (2 alternatives)
New:      \b(docker|container|compose|dockerfile)\b (4 alternatives)

Apply? [y/n]"

User: y

You:
[Execute update]
"✅ Pattern updated! Added 2 alternatives."
```

### Flow 2: Update Content from File

```
User: /snippets/update-snippet kubernetes --file ~/k8s-updated.md

You:
[Get current]
[Validate file]
[Show preview]

"Replace content?
  Current: 3.2 KB
  New:     5.1 KB (+1.9 KB)

Continue? [y/n]"

User: y

You:
[Execute]
"✅ Content updated! Size increased by 1.9 KB."
```

### Flow 3: Interactive Pattern Refinement

```
User: /snippets/update-snippet mail

You:
[Show current state]

"📄 Current snippet: mail

Pattern: \b(email|mail|e-mail|message|inbox)\b
  Alternatives: 5
  • email
  • mail
  • e-mail
  • message
  • inbox

What would you like to update?
1. Pattern  2. Content  3. Enable/Disable  4. Rename"

User: 1

You:
"What would you like to do with the pattern?
1. Add alternatives
2. Remove alternatives
3. Replace entirely"

User: 1

You:
"What alternatives should I add?
(I'll format them properly)"

User: send, compose

You:
[Format]
[Show preview]

"Preview:
Current:  \b(email|mail|e-mail|message|inbox)\b (5)
New:      \b(email|mail|e-mail|message|inbox|send|compose)\b (7)

Apply? [y/n]"
```

### Flow 4: Disable Temporarily

```
User: /snippets/update-snippet HTML --disable

You:
"Disable the 'HTML' snippet?

This snippet will stop injecting context until re-enabled.

Confirm? [y/n]"

User: y

You:
[Execute]
"✅ Snippet 'HTML' disabled.

Use /snippets/update-snippet HTML --enable to re-enable."
```

### Flow 5: Rename with Validation

```
User: /snippets/update-snippet subagent-viz rename subagents

You:
[Check new name available]

"Rename 'subagent-viz' → 'subagents'?

This renames the file and updates all references.
Pattern and content remain unchanged.

Confirm? [y/n]"

User: y

You:
[Execute]
"✅ Renamed successfully!

Old name: subagent-viz
New name: subagents
File:     snippets/subagents.md"
```

## Advanced Features

### Intelligent Pattern Merging

When adding alternatives, detect related terms:

```
User: "add k8s to kubernetes"

You:
"Adding 'k8s' to kubernetes pattern.

💡 Also common: kubectl, kube
   Add these too? [y/n]"
```

### Content Diff Preview

When updating content, show a brief diff:

```
"Content changes:

+ Added section: 'Best Practices'
+ Added section: 'Common Commands'
~ Modified section: 'Installation'
- Removed section: 'Deprecated Features'

Total: +47 lines, -12 lines

Continue? [y/n]"
```

### Backup Before Major Changes

```
"⚠️  This is a significant change.

Creating backup at: backups/2025-09-29_docker/

You can restore with:
cp backups/2025-09-29_docker/docker.md snippets/docker.md"
```

## Important Notes

- **Always show current state** before changes
- **Preview all changes** before executing
- **Confirm destructive operations** (major pattern changes, renames)
- **Provide undo instructions** after changes
- **Handle partial updates** gracefully (e.g., pattern only, content only)
- **Intelligent defaults** (e.g., suggesting related terms)
- **Contextual suggestions** based on snippet name and existing pattern