# Read Snippets Command

Parse $ARGUMENTS for:
- Optional name filter (e.g., "docker", "mail")
- Format: --json, --markdown, --html (default: html)

## Execute CLI

```bash
cd ~/.claude/snippets && ./snippets-cli.py list \
  ${name:+$name} \
  --show-content \
  --show-stats \
  --format json
```

## Format Output

### HTML Format (default)

Generate HTML using the template below and open in browser:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Claude Snippets</title>
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
        <strong>Enabled:</strong> {{ENABLED}} |
        <strong>Configuration:</strong> ~/.claude/snippets/config.json
    </div>

    <input type="text" class="search-box" placeholder="🔍 Search snippets by pattern or file name..." onkeyup="filterTable()">

    <table id="snippetsTable">
        <thead>
            <tr>
                <th>Name</th>
                <th>Pattern (Regex)</th>
                <th>Alternatives</th>
                <th>Status</th>
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

For each snippet, generate a row:
```html
<tr>
    <td><span class="file-name">{{NAME}}</span></td>
    <td><code class="pattern">{{PATTERN}}</code></td>
    <td><span class="alt-count">{{ALTERNATIVES}}</span></td>
    <td>{{STATUS}}</td>
    <td>
        <span class="collapsible" onclick="toggleContent(this)">📄 View</span>
        <div class="content">{{CONTENT}}</div>
    </td>
</tr>
```

Replace:
- `{{TOTAL_SNIPPETS}}` - Total count
- `{{ENABLED}}` - Enabled count
- `{{TABLE_ROWS}}` - All snippet rows
- `{{NAME}}` - Snippet name
- `{{PATTERN}}` - HTML-escaped pattern
- `{{ALTERNATIVES}}` - Count of alternatives
- `{{STATUS}}` - ✓ or ✗
- `{{CONTENT}}` - HTML-escaped content

Save HTML to `/tmp/claude_snippets.html` and open with `open`.

### JSON Format

Output the raw JSON from CLI.

**If a specific snippet name was requested**, after showing the JSON, display:
```
Regex pattern: {{PATTERN}}
```

### Markdown Format

Generate markdown table:
```
| Name | Pattern | Alternatives | Status |
|------|---------|--------------|--------|
| docker | \b(docker|container)\b | 2 | ✓ |
```

**If a specific snippet name was requested**, after showing the table, display:
```
Regex pattern: {{PATTERN}}
```

## Error Handling

- If no snippets found: "No snippets configured. Use /snippets/create-snippet to add one."
- If name filter finds nothing: "Snippet '{name}' not found."
- If CLI fails: Show error message from JSON output.