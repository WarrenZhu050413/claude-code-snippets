#!/bin/bash
# Test Suite for Snippet: search
# Generated: $(date)
# Pattern: \b(search|searching|websearch|web[\s-]?search|find[\s-]?information|look[\s-]?up|research|researching|comprehensive[\s-]?search)\b
# Verification Hash: 7f3c9a2e5d6b1048

set -e

SNIPPET_NAME="search"
TEST_KEYWORD="search"
VERIFICATION_HASH="7f3c9a2e5d6b1048"
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
if [ "$VERIFICATION_HASH" = "UNKNOWN" ]; then
    echo "  ⚠️  SKIP: No verification hash found in snippet"
    echo "  Note: This snippet was created before verification hash feature"
else
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
fi
echo ""

# Test 4: Snippet content verification
echo "Test 4: Verifying snippet content integrity..."
snippet_file="$SNIPPET_NAME"
snippet_path=$(cd ~/.claude/snippets && python3 -c "
import json, sys
result = json.loads(open('config.json').read())
for mapping in result.get('mappings', []):
    # Try to match by file name
    if '$SNIPPET_NAME' in mapping.get('snippet', ''):
        print(mapping['snippet'])
        sys.exit(0)
# Also check snippets array if it exists
for snippet in result.get('snippets', []):
    if snippet.get('name') == '$SNIPPET_NAME':
        print(snippet['file'])
        sys.exit(0)
" 2>/dev/null)

if [ -z "$snippet_path" ]; then
    # Fallback: use file from snippet data
    snippet_path="snippets/search.md"
fi

if [ -f ~/.claude/snippets/"$snippet_path" ]; then
    content_size=$(wc -c < ~/.claude/snippets/"$snippet_path")
    if [ "$content_size" -gt 50 ]; then
        echo "  ✅ PASS: Snippet content is valid (${content_size} bytes)"
        ((TESTS_PASSED++))
    else
        echo "  ❌ FAIL: Snippet content too small (${content_size} bytes)"
        ((TESTS_FAILED++))
    fi
else
    echo "  ❌ FAIL: Could not find snippet file at $snippet_path"
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
