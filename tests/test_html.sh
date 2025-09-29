#!/bin/bash

# Test for HTML.md snippet
# Regex Pattern: \bHTML\b (whole word anywhere)

echo "================================"
echo "Testing: HTML.md"
echo "Pattern: \\bHTML\\b (whole word)"
echo "================================"
echo

# Test cases that SHOULD match
echo "✓ Should match (HTML as whole word):"
SHOULD_MATCH=(
    "HTML"
    "HTML code"
    "HTML: create"
    "HTML is great"
    "html"
    "html code"
    "Html"
    "HTML:"
    "HTML help"
    "HTML tutorial"
    "test HTML"
    "the HTML"
    "my HTML"
    "Use HTML"
    "Write HTML"
    "some HTML code"
    "learn HTML"
    "HTML/CSS"
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
echo "✗ Should NOT match (not a whole word):"
SHOULD_NOT_MATCH=(
    "HTMLtest"
    "htmlcode"
    "MyHTML"
    "XHTML"
    "DHTML"
    "HTMLElement"
    "isHTML"
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