# Read Snippets Command

<input>
## Parse Arguments
Process $ARGUMENTS to extract:
- Optional filter keyword (e.g., "mail", "html")
- Format flag (--json, --markdown, --html) - defaults to HTML

## Example Inputs
- `/snippets/read-snippet` (shows all snippets in HTML)
- `/snippets/read-snippet mail` (filter for mail-related snippets)
- `/snippets/read-snippet --json` (output as JSON)
- `/snippets/read-snippet --markdown` (output as markdown table)

## Read Context
Read the snippet configuration and files:
- ~/.claude/snippets/snippets-config.json
- ~/.claude/snippets/*.md (all snippet files)

## Build Context
- Parse all snippet mappings
- Read snippet file contents
- Calculate pattern statistics
- Organize by category/type
</input>

<workflow>
## Phase 1: Read Configuration
Read snippets-config.json to get all mappings:
- Pattern regex
- Associated snippet file
- Extract metadata

## Phase 2: Read Snippet Files
For each snippet file:
- Read the content
- Count lines
- Extract description if available
- Note file size

## Phase 3: Analyze Patterns
For each pattern:
- Count alternatives (e.g., "mail|email" = 2 alternatives)
- Identify word boundaries
- Check complexity
- List example matches

## Phase 4: Generate Output
Based on format flag:
- HTML: Create interactive table with collapsibles
- JSON: Return structured data
- Markdown: Simple table format

## Phase 5: Open HTML (if HTML format)
Write HTML file and open in browser

## Tools to Use:
- Read: Get snippets-config.json and snippet files
- Write: Generate HTML output file
- Bash: Open HTML in browser
</workflow>

<output>
## Format
For HTML output (default):
- Compact, information-dense table
- Pattern regex with syntax highlighting
- Snippet file preview (collapsible)
- Statistics and metadata
- Search/filter functionality

For JSON output:
```json
{
  "snippets": [
    {
      "pattern": "\\b(mail|email)\\b",
      "snippet": "mail.md",
      "alternatives": 2,
      "content_lines": 15,
      "content_preview": "..."
    }
  ]
}
```

For Markdown output:
```
| Pattern | Snippet File | Alternatives | Lines |
|---------|--------------|--------------|-------|
| \b(mail\|email)\b | mail.md | 2 | 15 |
```

## Example Output (HTML):
Opens browser with interactive table showing:
- 5 snippets configured
- Patterns with regex visualization
- Click to expand snippet content
- Statistics: total patterns, average complexity
- Quick search/filter box
</output>

<clarification>
## When to Ask Questions
Clarify when:
- Filter keyword matches multiple snippets ambiguously
- Snippet files are missing but referenced in config
- Format flag is unrecognized

## Example Questions:
- "Found 3 snippets matching 'cal'. Show all or filter further?"
- "Warning: 'docker.md' referenced in config but file not found. Continue?"
- "Format '--table' not recognized. Did you mean --markdown?"

## How to Ask
- Present options clearly
- Show what was found
- Suggest best match
</clarification>

---

## HTML Template

Use this template for generating the HTML output. Replace the table rows with actual data from snippets-config.json:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Claude Snippets List</title>
    <style>
        :root {
            --chinese-red: #8B0000;
            --chinese-gold: #FFD700;
            --paper-beige: #F5F5DC;
            --light-cream: #FFFEF0;
            --ink-black: #1a1a1a;
        }

        body {
            background: linear-gradient(135deg, var(--paper-beige) 0%, var(--light-cream) 100%);
            color: var(--ink-black);
            margin: 0;
            padding: 8px;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            font-size: 14px;
            line-height: 1.2;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        h1 {
            font-size: 24px;
            font-weight: 900;
            margin: 4px 0;
            padding: 6px 4px;
            background: linear-gradient(135deg, var(--chinese-red), #CD5C5C);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .stats {
            background: linear-gradient(135deg, rgba(255, 215, 0, 0.1), white);
            border: 2px solid var(--chinese-gold);
            padding: 8px;
            margin: 8px 0;
            border-radius: 3px;
        }

        .stats strong {
            color: var(--chinese-red);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 8px 0;
            background: white;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        th, td {
            border: 1px solid rgba(139, 0, 0, 0.2);
            padding: 6px;
            text-align: left;
        }

        th {
            background: rgba(139, 0, 0, 0.1);
            font-weight: 600;
            color: var(--chinese-red);
        }

        .pattern {
            font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
            background: rgba(245, 245, 220, 0.3);
            padding: 2px 4px;
            font-size: 12px;
            border: 1px solid rgba(139, 0, 0, 0.1);
            border-radius: 2px;
        }

        .collapsible {
            cursor: pointer;
            color: var(--chinese-red);
            font-weight: 600;
            user-select: none;
        }

        .collapsible:hover {
            text-decoration: underline;
        }

        .content {
            display: none;
            padding: 8px;
            background: rgba(245, 245, 220, 0.2);
            margin-top: 4px;
            font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
            font-size: 11px;
            white-space: pre-wrap;
            border-left: 3px solid var(--chinese-gold);
            max-height: 300px;
            overflow-y: auto;
        }

        .content.show {
            display: block;
        }

        .search-box {
            width: 100%;
            padding: 8px;
            margin: 8px 0;
            border: 2px solid var(--chinese-gold);
            font-size: 14px;
            border-radius: 3px;
        }

        .search-box:focus {
            outline: none;
            border-color: var(--chinese-red);
        }

        .alt-count {
            background: rgba(139, 0, 0, 0.1);
            padding: 2px 6px;
            border-radius: 2px;
            font-weight: 600;
            color: var(--chinese-red);
        }

        .file-name {
            font-weight: 600;
            color: var(--ink-black);
        }

        tr:hover {
            background: rgba(255, 215, 0, 0.05);
        }
    </style>
</head>
<body>
    <h1>📋 Claude Code Snippets</h1>

    <div class="stats">
        <strong>Total Snippets:</strong> {{TOTAL_SNIPPETS}} |
        <strong>Total Patterns:</strong> {{TOTAL_PATTERNS}} |
        <strong>Configuration:</strong> ~/.claude/snippets/snippets-config.json
    </div>

    <input type="text" class="search-box" placeholder="🔍 Search snippets by pattern or file name..." onkeyup="filterTable()">

    <table id="snippetsTable">
        <thead>
            <tr>
                <th>Pattern (Regex)</th>
                <th>Snippet File</th>
                <th>Alternatives</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            {{TABLE_ROWS}}
        </tbody>
    </table>

    <script>
        function toggleContent(element) {
            const content = element.nextElementSibling;
            content.classList.toggle('show');
        }

        function filterTable() {
            const input = document.querySelector('.search-box');
            const filter = input.value.toLowerCase();
            const table = document.getElementById('snippetsTable');
            const rows = table.getElementsByTagName('tr');

            for (let i = 1; i < rows.length; i++) {
                const row = rows[i];
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(filter) ? '' : 'none';
            }
        }
    </script>
</body>
</html>
```

## Row Template

For each snippet in the config, generate a row like this:

```html
<tr>
    <td><code class="pattern">{{PATTERN}}</code></td>
    <td><span class="file-name">{{SNIPPET_FILE}}</span></td>
    <td><span class="alt-count">{{ALTERNATIVES}}</span></td>
    <td>
        <span class="collapsible" onclick="toggleContent(this)">📄 View Content</span>
        <div class="content">{{SNIPPET_CONTENT}}</div>
    </td>
</tr>
```

Replace:
- `{{TOTAL_SNIPPETS}}` - Total number of snippets
- `{{TOTAL_PATTERNS}}` - Total number of patterns
- `{{TABLE_ROWS}}` - All generated rows
- `{{PATTERN}}` - The regex pattern (HTML escaped)
- `{{SNIPPET_FILE}}` - The snippet filename
- `{{ALTERNATIVES}}` - Number of alternatives in pattern (count `|` separators + 1)
- `{{SNIPPET_CONTENT}}` - First 500 chars of snippet content (or full if shorter)