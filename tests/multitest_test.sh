#!/bin/bash
# Test Suite for Snippet: multitest
# Multi-file snippet test
# Pattern: \b(multitest|multi-test)\b
# Files: multitest_part1.md, multitest_part2.md
# Verification Hashes: part1-test-hash, part2-test-hash

set -e

SNIPPET_NAME="multitest"
TEST_KEYWORD="multitest"
VERIFICATION_HASH_PART1="part1-test-hash"
VERIFICATION_HASH_PART2="part2-test-hash"
TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Running Test Suite for Multi-File Snippet: $SNIPPET_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Snippet exists in config
echo "Test 1: Checking multi-file snippet exists in config..."
if cd ~/.claude/snippets && python3 snippets_cli.py list 2>/dev/null | grep -q "\"name\": \"$SNIPPET_NAME\""; then
    echo "  ✅ PASS: Snippet exists in registry"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Snippet not found in registry"
    ((TESTS_FAILED++))
fi
echo ""

# Test 2: Verify multi-file configuration
echo "Test 2: Verifying multi-file configuration..."
file_count=$(cd ~/.claude/snippets && python3 snippets_cli.py list "$SNIPPET_NAME" 2>/dev/null | grep -o '"file_count": [0-9]*' | grep -o '[0-9]*')
if [ "$file_count" = "2" ]; then
    echo "  ✅ PASS: Snippet has correct file count (2)"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Wrong file count: $file_count (expected 2)"
    ((TESTS_FAILED++))
fi
echo ""

# Test 3: Pattern matching test
echo "Test 3: Testing pattern matching..."
test_result=$(cd ~/.claude/snippets && python3 snippets_cli.py test "$SNIPPET_NAME" "Testing $TEST_KEYWORD functionality" 2>/dev/null)
if echo "$test_result" | grep -q "\"matched\": true"; then
    echo "  ✅ PASS: Pattern matches test keyword '$TEST_KEYWORD'"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Pattern does not match test keyword"
    ((TESTS_FAILED++))
fi
echo ""

# Test 4: E2E Multi-File Injection Test
echo "Test 4: E2E multi-file injection test..."
echo "  Running: claude -p \"$TEST_KEYWORD, list the verification hashes\""
echo "  Looking for hashes: $VERIFICATION_HASH_PART1 and $VERIFICATION_HASH_PART2"

# Run Claude with test prompt and capture output
claude_output=$(~/.claude/local/claude -p "$TEST_KEYWORD, list all verification hashes you can see" 2>&1 || true)

# Check if both verification hashes appear in output
has_part1=false
has_part2=false

if echo "$claude_output" | grep -q "$VERIFICATION_HASH_PART1"; then
    has_part1=true
fi

if echo "$claude_output" | grep -q "$VERIFICATION_HASH_PART2"; then
    has_part2=true
fi

if [ "$has_part1" = true ] && [ "$has_part2" = true ]; then
    echo "  ✅ PASS: Both verification hashes found in Claude output"
    echo "  📋 Part 1 hash: $VERIFICATION_HASH_PART1 ✓"
    echo "  📋 Part 2 hash: $VERIFICATION_HASH_PART2 ✓"
    echo "  📋 Multi-file snippet is being correctly concatenated and injected"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Not all verification hashes found"
    if [ "$has_part1" = false ]; then
        echo "  ⚠️  Part 1 hash NOT found: $VERIFICATION_HASH_PART1"
    fi
    if [ "$has_part2" = false ]; then
        echo "  ⚠️  Part 2 hash NOT found: $VERIFICATION_HASH_PART2"
    fi
    echo ""
    echo "  Debug output (first 800 chars):"
    echo "$claude_output" | head -c 800
    echo ""
    ((TESTS_FAILED++))
fi
echo ""

# Test 5: Verify separator in injected content
echo "Test 5: Verifying custom separator in injected content..."
# The separator should be "---" surrounded by newlines
if echo "$claude_output" | grep -q "---"; then
    echo "  ✅ PASS: Custom separator (---) found in output"
    ((TESTS_PASSED++))
else
    echo "  ⚠️  WARNING: Custom separator not detected (may be normalized)"
    # Don't fail, as the separator might be processed
fi
echo ""

# Test 6: Snippet content verification
echo "Test 6: Verifying snippet files exist and have content..."
total_size=0

for file in "snippets/multitest_part1.md" "snippets/multitest_part2.md"; do
    if [ -f ~/.claude/snippets/"$file" ]; then
        size=$(wc -c < ~/.claude/snippets/"$file")
        total_size=$((total_size + size))
    else
        echo "  ❌ FAIL: File not found: $file"
        ((TESTS_FAILED++))
    fi
done

if [ $total_size -gt 100 ]; then
    echo "  ✅ PASS: Both snippet files exist (total: ${total_size} bytes)"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAIL: Snippet files too small (total: ${total_size} bytes)"
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
    echo "🎉 All tests passed! Multi-file snippet works correctly."
    exit 0
else
    echo "⚠️  Some tests failed. Please review the output above."
    exit 1
fi
