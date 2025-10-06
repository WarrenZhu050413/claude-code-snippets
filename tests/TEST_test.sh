#!/bin/bash
# Test Suite for Snippet: TEST
# Generated: $(date)
# Pattern: \b(TEST|test\s*thoroughly|comprehensive\s*test|testing\s*protocol|regression\s*test)\b
# Verification Hash: 746f660e538edb27

set -e

SNIPPET_NAME="TEST"
TEST_KEYWORD="TEST"
VERIFICATION_HASH="746f660e538edb27"
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

# Test 3: Additional pattern tests
echo "Test 3: Testing alternative pattern matches..."
alt_test1=$(cd ~/.claude/snippets && python3 snippets_cli.py test "$SNIPPET_NAME" "I need to test thoroughly" 2>/dev/null)
alt_test2=$(cd ~/.claude/snippets && python3 snippets_cli.py test "$SNIPPET_NAME" "comprehensive test needed" 2>/dev/null)
alt_test3=$(cd ~/.claude/snippets && python3 snippets_cli.py test "$SNIPPET_NAME" "testing protocol" 2>/dev/null)

matches=0
echo "$alt_test1" | grep -q "\"matched\": true" && ((matches++))
echo "$alt_test2" | grep -q "\"matched\": true" && ((matches++))
echo "$alt_test3" | grep -q "\"matched\": true" && ((matches++))

if [ "$matches" -eq 3 ]; then
    echo "  ✅ PASS: All alternative patterns matched (3/3)"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Some alternative patterns failed ($matches/3)"
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
        print(snippet['files'][0] if 'files' in snippet else snippet.get('file', ''))
        break
" 2>/dev/null)

if [ -n "$snippet_content" ] && [ -f ~/.claude/snippets/"$snippet_content" ]; then
    content_size=$(wc -c < ~/.claude/snippets/"$snippet_content")
    if [ "$content_size" -gt 1000 ]; then
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

# Test 5: Verification hash presence
echo "Test 5: Checking verification hash in content..."
if [ -f ~/.claude/snippets/"$snippet_content" ] && grep -q "$VERIFICATION_HASH" ~/.claude/snippets/"$snippet_content"; then
    echo "  ✅ PASS: Verification hash found in snippet content"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Verification hash not found in content"
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
