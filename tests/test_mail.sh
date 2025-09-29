#!/bin/bash

# Test for mail.md snippet
# Regex Pattern: \b(email|mail|e-mail|message|inbox|send\s+(to|message))\b

echo "================================"
echo "Testing: mail.md"
echo "Pattern: \\b(email|mail|e-mail|message|inbox|send\\s+(to|message))\\b"
echo "================================"
echo

# Test cases that SHOULD match
echo "✓ Should match:"
SHOULD_MATCH=(
    "email"
    "Email"
    "EMAIL"
    "send email"
    "email me"
    "mail"
    "Mail"
    "check mail"
    "e-mail"
    "E-mail"
    "E-MAIL"
    "message"
    "Message"
    "new message"
    "inbox"
    "Inbox"
    "check inbox"
    "send to"
    "Send to"
    "send message"
    "Send Message"
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
    "gmail"
    "Gmail"
    "hotmail"
    "mailing"
    "mailed"
    "emails"
    "blackmail"
    "mailbox"
    "emailer"
    "messages"
    "messaging"
    "messaged"
    "inboxes"
    "sending"
    "sender"
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