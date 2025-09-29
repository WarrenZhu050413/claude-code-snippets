#!/usr/bin/env python3
import json
import sys
import re
from pathlib import Path

# All paths relative to snippets directory
SNIPPETS_DIR = Path(__file__).parent
CONFIG_PATH = SNIPPETS_DIR / 'snippets-config.json'

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
        pattern = mapping['pattern']

        # All patterns are treated as regex with case-insensitive matching
        if re.search(pattern, prompt, re.IGNORECASE):
            matched_snippets.append(mapping['snippet'])

    # Remove duplicates while preserving order
    matched_snippets = list(dict.fromkeys(matched_snippets))

    # Load and append snippets
    if matched_snippets:
        additional_context = []
        for snippet_file in matched_snippets:
            snippet_path = SNIPPETS_DIR / snippet_file
            if snippet_path.exists():
                with open(snippet_path) as f:
                    content = f.read()
                    additional_context.append(content)

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