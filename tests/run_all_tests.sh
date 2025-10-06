#!/bin/bash
# Run all snippet tests

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$TESTS_DIR"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║         Claude Snippets - Comprehensive Test Suite                 ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

TOTAL_PASSED=0
TOTAL_FAILED=0
TESTS_RUN=0

# Get all test files
TEST_FILES=($(ls -1 *_test.sh 2>/dev/null | sort))

if [ ${#TEST_FILES[@]} -eq 0 ]; then
    echo "❌ No test files found in $TESTS_DIR"
    exit 1
fi

echo "Found ${#TEST_FILES[@]} test suites"
echo ""

# Run each test
for test_file in "${TEST_FILES[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running: $test_file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if bash "$test_file"; then
        ((TOTAL_PASSED++))
    else
        ((TOTAL_FAILED++))
        echo "⚠️  Test suite failed: $test_file"
    fi

    ((TESTS_RUN++))
    echo ""
done

# Summary
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                        FINAL SUMMARY                                ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Test Suites Run:    $TESTS_RUN"
echo "✅ Passed:          $TOTAL_PASSED"
echo "❌ Failed:          $TOTAL_FAILED"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo "🎉 🎉 🎉  ALL TESTS PASSED!  🎉 🎉 🎉"
    exit 0
else
    echo "⚠️  $TOTAL_FAILED test suite(s) failed"
    exit 1
fi
