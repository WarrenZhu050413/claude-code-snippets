#!/usr/bin/env python3
import json
import sys
import re
from pathlib import Path

# All paths relative to snippets directory
SNIPPETS_DIR = Path(__file__).parent
CONFIG_PATH = SNIPPETS_DIR / 'config.json'

try:
    # Read the hook input
    input_data = json.load(sys.stdin)
    prompt = input_data.get('prompt', '')

    # Load config
    with open(CONFIG_PATH) as f:
        config = json.load(f)

    # Check for matches (all patterns are regex)
    matched_snippets = []
    for mapping in config['mappings']:
        # Skip disabled snippets
        if not mapping.get('enabled', True):
            continue

        pattern = mapping['pattern']

        # All patterns are treated as regex with case-insensitive matching
        if re.search(pattern, prompt, re.IGNORECASE):
            # Store snippet files array and separator
            snippet_files = mapping['snippet']  # Now always an array
            separator = mapping.get('separator', '\n')
            matched_snippets.append((snippet_files, separator))

    # Remove duplicates while preserving order
    seen = set()
    unique_snippets = []
    for snippet_tuple in matched_snippets:
        key = (tuple(snippet_tuple[0]), snippet_tuple[1])
        if key not in seen:
            seen.add(key)
            unique_snippets.append(snippet_tuple)
    matched_snippets = unique_snippets

    # Load and append snippets
    if matched_snippets:
        additional_context = []
        for snippet_files, separator in matched_snippets:
            # Load all files for this snippet and join with separator
            file_contents = []
            for snippet_file in snippet_files:
                snippet_path = SNIPPETS_DIR / snippet_file
                if snippet_path.exists():
                    with open(snippet_path) as f:
                        content = f.read()
                        file_contents.append(content)

            # Join files with separator and add to context
            if file_contents:
                combined_content = separator.join(file_contents)
                additional_context.append(combined_content)

        if additional_context:
            # Return JSON with additional context
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": "\n".join(additional_context)
                }
            }
            print(json.dumps(output))

except Exception as e:
    # Log error to stderr for debugging
    print(f"Hook error: {e}", file=sys.stderr)
    # Exit gracefully - don't block the prompt
    pass

sys.exit(0)