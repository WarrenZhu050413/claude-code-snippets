#!/bin/bash

# Test for codex.md snippet
# Regex Pattern: \b(codex|cdx)\b

echo "================================"
echo "Testing: codex.md"
echo "Pattern: \\b(codex|cdx)\\b"
echo "================================"
echo

# Test cases that SHOULD match
echo "✓ Should match:"
SHOULD_MATCH=(
    "codex"
    "Codex"
    "CODEX"
    "use codex"
    "codex is great"
    "I need codex help"
    "cdx"
    "CDX"
    "try cdx"
    "cdx search"
)

PASS=0
FAIL=0

for test in "${SHOULD_MATCH[@]}"; do
    printf "  %-30s" "'$test':"
    if echo "{\"prompt\": \"$test\"}" | python3 ../snippet-injector.py 2>/dev/null | grep -q "hookSpecificOutput"; then
        echo "✓ PASS"
        ((PASS++))
    else
        echo "✗ FAIL"
        ((FAIL++))
    fi
done

echo
echo "✗ Should NOT match:"
SHOULD_NOT_MATCH=(
    "codexing"
    "codexed"
    "mycodex"
    "codextest"
    "cdxtest"
    "testcdx"
    "codex123"
)

for test in "${SHOULD_NOT_MATCH[@]}"; do
    printf "  %-30s" "'$test':"
    if echo "{\"prompt\": \"$test\"}" | python3 ../snippet-injector.py 2>/dev/null | grep -q "hookSpecificOutput"; then
        echo "✗ FAIL (matched)"
        ((FAIL++))
    else
        echo "✓ PASS"
        ((PASS++))
    fi
done

echo
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
    echo "Status: ✓ ALL TESTS PASSED"
else
    echo "Status: ✗ SOME TESTS FAILED"
fi
echo "================================"