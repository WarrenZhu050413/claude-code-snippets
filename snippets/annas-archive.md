# Anna's Archive API - Developer Guide

**VERIFICATION_HASH:** `504782213aca5a5e`

## Usage Guidelines

**IMPORTANT: Follow these rules when helping users download from Anna's Archive:**

1. **Default to PDF format**: Always search with `ext=pdf` parameter unless the user explicitly requests another format
2. **Handle missing PDFs**: If no PDFs are available for the requested book:
   - List all available formats to the user
   - Ask which format they prefer
3. **Edition selection**: When multiple editions exist:
   - Prioritize: (a) Newest publication year, (b) Reputable publisher (e.g., O'Reilly, MIT Press, Springer, Cambridge, Oxford, Pearson, Wiley, Academic Press)
   - If uncertain which edition is best, present options with: title, author, year, publisher, file format
   - Ask the user to choose
4. **Search strategy**: Filter searches with `ext=pdf` by default to show only PDF results first

## Quick Reference

**Base URL:** `https://annas-archive.org`

**API Key:** `73VSRLTEXTxDPW6zpWhvXjrUd1NQf`

## Search API

### Endpoint
```
GET /search
```

### Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `q` | string | Search query | `chrome extensions` |
| `index` | string | Search index: `""` (books) or `journals` | `journals` |
| `page` | integer | Page number (1-based) | `1` |
| `sort` | string | Sort: `""`, `newest`, `oldest`, `largest`, `smallest` | `newest` |
| `content` | string[] | Content type filter (multiple allowed) | `book_nonfiction` |
| `ext` | string[] | File extension filter (multiple) | `pdf`, `epub` |
| `lang` | string[] | Language code filter (multiple) | `en`, `zh` |

### Content Types

**Include:** Use `content={type}`
- `book_nonfiction` - 📘 Book (non-fiction)
- `book_fiction` - 📕 Book (fiction)
- `book_unknown` - 📗 Book (unknown)
- `magazine` - 📰 Magazine
- `book_comic` - 💬 Comic book
- `standards_document` - 📝 Standards document
- `musical_score` - 🎶 Musical score

**Exclude:** Use `content=anti__{type}`
- `anti__book_nonfiction` - Exclude non-fiction
- `anti__book_fiction` - Exclude fiction
- etc.

### File Extensions (ext)
`pdf`, `epub`, `zip`, `mobi`, `fb2`, `cbr`, `djvu`, `cbz`, `txt`, `azw3`, `doc`, `lit`, `rtf`, `rar`, `htm`, `html`, `mht`, `docx`, `lrf`, `jpg`, `opf`, `chm`, `azw`, `pdb`

### Languages (lang)
`en` (English), `hi` (Hindi), `fr` (French), `zh` (Chinese), `ru` (Russian), `de` (German), `ja` (Japanese), `es` (Spanish), `la` (Latin), `id` (Indonesian), `pt` (Portuguese), `it` (Italian)

### Search Examples

```bash
# Basic search (DEFAULT: always include ext=pdf)
https://annas-archive.org/search?q=chrome%20extensions&ext=pdf

# Filter by content type (non-fiction PDFs only)
https://annas-archive.org/search?q=python&content=book_nonfiction&ext=pdf

# Exclude fiction books (PDFs only)
https://annas-archive.org/search?q=history&content=anti__book_fiction&ext=pdf

# Multiple file types (only if user explicitly requests non-PDF formats)
https://annas-archive.org/search?q=javascript&ext=pdf&ext=epub

# Filter by language (English PDFs only)
https://annas-archive.org/search?q=machine%20learning&lang=en&ext=pdf

# Search journals (PDFs preferred)
https://annas-archive.org/search?index=journals&q=neural%20networks&ext=pdf

# Combined filters with newest first (for edition selection)
https://annas-archive.org/search?q=rust&content=book_nonfiction&ext=pdf&lang=en&sort=newest&page=1
```

## Download API

### Endpoint
```
GET /dyn/api/fast_download.json
```

**Note:** Requires paid membership

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `md5` | ✅ Yes | MD5 hash of the file (32 hex characters) |
| `key` | ✅ Yes | Your membership API key |
| `path_index` | ❌ No | Collection index (0, 1, 2...) if file exists in multiple sources |
| `domain_index` | ❌ No | Download server index (0='Fast Partner Server #1', 1, 2...) |

### Response Format

**Success (200 or 204):**
```json
{
  "download_url": "https://cdn.example.org/.../book.epub",
  "account_fast_download_info": {
    "downloads_left": 24,
    "downloads_per_day": 25,
    "recently_downloaded_md5s": ["553efec5e886db996bb1363ffa391a92"]
  }
}
```

**Error:**
```json
{
  "download_url": null,
  "error": "Invalid md5"
}
```

### Download Examples

```bash
# Basic download
curl "https://annas-archive.org/dyn/api/fast_download.json?md5=553efec5e886db996bb1363ffa391a92&key=73VSRLTEXTxDPW6zpWhvXjrUd1NQf"

# Specify collection and server
curl "https://annas-archive.org/dyn/api/fast_download.json?md5=d6e1dc51a50726f00ec438af21952a45&key=73VSRLTEXTxDPW6zpWhvXjrUd1NQf&path_index=0&domain_index=0"
```

## Item Page

### Endpoint
```
GET /md5/{hash}
```

View detailed information page for a specific file.

**Example:**
```
https://annas-archive.org/md5/553efec5e886db996bb1363ffa391a92
```

Returns HTML page with:
- Title, author, publisher
- File details (size, format, language)
- Download options
- Preview/reader link

## Getting MD5 Hashes

### Method 1: Parse Search Results
Search returns HTML with links like:
```html
<a href="/md5/553efec5e886db996bb1363ffa391a92">Book Title</a>
```

Extract MD5 using regex: `/md5/([a-f0-9]{32})`

### Method 2: Use Unofficial Libraries
- **Python:** `annas-archive-api` by dheison0
- **JavaScript:** `archive_of_anna` by shetty-tejas
- **Dart:** `annas_archive_api` (pub.dev)

### Method 3: Web Scraping
```python
import requests
from bs4 import BeautifulSoup

response = requests.get("https://annas-archive.org/search?q=python")
soup = BeautifulSoup(response.text, 'html.parser')

for link in soup.select('a[href*="/md5/"]'):
    href = link['href']
    md5 = href.split('/md5/')[1].split('/')[0]
    print(f"MD5: {md5}")
```

## Handling Multiple Editions and Formats

### Edition Selection Strategy

When multiple editions of a book exist, use these criteria in order:

1. **Publisher reputation**: Prefer academic/technical publishers
   - Top tier: MIT Press, Cambridge, Oxford, Springer, IEEE
   - Professional: O'Reilly, Pearson, Wiley, Academic Press, Manning, Apress
   - University presses generally preferred over unknown publishers

2. **Publication year**: Choose the newest edition (use `sort=newest`)

3. **File format**: PDF > EPUB > MOBI > other formats (unless user specifies)

### When PDFs Are Not Available

If search with `ext=pdf` returns no results:

```python
# Step 1: Try PDF search first
pdf_results = search_annas_archive(query, ext='pdf')

if not pdf_results:
    # Step 2: Search without format filter
    all_results = search_annas_archive(query)

    # Step 3: Show available formats to user
    print("No PDFs available for this book.")
    print("Available formats:")
    for result in all_results[:5]:
        print(f"  - {result['title']} ({result['format']})")

    # Step 4: Ask user for preference
    user_choice = input("Which format would you like? ")
```

### Example: Multi-Edition Selection

```python
# Search with newest first
results = search_annas_archive('introduction to algorithms', sort='newest', ext='pdf')

# Parse editions
editions = []
for result in results:
    editions.append({
        'title': result['title'],
        'author': result['author'],
        'year': result['year'],
        'publisher': result['publisher'],
        'md5': result['md5']
    })

# Reputable publishers for computer science
reputable_publishers = [
    'MIT Press', 'Cambridge', 'Oxford', 'Springer', 'IEEE',
    "O'Reilly", 'Pearson', 'Wiley', 'Manning', 'Apress'
]

# Filter and rank
best_edition = None
for edition in editions:
    if any(pub.lower() in edition['publisher'].lower() for pub in reputable_publishers):
        best_edition = edition
        break

if best_edition:
    print(f"Selected: {best_edition['title']} ({best_edition['year']}) - {best_edition['publisher']}")
else:
    # If uncertain, ask user
    print("Multiple editions found:")
    for i, ed in enumerate(editions[:5]):
        print(f"{i+1}. {ed['title']} ({ed['year']}) - {ed['publisher']}")
    choice = input("Which edition? ")
```

## Complete Workflow Example

### Python Script with Auto-Save to ~/Desktop/AnnasArchive

```python
import requests
from bs4 import BeautifulSoup
import os
import urllib.parse

# Configuration
DOWNLOAD_DIR = os.path.expanduser("~/Desktop/AnnasArchive")
API_KEY = "73VSRLTEXTxDPW6zpWhvXjrUd1NQf"

# Ensure download directory exists
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

# 1. Search for books (ALWAYS default to PDF)
search_url = "https://annas-archive.org/search"
params = {
    'q': 'chrome extensions',
    'content': 'book_nonfiction',
    'ext': 'pdf',  # DEFAULT: Always search for PDFs first
    'lang': 'en',
    'sort': 'newest'  # For edition selection: prioritize newest
}
response = requests.get(search_url, params=params)
soup = BeautifulSoup(response.text, 'html.parser')

# 2. Extract MD5 hashes
md5_hashes = []
for link in soup.select('a[href*="/md5/"]'):
    href = link['href']
    if '/md5/' in href:
        md5 = href.split('/md5/')[1].split('/')[0]
        md5_hashes.append(md5)

# 3. Get download URL for first result
api_url = "https://annas-archive.org/dyn/api/fast_download.json"
download_params = {
    'md5': md5_hashes[0],
    'key': API_KEY
}
download_response = requests.get(api_url, params=download_params)
data = download_response.json()

if data.get('download_url'):
    download_url = data['download_url']

    # 4. Extract clean filename from URL
    # URL format: .../Title -- Author -- Year -- Publisher -- ISBN -- MD5 -- Anna's Archive.ext
    raw_filename = urllib.parse.unquote(download_url.split('/')[-1])

    # Clean filename - take title part before "--" or use MD5 as fallback
    if '--' in raw_filename:
        # Get title (first part before --)
        title = raw_filename.split('--')[0].strip()
        # Get extension
        ext = raw_filename.split('.')[-1]
        filename = f"{title}.{ext}"
    else:
        filename = f"{md5_hashes[0]}.pdf"

    # 5. Download to ~/Desktop/AnnasArchive
    output_path = os.path.join(DOWNLOAD_DIR, filename)

    print(f"Downloading: {filename}")
    print(f"Saving to: {output_path}")

    file_response = requests.get(download_url, stream=True)
    with open(output_path, 'wb') as f:
        for chunk in file_response.iter_content(chunk_size=8192):
            f.write(chunk)

    print(f"✓ Downloaded successfully to {output_path}")
    print(f"✓ Downloads remaining: {data['account_fast_download_info']['downloads_left']}/25")
else:
    print(f"Error: {data.get('error')}")
```

### Bash One-Liner with Auto-Save

```bash
# Download directly to ~/Desktop/AnnasArchive
MD5="bdd7adbb391ea84c5a23f95dbb8cc536"
API_KEY="73VSRLTEXTxDPW6zpWhvXjrUd1NQf"

# Get download URL and save to directory
mkdir -p ~/Desktop/AnnasArchive && \
DOWNLOAD_URL=$(curl -s "https://annas-archive.org/dyn/api/fast_download.json?md5=$MD5&key=$API_KEY" | python3 -c "import json, sys; print(json.load(sys.stdin).get('download_url', ''))") && \
FILENAME=$(echo "$DOWNLOAD_URL" | python3 -c "import sys, urllib.parse; url=sys.stdin.read().strip(); fname=urllib.parse.unquote(url.split('/')[-1]); print(fname.split('--')[0].strip() + '.' + fname.split('.')[-1])") && \
curl -L -o ~/Desktop/AnnasArchive/"$FILENAME" "$DOWNLOAD_URL" && \
echo "✓ Downloaded to ~/Desktop/AnnasArchive/$FILENAME"
```

### Complete Function for Reuse

```python
import requests
import os
import urllib.parse

def download_from_annas_archive(md5_hash, api_key="73VSRLTEXTxDPW6zpWhvXjrUd1NQf",
                                 download_dir="~/Desktop/AnnasArchive"):
    """
    Download a file from Anna's Archive using its MD5 hash.

    Args:
        md5_hash: MD5 hash of the file to download
        api_key: Your Anna's Archive API key
        download_dir: Directory to save files (default: ~/Desktop/AnnasArchive)

    Returns:
        dict: {'success': bool, 'filepath': str, 'message': str}
    """
    # Expand and create directory
    download_dir = os.path.expanduser(download_dir)
    os.makedirs(download_dir, exist_ok=True)

    # Get download URL from API
    api_url = "https://annas-archive.org/dyn/api/fast_download.json"
    params = {'md5': md5_hash, 'key': api_key}

    try:
        response = requests.get(api_url, params=params, timeout=10)
        data = response.json()

        if not data.get('download_url'):
            return {
                'success': False,
                'filepath': None,
                'message': f"Error: {data.get('error', 'No download URL')}"
            }

        download_url = data['download_url']

        # Extract clean filename
        raw_filename = urllib.parse.unquote(download_url.split('/')[-1])
        if '--' in raw_filename:
            title = raw_filename.split('--')[0].strip()
            ext = raw_filename.split('.')[-1]
            filename = f"{title}.{ext}"
        else:
            filename = f"{md5_hash}.pdf"

        output_path = os.path.join(download_dir, filename)

        # Download file
        file_response = requests.get(download_url, stream=True, timeout=30)
        file_response.raise_for_status()

        with open(output_path, 'wb') as f:
            for chunk in file_response.iter_content(chunk_size=8192):
                f.write(chunk)

        downloads_left = data['account_fast_download_info']['downloads_left']

        return {
            'success': True,
            'filepath': output_path,
            'message': f"Downloaded to {output_path} ({downloads_left}/25 remaining)"
        }

    except Exception as e:
        return {
            'success': False,
            'filepath': None,
            'message': f"Exception: {str(e)}"
        }

# Usage example:
result = download_from_annas_archive('bdd7adbb391ea84c5a23f95dbb8cc536')
if result['success']:
    print(f"✓ {result['message']}")
else:
    print(f"✗ {result['message']}")
```

## Best Practices

- **Rate Limiting:** Add 1-2 second delays between requests
- **User Agent:** Set a descriptive User-Agent header
- **Error Handling:** Check for null `download_url` and error messages
- **Daily Limits:** Respect the 25 downloads/day limit for members
- **Caching:** Cache search results to minimize requests
- **Robots.txt:** Respect Anna's Archive robots.txt guidelines

## Error Codes

| Error | Cause | Solution |
|-------|-------|----------|
| `"Invalid md5"` | MD5 not found or malformed | Verify MD5 format (32 hex chars) |
| `"Invalid key"` | API key incorrect | Check membership status |
| `download_url: null` | File unavailable or quota exceeded | Check daily download limit |
| HTTP 429 | Too many requests | Add delays, implement backoff |
| HTTP 403 | Blocked or unauthorized | Check User-Agent, IP, auth |

## URL Structure Reference

```
# Search
https://annas-archive.org/search?q={query}&index={index}&page={page}&sort={sort}&content={type}&ext={ext}&lang={lang}

# Download API
https://annas-archive.org/dyn/api/fast_download.json?md5={hash}&key={api_key}&path_index={idx}&domain_index={idx}

# Item page
https://annas-archive.org/md5/{hash}
```

## Additional Resources

- **HTML Documentation:** See `claude_annas_archive_api_complete.html` for detailed guide
- **Method Comparison:** See `claude_md5_retrieval_methods.html` for 7 ways to get MD5 hashes
- **Process Explanation:** See `claude_annas_archive_explanation.html` for how MD5/API works