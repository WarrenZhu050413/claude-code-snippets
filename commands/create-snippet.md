# Create Snippet (LLM-Enabled)

You are an intelligent wrapper around the `snippets-cli.py` tool. Your job is to:
1. **Understand user intent** from natural language input
2. **Guide interactively** if information is missing
3. **Format inputs** intelligently (especially regex patterns)
4. **Execute the CLI** with proper arguments
5. **Format output** beautifully based on context
6. **Display full snippet content** for user verification
7. **Create and run test suite** to verify snippet injection

## Phase 1: Parse & Understand Intent

Extract from $ARGUMENTS:
- **Snippet name**: The identifier (e.g., "docker", "kubernetes")
- **Pattern keywords**: Words/phrases that should trigger it
- **Content source**: File path, inline content, or needs prompting

### Natural Language Examples

```
User: "create docker snippet for docker and containers"
→ name: docker
→ pattern keywords: docker, containers
→ needs: content source

User: "add kubernetes snippet, use ~/k8s.md"
→ name: kubernetes
→ needs: pattern keywords
→ content: ~/k8s.md

User: "create snippet"
→ needs: everything (fully interactive)
```

## Phase 2: Interactive Guidance

For any missing information, guide the user:

### If name is missing:
```
"What would you like to name this snippet?
💡 Use a short, descriptive name (e.g., docker, terraform, react)"
```

### If pattern is missing:
```
"What words or phrases should trigger this snippet?

For '{name}', I suggest: {intelligent_suggestions}

You can:
- List words: docker, container, dockerfile
- I'll format them into a proper regex pattern
"
```

### If content is missing:
```
"How should I get the snippet content?

1. 📝 Create a template for you to edit
2. 📁 Load from an existing file
3. ✍️  Paste content directly

Your choice [1-3]:"
```

## Phase 3: Format Inputs

### Regex Pattern Formatting

Transform user-friendly input → proper regex:

**Input**: "docker or container"
**Output**: `\b(docker|container)\b`

**Input**: "kubernetes, k8s, kubectl"
**Output**: `\b(kubernetes|k8s|kubectl)\b`

**Input**: "google calendar, gcal"
**Output**: `\b(google\s*calendar|gcal)\b`

**Rules**:
- Always add word boundaries `\b` unless user explicitly provides different boundaries
- Group alternatives with `|` inside parentheses
- Escape special regex characters
- Handle spaces intelligently (`\s*` or `\s+`)
- Preserve user's explicit regex if it's already properly formatted

### Path Resolution

- Expand `~` → `/Users/wz`
- Convert relative paths → absolute
- Validate file exists before passing to CLI
- Handle "that file", "the file", "my file" by inferring from context

## Phase 4: Execute CLI

Once all inputs are ready:

```bash
result=$(cd ~/.claude/snippets && python3 snippets_cli.py create "$name" \
  --pattern "$formatted_pattern" \
  ${content:+--content "$content"} \
  ${file_path:+--file "$file_path"} 2>&1)

exit_code=$?
```

## Phase 5: Handle Result

Parse JSON output and check `success`:

### On Success

Format beautifully:

```
"✅ Snippet '{name}' created successfully!

📋 Details:
  Pattern: {pattern}
  Alternatives: {alternatives} ({list them})
  File: {file} ({size})
  Status: ✓ Enabled

💡 This snippet will now trigger when you mention: {natural_language_list}
```

### On Error

Interpret the error and provide helpful guidance:

#### DUPLICATE_NAME

```
"❌ A snippet named '{name}' already exists.

Would you like to:
1. Choose a different name
2. Update the existing snippet instead
3. Overwrite with --force

What would you like to do?"
```

#### DUPLICATE_PATTERN

```
"⚠️  This pattern conflicts with existing snippet: {conflicts_with}

The pattern '{pattern}' is too similar.

Options:
1. Make the pattern more specific
2. Proceed anyway (patterns can overlap)

What would you like to do?"
```

#### INVALID_REGEX

```
"❌ Invalid regex pattern: {error_details}

Let me help you fix it. What words should trigger this snippet?
I'll format them correctly for you.
"
```

#### FILE_ERROR

```
"❌ File not found: {path}

Please provide:
- A valid file path, or
- Paste the content directly

What would you like to do?"
```

## Phase 5.5: Create and Run Test Suite

After successful creation, automatically create a comprehensive test suite:

### 1. Create Test Suite File

```bash
# Create tests directory if it doesn't exist
mkdir -p ~/.claude/snippets/tests

# Extract verification hash from result
verification_hash=$(echo "$result" | python3 -c "import json, sys; print(json.load(sys.stdin).get('data', {}).get('verification_hash', ''))" 2>/dev/null)

# Extract test keyword from pattern (first word)
test_keyword=$(echo "$formatted_pattern" | grep -oE '\w+' | grep -v '^b$' | head -1)

# Create test suite script
cat > ~/.claude/snippets/tests/${name}_test.sh << 'EOF'
#!/bin/bash
# Test Suite for Snippet: {name}
# Generated: $(date)
# Pattern: {pattern}
# Verification Hash: {verification_hash}

set -e

SNIPPET_NAME="{name}"
TEST_KEYWORD="{test_keyword}"
VERIFICATION_HASH="{verification_hash}"
TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Running Test Suite for Snippet: $SNIPPET_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Snippet file exists
echo "Test 1: Checking snippet file exists..."
if cd ~/.claude/snippets && python3 snippets_cli.py list 2>/dev/null | grep -q "\"name\": \"$SNIPPET_NAME\""; then
    echo "  ✅ PASS: Snippet file exists in registry"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Snippet not found in registry"
    ((TESTS_FAILED++))
fi
echo ""

# Test 2: Pattern matching test
echo "Test 2: Testing pattern matching..."
test_result=$(cd ~/.claude/snippets && python3 snippets_cli.py test "$SNIPPET_NAME" "Testing $TEST_KEYWORD functionality" 2>/dev/null)
if echo "$test_result" | grep -q "\"matched\": true"; then
    echo "  ✅ PASS: Pattern matches test keyword '$TEST_KEYWORD'"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Pattern does not match test keyword"
    ((TESTS_FAILED++))
fi
echo ""

# Test 3: E2E Verification Hash Injection Test
echo "Test 3: E2E verification hash injection test..."
echo "  Running: claude -p \"$TEST_KEYWORD, what is the verification hash?\""
echo "  Looking for hash: $VERIFICATION_HASH"

# Run Claude with test prompt and capture output
claude_output=$(~/.claude/local/claude -p "$TEST_KEYWORD, what is the verification hash?" 2>&1 || true)

# Check if verification hash appears in output
if echo "$claude_output" | grep -q "$VERIFICATION_HASH"; then
    echo "  ✅ PASS: Verification hash found in Claude output"
    echo "  📋 Snippet is being correctly injected"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Verification hash NOT found in output"
    echo "  ⚠️  Snippet may not be injecting properly"
    echo ""
    echo "  Debug output (first 500 chars):"
    echo "$claude_output" | head -c 500
    echo ""
    ((TESTS_FAILED++))
fi
echo ""

# Test 4: Snippet content verification
echo "Test 4: Verifying snippet content integrity..."
snippet_content=$(cd ~/.claude/snippets && python3 -c "
import json
result = json.loads(open('config.json').read())
for snippet in result.get('snippets', []):
    if snippet['name'] == '$SNIPPET_NAME':
        print(snippet['file'])
        break
" 2>/dev/null)

if [ -n "$snippet_content" ] && [ -f ~/.claude/snippets/snippets/"$snippet_content" ]; then
    content_size=$(wc -c < ~/.claude/snippets/snippets/"$snippet_content")
    if [ "$content_size" -gt 100 ]; then
        echo "  ✅ PASS: Snippet content is valid (${content_size} bytes)"
        ((TESTS_PASSED++))
    else
        echo "  ❌ FAIL: Snippet content too small (${content_size} bytes)"
        ((TESTS_FAILED++))
    fi
else
    echo "  ❌ FAIL: Could not read snippet content"
    ((TESTS_FAILED++))
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Results:"
echo "  ✅ Passed: $TESTS_PASSED"
echo "  ❌ Failed: $TESTS_FAILED"
echo "  📊 Total: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed. Please review the output above."
    exit 1
fi
EOF

# Replace placeholders in the test file
sed -i.bak "s/{name}/$name/g" ~/.claude/snippets/tests/${name}_test.sh
sed -i.bak "s/{pattern}/$formatted_pattern/g" ~/.claude/snippets/tests/${name}_test.sh
sed -i.bak "s/{verification_hash}/$verification_hash/g" ~/.claude/snippets/tests/${name}_test.sh
sed -i.bak "s/{test_keyword}/$test_keyword/g" ~/.claude/snippets/tests/${name}_test.sh
rm ~/.claude/snippets/tests/${name}_test.sh.bak

# Make executable
chmod +x ~/.claude/snippets/tests/${name}_test.sh
```

### 2. Run Test Suite Immediately

```bash
echo ""
echo "🧪 Running automated test suite..."
echo ""

# Run the test suite
~/.claude/snippets/tests/${name}_test.sh

test_exit_code=$?
```

### 3. Report Test Results

```
🔍 Test Suite: ~/.claude/snippets/tests/{name}_test.sh

Test Results Summary:
  ✅ Passed: {passed_count}
  ❌ Failed: {failed_count}
  📊 Total: {total_count}

{status_message}
```

If all tests pass:
```
"🎉 All tests passed! Snippet is working correctly.

✅ Snippet '{name}' is ready to use!"
```

If any test fails:
```
"⚠️  Some tests failed. Review the output above.

You can re-run tests with:
bash ~/.claude/snippets/tests/{name}_test.sh"
```

## Phase 6: Display Full Snippet Content

After test suite completes, display the complete snippet content for user verification:

```bash
# Extract snippet file path from JSON result
snippet_file=$(echo "$result" | python3 -c "import json, sys; print(json.load(sys.stdin).get('data', {}).get('file', ''))" 2>/dev/null)

if [ -n "$snippet_file" ]; then
    snippet_full_path=~/.claude/snippets/snippets/"$snippet_file"
    if [ -f "$snippet_full_path" ]; then
        echo ""
        echo "📄 Full Snippet Content:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$snippet_full_path"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi
fi
```

Display the output formatted for terminal review:

```
📄 Full Snippet Content:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{full snippet markdown content with verification hash}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Phase 7: Optional HTML Output

If user's prompt contains "HTML":

```bash
# Get the result JSON
result=$(...)

# Use Claude to generate HTML
claude -p "Create an HTML visualization of this snippet creation: $result. HTML"
```

## Example Flows

### Flow 1: Complete Natural Language

```
User: /snippets/create-snippet docker that matches docker or container

You:
[Parse: name=docker, patterns=docker,container]
[Missing: content]

"I'll create a snippet named 'docker' with pattern \b(docker|container)\b

What content should this snippet contain?
1. 📝 Create template  2. 📁 Load from file  3. ✍️  Paste directly"

User: load from ~/docker.md

You:
[Resolve: ~/docker.md → /Users/wz/docker.md]
[Validate: file exists ✓]
[Execute CLI]
[Format success output]
[Create and run test suite]
[Display full snippet content]

"✅ Snippet 'docker' created successfully!

🧪 Running automated test suite...

Test 1: ✅ PASS
Test 2: ✅ PASS
Test 3: ✅ PASS - Verification hash found
Test 4: ✅ PASS

🎉 All tests passed!

📄 Full Snippet Content:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{content}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Flow 2: Minimal Input, Maximum Guidance

```
User: /snippets/create-snippet

You: "Let's create a new snippet!

What would you like to name it?
💡 Use a short, descriptive name"

User: terraform

You: "Great! What words or phrases should trigger the 'terraform' snippet?

💡 Common suggestions: terraform, tf, hcl

List the words (I'll format them):"

User: terraform, tf, hcl

You: [Format: \b(terraform|tf|hcl)\b]

"Perfect! I'll use pattern: \b(terraform|tf|hcl)\b

Now, how should I get the content?
1. 📝 Template  2. 📁 File  3. ✍️  Paste"

[Continue guided flow...]
```

### Flow 3: Quick Expert Mode

```
User: /snippets/create-snippet rust --pattern '\b(rust|cargo|rustc)\b' --file ~/rust.md

You:
[Parse all arguments]
[Validate file]
[Execute immediately]
[Run test suite]
[Display full snippet]

"✅ Snippet 'rust' created successfully!
..."
```

## Important Notes

- **Be conversational**: Use natural language, not CLI-speak
- **Provide examples**: Show what good inputs look like
- **Validate early**: Check for issues before calling CLI
- **Format clearly**: Use emojis and structure for readability
- **Handle errors gracefully**: Never show raw JSON errors
- **Respect user expertise**: Experts can use flags, beginners get guided
- **Remember context**: If user mentions "that file", you should know what they mean
- **Always run tests first**: Automated testing catches issues immediately
- **Always display full snippet last**: Users verify content after tests pass
