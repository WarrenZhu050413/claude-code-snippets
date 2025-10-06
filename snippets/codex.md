<codex>

**VERIFICATION_HASH:** `39a81fa917f4a206`

- Use codex mcp instead of websearch for all web searching tasks and for heavy analytical tasks
- When using Codex MCP tool, conversation continuity is possible by finding the session ID in ~/.codex/sessions/YYYY/MM/DD/\*.jsonl files and using codex-reply with that ID. Each Codex session creates a persistent conversation that can be continued across multiple interactions.

## Configuration

**IMPORTANT:** Pass config as an inline object, NOT as a file path. This prevents hanging and nested Codex spawning issues.

### Correct Usage:
```python
mcp__codex__codex(
    prompt="your search query here",
    config={
        "tools": {"web_search": true},
        "model": "gpt-5-codex",
        "model_provider": "openai",
        "approval_policy": "never",
        "sandbox_mode": "read-only",
        "model_reasoning_effort": "high",
        "model_reasoning_summary": "detailed",
        "model_verbosity": "high"
    }
)
```

### Why This Works:
- ✅ No hanging or timeouts
- ✅ Direct web search without spawning nested Codex processes
- ✅ Read-only sandbox (safe, no workspace modifications)
- ✅ Fast responses (5-10 seconds for web searches)

### ❌ DON'T Use:
- `config="/Users/wz/.codex/codex-search.toml"` (causes hanging)
- `profile="search"` (may spawn nested Codex with sandbox issues)
</codex>
