#!/bin/bash
# Test Suite for Snippet: exa
# Generated: $(date)
# Pattern: \bexa\b
# Verification Hash: d4e04a5136e4d0ee

set -e

SNIPPET_NAME="exa"
TEST_KEYWORD="exa"
VERIFICATION_HASH="d4e04a5136e4d0ee"
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
echo "  Testing if pattern matches: '$TEST_KEYWORD'"
test_result=$(cd ~/.claude/snippets && python3 snippets_cli.py test "$SNIPPET_NAME" "Testing $TEST_KEYWORD functionality" 2>/dev/null)
if echo "$test_result" | grep -q "\"matched\": true"; then
    echo "  ✅ PASS: Pattern matches test keyword '$TEST_KEYWORD'"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Pattern does not match test keyword"
    echo "  Debug: Test string was 'Testing $TEST_KEYWORD functionality'"
    ((TESTS_FAILED++))
fi
echo ""

# Test 3: E2E Verification Hash Injection Test
echo "Test 3: E2E verification hash injection test..."
if [ "$VERIFICATION_HASH" = "UNKNOWN" ]; then
    echo "  ⚠️  SKIP: No verification hash found in snippet"
else
    echo "  Running: claude -p \"$TEST_KEYWORD, what is the verification hash?\""
    echo "  Looking for hash: $VERIFICATION_HASH"

    # Run Claude with test prompt
    claude_output=$(~/.claude/local/claude -p "$TEST_KEYWORD, what is the verification hash?" 2>&1 || true)

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
snippet_path=$(cd ~/.claude/snippets && python3 -c "
import json, sys
result = json.loads(open('config.json').read())
for mapping in result.get('mappings', []):
    if '$SNIPPET_NAME' in mapping.get('snippet', ''):
        print(mapping['snippet'])
        sys.exit(0)
for snippet in result.get('snippets', []):
    if snippet.get('name') == '$SNIPPET_NAME':
        print(snippet['file'])
        sys.exit(0)
" 2>/dev/null)

if [ -z "$snippet_path" ]; then
    snippet_path="snippets/exa.md"
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
