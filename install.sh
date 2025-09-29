#!/bin/bash

# Snippet Installation Script for Claude Code
# This script interactively adds new snippets to the Claude Code snippet injector

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SNIPPETS_DIR="$HOME/.claude/snippets"
CONFIG_FILE="$SNIPPETS_DIR/snippets-config.json"
TESTS_DIR="$SNIPPETS_DIR/tests"
HTML_STYLE="$HOME/.claude/output-styles/html.md"

# Ensure directories exist
mkdir -p "$SNIPPETS_DIR"
mkdir -p "$TESTS_DIR"

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to validate regex
validate_regex() {
    local pattern=$1
    echo "test" | grep -qE "$pattern" 2>/dev/null
    return $?
}

# Function to check for duplicate patterns
check_duplicate() {
    local pattern=$1
    if [ -f "$CONFIG_FILE" ]; then
        # Check if pattern already exists
        if grep -q "\"pattern\".*\"$pattern\"" "$CONFIG_FILE" 2>/dev/null; then
            return 0  # Duplicate found
        fi
    fi
    return 1  # No duplicate
}

# Function to test pattern against examples
test_pattern() {
    local pattern=$1
    local test_string=$2

    if echo "$test_string" | grep -qiE "$pattern" 2>/dev/null; then
        return 0  # Match
    else
        return 1  # No match
    fi
}

# Function to create test file
create_test_file() {
    local snippet_name=$1
    local pattern=$2
    local test_file="$TESTS_DIR/test_${snippet_name}.sh"

    cat > "$test_file" << 'EOF'
#!/bin/bash

# Test for SNIPPET_NAME.md snippet
# Regex Pattern: PATTERN_PLACEHOLDER

echo "================================"
echo "Testing: SNIPPET_NAME.md"
echo "Pattern: PATTERN_DISPLAY"
echo "================================"
echo

# Test cases that SHOULD match
echo "✓ Should match:"
SHOULD_MATCH=(
TEST_CASES_MATCH
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
TEST_CASES_NO_MATCH
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
    exit 0
else
    echo "Status: ✗ SOME TESTS FAILED"
    exit 1
fi
echo "================================"
EOF

    # Replace placeholders
    sed -i '' "s/SNIPPET_NAME/${snippet_name}/g" "$test_file"
    sed -i '' "s/PATTERN_PLACEHOLDER/${pattern}/g" "$test_file"
    sed -i '' "s/PATTERN_DISPLAY/${pattern//\\/\\\\}/g" "$test_file"

    chmod +x "$test_file"
    echo "$test_file"
}

# Function to run tests using Claude subagent
run_tests_with_claude() {
    local snippet_name=$1
    local pattern=$2
    local test_file="$TESTS_DIR/test_${snippet_name}.sh"
    local html_output="/tmp/snippet_test_results.html"

    print_color "$BLUE" "🤖 Launching Claude subagent for comprehensive testing..."

    # Create a test prompt for Claude
    local claude_test_prompt="Test the snippet '$snippet_name' with pattern '$pattern'.
Run the test file at $test_file and verify:
1. The pattern matches appropriate test cases
2. The pattern correctly excludes non-matching cases
3. The snippet injector works with this configuration
4. Generate additional edge case tests

Provide a comprehensive test report."

    # Launch Claude subagent for testing
    local claude_output
    claude_output=$(claude -p "$claude_test_prompt" 2>&1)

    # Also run the shell test for concrete results
    local test_output
    local test_result

    if test_output=$("$test_file" 2>&1); then
        test_result="success"
    else
        test_result="failure"
    fi

    # Create HTML output
    cat > "$html_output" << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Snippet Test Results</title>
    <style>
        :root {
            --chinese-red: #8B0000;
            --chinese-gold: #FFD700;
            --jade-green: #00A86B;
            --ink-black: #2B2B2B;
            --paper-beige: #F5F5DC;
            --light-cream: #FAFAF0;
        }
        body {
            background: linear-gradient(135deg, var(--paper-beige) 0%, var(--light-cream) 100%);
            color: var(--ink-black);
            font-family: system-ui, -apple-system, sans-serif;
            margin: 0;
            padding: 20px;
            line-height: 1.6;
        }
        h1 {
            color: var(--chinese-red);
            border-bottom: 3px solid var(--chinese-gold);
            padding-bottom: 10px;
        }
        .success {
            color: var(--jade-green);
            font-weight: bold;
        }
        .failure {
            color: var(--chinese-red);
            font-weight: bold;
        }
        .test-output {
            background: white;
            border: 1px solid var(--chinese-gold);
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            font-family: monospace;
            white-space: pre-wrap;
        }
        .summary {
            background: linear-gradient(135deg, rgba(255, 215, 0, 0.1), white);
            border: 2px solid var(--chinese-gold);
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <h1>📝 Snippet Test Results</h1>
    <div class="summary">
        <h2>Test Summary for: <code>SNIPPET_NAME</code></h2>
        <p>Status: <span class="TEST_CLASS">TEST_STATUS</span></p>
    </div>
    <div class="test-output">TEST_OUTPUT</div>
</body>
</html>
HTML

    # Replace placeholders
    sed -i '' "s/SNIPPET_NAME/${snippet_name}/g" "$html_output"
    sed -i '' "s/TEST_STATUS/${test_result^^}/g" "$html_output"
    sed -i '' "s/TEST_CLASS/${test_result}/g" "$html_output"

    # Escape test output for HTML
    local escaped_output=$(echo "$test_output" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
    # Use a different delimiter for sed to avoid conflicts with forward slashes
    sed -i '' "s|TEST_OUTPUT|${escaped_output}|g" "$html_output"

    # Open the HTML in browser
    if command -v open &> /dev/null; then
        open "$html_output"
    fi

    echo "$test_output"
    return $([ "$test_result" = "success" ] && echo 0 || echo 1)
}

# Function to add snippet to config
add_to_config() {
    local snippet_name=$1
    local pattern=$2

    # Backup existing config
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    fi

    # Create or update config
    if [ ! -f "$CONFIG_FILE" ]; then
        # Create new config
        cat > "$CONFIG_FILE" << EOF
{
  "mappings": [
    {
      "pattern": "$pattern",
      "snippet": "${snippet_name}.md"
    }
  ]
}
EOF
    else
        # Add to existing config using Python for proper JSON handling
        python3 << EOF
import json

with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

new_mapping = {
    "pattern": "$pattern",
    "snippet": "${snippet_name}.md"
}

config['mappings'].append(new_mapping)

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
EOF
    fi
}

# Main installation flow
main() {
    print_color "$BLUE" "╔════════════════════════════════════════╗"
    print_color "$BLUE" "║   Claude Code Snippet Installer       ║"
    print_color "$BLUE" "╚════════════════════════════════════════╝"
    echo

    # Step 1: Get snippet name
    print_color "$YELLOW" "📝 Step 1: Snippet Name"
    read -p "What would you like to name this snippet? (e.g., docker, terraform): " snippet_name

    if [ -z "$snippet_name" ]; then
        print_color "$RED" "Error: Snippet name cannot be empty"
        exit 1
    fi

    # Check if snippet file already exists
    if [ -f "$SNIPPETS_DIR/${snippet_name}.md" ]; then
        print_color "$YELLOW" "Warning: ${snippet_name}.md already exists."
        read -p "Overwrite? (y/n): " overwrite
        if [ "$overwrite" != "y" ]; then
            print_color "$RED" "Aborted."
            exit 1
        fi
    fi

    # Step 2: Get snippet content
    echo
    print_color "$YELLOW" "📄 Step 2: Snippet Content"
    echo "Enter the snippet content (press Ctrl+D when done):"
    snippet_content=$(cat)

    # Step 3: Get pattern
    echo
    print_color "$YELLOW" "🔍 Step 3: Regex Pattern"
    echo "What regex pattern should trigger this snippet?"
    echo "Example: \\b(docker|container|dockerfile)\\b"
    read -p "Pattern: " pattern

    # Validate regex
    if ! validate_regex "$pattern"; then
        print_color "$RED" "Error: Invalid regex pattern"
        exit 1
    fi

    # Check for duplicates
    if check_duplicate "$pattern"; then
        print_color "$YELLOW" "Warning: This pattern already exists in the configuration."
        read -p "Continue anyway? (y/n): " continue_dup
        if [ "$continue_dup" != "y" ]; then
            print_color "$RED" "Aborted."
            exit 1
        fi
    fi

    # Step 4: Test pattern with examples
    echo
    print_color "$YELLOW" "🧪 Step 4: Pattern Testing"
    echo "Let's test your pattern. Enter test strings (empty line to finish):"

    local should_match=()
    local should_not_match=()

    while true; do
        read -p "Test string (or press Enter to continue): " test_str
        [ -z "$test_str" ] && break

        if test_pattern "$pattern" "$test_str"; then
            print_color "$GREEN" "  ✓ Matches: $test_str"
            should_match+=("\"$test_str\"")
        else
            print_color "$RED" "  ✗ No match: $test_str"
            should_not_match+=("\"$test_str\"")
        fi
    done

    # Step 5: Preview
    echo
    print_color "$YELLOW" "👁️ Step 5: Preview"
    echo "--- Configuration Entry ---"
    echo "{
  \"pattern\": \"$pattern\",
  \"snippet\": \"${snippet_name}.md\"
}"
    echo
    echo "--- Snippet Content ---"
    echo "$snippet_content"
    echo

    # Step 6: Create test file
    print_color "$YELLOW" "📋 Step 6: Creating Tests"
    test_file=$(create_test_file "$snippet_name" "$pattern")

    # Add test cases to test file
    match_cases=$(printf "    %s\n" "${should_match[@]}")
    no_match_cases=$(printf "    %s\n" "${should_not_match[@]}")
    sed -i '' "s/TEST_CASES_MATCH/${match_cases}/g" "$test_file"
    sed -i '' "s/TEST_CASES_NO_MATCH/${no_match_cases}/g" "$test_file"

    print_color "$GREEN" "✓ Test file created: $test_file"

    # Step 7: Save snippet file (temporarily for testing)
    echo "$snippet_content" > "$SNIPPETS_DIR/${snippet_name}.md"

    # Step 8: Run tests
    echo
    print_color "$YELLOW" "🚀 Step 7: Running Tests (with Claude subagent)"
    if run_tests_with_claude "$snippet_name" "$pattern"; then
        print_color "$GREEN" "✓ All tests passed!"
    else
        print_color "$RED" "✗ Some tests failed. Please review."
        read -p "Continue anyway? (y/n): " continue_failed
        if [ "$continue_failed" != "y" ]; then
            # Cleanup
            rm -f "$SNIPPETS_DIR/${snippet_name}.md"
            rm -f "$test_file"
            print_color "$RED" "Aborted. Cleaned up temporary files."
            exit 1
        fi
    fi

    # Step 9: Final confirmation
    echo
    print_color "$YELLOW" "✅ Step 8: Final Confirmation"
    echo "Ready to add '${snippet_name}' snippet with pattern: $pattern"
    read -p "Proceed with installation? (y/n): " confirm

    if [ "$confirm" != "y" ]; then
        # Cleanup
        rm -f "$SNIPPETS_DIR/${snippet_name}.md"
        rm -f "$test_file"
        print_color "$RED" "Installation cancelled. Cleaned up temporary files."
        exit 1
    fi

    # Step 10: Install
    add_to_config "$snippet_name" "$pattern"

    print_color "$GREEN" "🎉 Success! Snippet '${snippet_name}' has been installed."
    print_color "$GREEN" "Files created:"
    print_color "$GREEN" "  - $SNIPPETS_DIR/${snippet_name}.md"
    print_color "$GREEN" "  - $test_file"
    print_color "$GREEN" "  - Updated: $CONFIG_FILE"

    echo
    print_color "$BLUE" "To test your new snippet, try:"
    print_color "$BLUE" "  echo 'your test text' | claude"
}

# Run main function
main "$@"