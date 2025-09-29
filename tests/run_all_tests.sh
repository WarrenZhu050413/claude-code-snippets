#!/bin/bash

echo "========================================"
echo "Running All Snippet Tests"
echo "========================================"
echo

TOTAL_PASS=0
TOTAL_FAIL=0

# Run each test
for test_file in test_*.sh; do
    if [ -f "$test_file" ] && [ "$test_file" != "run_all_tests.sh" ]; then
        echo "Running $test_file..."
        ./"$test_file" > temp_output.txt 2>&1

        # Extract results
        if grep -q "ALL TESTS PASSED" temp_output.txt; then
            echo "  ✓ PASSED"
            ((TOTAL_PASS++))
        else
            echo "  ✗ FAILED"
            ((TOTAL_FAIL++))
            # Show which tests failed
            grep "✗ FAIL" temp_output.txt | head -5
        fi
        echo
    fi
done

rm -f temp_output.txt

echo "========================================"
echo "Overall Results:"
echo "  Tests Passed: $TOTAL_PASS"
echo "  Tests Failed: $TOTAL_FAIL"
if [ $TOTAL_FAIL -eq 0 ]; then
    echo "  Status: ✓ ALL SNIPPET TESTS PASSED"
else
    echo "  Status: ✗ SOME SNIPPET TESTS FAILED"
fi
echo "========================================"