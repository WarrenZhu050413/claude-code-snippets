# Update Snippet Command

<input>
## Parse Arguments
Process $ARGUMENTS to extract:
- Snippet name (required)
- Optional flags: --pattern, --content, --both

## Example Inputs
- `/snippets/update-snippet docker` (interactive: choose what to edit)
- `/snippets/update-snippet docker --pattern` (edit pattern only)
- `/snippets/update-snippet docker --content` (edit content only)
- `/snippets/update-snippet docker --both` (edit both)

## Read Context
Read existing snippet data:
- ~/.claude/snippets/snippets-config.json (current pattern)
- ~/.claude/snippets/{name}.md (current content)
- ~/.claude/snippets/tests/test_{name}.sh (test file)

## Build Context
- Current snippet configuration
- Existing pattern and content
- Related test files
</input>

<workflow>
## Phase 1: Validate Snippet Exists
Check if snippet exists:
- Verify snippet file exists
- Check if pattern is in config
- Show current configuration

## Phase 2: Determine What to Edit
Based on arguments or prompt user:
- Pattern only
- Content only
- Both pattern and content

## Phase 3: Edit Pattern (if selected)
If editing pattern:
- Show current pattern
- Prompt for new pattern
- Validate regex syntax
- Check for duplicates with other patterns
- Show what the new pattern would match

## Phase 4: Edit Content (if selected)
If editing content:
- Show current content
- Allow editing via $EDITOR or direct input
- Preview changes

## Phase 5: Validation
- If pattern changed: validate regex
- Test new pattern against example inputs
- Run existing test file with new changes

## Phase 6: Backup & Update
- Create backup of current files
- Update snippet file if content changed
- Update config if pattern changed
- Update test file if pattern changed

## Phase 7: Confirmation
- Show summary of changes
- Run tests with new configuration
- Confirm success

## Tools to Use:
- Read: Get current snippet and config
- Edit: Update snippet content
- Write: Update config if needed
- Bash: Run tests, open editor
</workflow>

<output>
## Format
Interactive prompts with clear feedback:
- Show current vs new values
- Highlight what changed
- Test results
- Success confirmation

## Example Output:
"Let's update the 'docker' snippet.

**Current Configuration:**
- Pattern: `\b(docker|container)\b`
- File: docker.md (150 lines)

**What would you like to edit?**
1. Pattern only
2. Content only
3. Both

Your choice: 1

**Current Pattern:** `\b(docker|container)\b`
**New Pattern:** `\b(docker|container|dockerfile|compose)\b`

**Pattern Validation:**
✓ Regex syntax valid
✓ No conflicts with existing patterns
✓ Added 2 new alternatives

**Testing New Pattern:**
Running tests...
✓ 10/10 tests passed

**Summary of Changes:**
- Pattern: `\b(docker|container)\b` → `\b(docker|container|dockerfile|compose)\b`
- Content: No changes

✅ Snippet 'docker' updated successfully!"
</output>

<clarification>
## When to Ask Questions
Clarify when:
- Snippet name doesn't exist
- New pattern conflicts with existing patterns
- Tests fail after updates
- Ambiguous edit request

## Example Questions:
- "Snippet 'docker' not found. Did you mean 'docker-compose'?"
- "New pattern overlaps with 'container.md'. Continue anyway?"
- "Tests are failing with new pattern. Revert changes?"
- "Do you want to update the test file to match the new pattern?"

## How to Ask
- Show specific conflicts
- Suggest alternatives
- Provide rollback option
- Explain implications
</clarification>