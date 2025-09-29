#!/bin/bash

# Test for style.md snippet
# Regex Pattern: \bSTYLE\b (whole word anywhere)

echo "================================"
echo "Testing: style.md"
echo "Pattern: \\bSTYLE\\b (whole word)"
echo "================================"
echo

# Test cases that SHOULD match
echo "✓ Should match (STYLE as whole word):"
SHOULD_MATCH=(
    "STYLE"
    "STYLE guide"
    "STYLE: update"
    "STYLE is important"
    "style"
    "style guide"
    "Style"
    "Style:"
    "STYLE help"
    "style format"
    "my STYLE"
    "the STYLE"
    "use STYLE"
    "Write STYLE"
    "follow the style"
    "writing style"
    "code STYLE"
    "check my style"
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
echo "✗ Should NOT match (not a whole word or wrong word):"
SHOULD_NOT_MATCH=(
    "STYLEtest"
    "mystyle"
    "MySTYLE"
    "search"
    "searching"
    "Search"
    "SEARCH"
    "research"
    "my search"
    "freestyle"
    "styling"
    "styled"
    "styles"
    "stylesheet"
    "hairstyle"
    "lifestyle"
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