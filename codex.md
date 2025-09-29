<codex>
- Use codex mcp instead of websearch for all web searching tasks and for heavy analytical tasks
- Pass through config="/Users/wz/.codex/codex-search.toml"
- When using Codex MCP tool, conversation continuity is possible by finding the session ID in ~/.codex/sessions/YYYY/MM/DD/\*.jsonl files and using codex-reply with that ID. Each Codex session creates a persistent conversation that can be continued across multiple interactions.
</codex>
