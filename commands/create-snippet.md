# Add Snippet Command

<input>
## Parse Arguments
Process $ARGUMENTS to extract:
- Snippet name (if provided)
- Pattern (if provided as argument)
- File content (if provided)

## Example Inputs
- `/add-snippet`  (interactive mode)
- `/add-snippet docker` (pre-fill snippet name)
- `/add-snippet docker "\\bdocker\\b"` (with pattern)

## Read Context
- Current snippets-config.json
- Existing snippet files
- Test directory structure

## Build Context
- Existing patterns to avoid duplicates
- Available snippet files
- Test framework setup
</input>

<workflow>
## Phase 1: Gather Information
- Prompt for snippet name (e.g., "docker", "terraform", "pytest")
- Ask for snippet content or file path
- Request regex pattern with examples
- Show what the pattern would match

## Phase 2: Validation
- Check for duplicate patterns
- Validate regex syntax
- Test pattern against example inputs
- Preview the configuration changes

## Phase 3: Create Test Cases
- Generate positive test cases (should match)
- Generate negative test cases (should not match)
- Create test file for the new snippet

## Phase 4: Execute Tests
- Run the test suite
- Collect results
- Format for display

## Phase 5: Confirmation & Installation
- Show test results
- Display what will be added
- Get user confirmation
- Update configuration
- Create snippet file
- Add test file

## Tools to Use:
- Read: Get existing configuration
- Write: Create snippet and test files
- Edit: Update configuration
- Bash: Run tests
- TodoWrite: Track progress
</workflow>

<output>
## Format
Interactive prompts with clear feedback:
- Step-by-step guidance
- Test results in HTML format
- Success confirmation

## Example Output:
"Let's add a new snippet to your Claude Code configuration.

**Step 1: Snippet Details**
What would you like to name this snippet? (e.g., docker, terraform): docker

**Step 2: Content**
Please provide the snippet content or file path:
[User provides content]

**Step 3: Pattern**
What regex pattern should trigger this snippet?
Example: \\b(docker|container|dockerfile)\\b

**Step 4: Testing**
Running tests for your new snippet...
[HTML formatted test results]

**Step 5: Confirmation**
Ready to add 'docker' snippet. Proceed? (y/n): "
</output>

<clarification>
## When to Ask Questions
Clarify when:
- Pattern might overlap with existing ones
- Snippet file already exists
- Test failures need explanation
- Regex needs refinement

## Example Questions:
- "This pattern overlaps with 'container.md'. Should I proceed anyway?"
- "The file docker.md already exists. Overwrite or use different name?"
- "Your pattern didn't match 'Docker'. Should it be case-insensitive?"

## How to Ask
- Show specific examples
- Suggest alternatives
- Explain implications
</clarification>