#!/bin/bash

# Test for gcal.md snippet
# Regex Pattern: \b(gcal|g-cal|google\s*calendar|calendar|event|schedule|appointment)\b

echo "================================"
echo "Testing: gcal.md"
echo "Pattern: \\b(gcal|g-cal|google\\s*calendar|calendar|event|schedule|appointment)\\b"
echo "================================"
echo

# Test cases that SHOULD match
echo "✓ Should match:"
SHOULD_MATCH=(
    "gcal"
    "Gcal"
    "GCAL"
    "check gcal"
    "g-cal"
    "G-cal"
    "G-CAL"
    "google calendar"
    "Google Calendar"
    "Google calendar"
    "GOOGLE CALENDAR"
    "googlecalendar"
    "calendar"
    "Calendar"
    "CALENDAR"
    "my calendar"
    "event"
    "Event"
    "EVENT"
    "new event"
    "schedule"
    "Schedule"
    "SCHEDULE"
    "my schedule"
    "appointment"
    "Appointment"
    "APPOINTMENT"
    "book appointment"
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
    "gcaltest"
    "testgcal"
    "mycalendar"
    "calendars"
    "calendaring"
    "events"
    "eventful"
    "eventual"
    "schedules"
    "scheduled"
    "scheduling"
    "scheduler"
    "appointments"
    "appointing"
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