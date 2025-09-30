# Search Strategy Guide

**VERIFICATION_HASH:** `0eda421a78b27864`

## Overview
**IMPORTANT: Start with WebSearch, then supplement with Exa/Anna's Archive ONLY if needed.**

WebSearch is free and fast (2-4s). Use it as your primary search tool. Only add Exa ($0.01/query) or Anna's Archive when WebSearch results are insufficient.

## Primary Strategy: WebSearch First

### Default Workflow
```
1. Start with WebSearch (free, fast, broad coverage)
2. Analyze results for gaps
3. If gaps exist:
   - Need code examples? → Add Exa
   - Need academic papers? → Add Anna's Archive
4. If no gaps, you're done!
```

## Tool-Specific References

### 🌐 WebSearch (START HERE - Always Use First)
**→ Read the `websearch` snippet for:**
- Query decomposition and expansion
- Multi-strategy parallel search patterns
- Iterative refinement with gap analysis
- Date-aware searching techniques
**Cost:** Free | **Speed:** 2-4s

### 🔍 Exa (Supplement Only When Needed)
**→ Read the `exa` snippet for:**
- Deep code examples and production patterns
- Technical documentation with context
- When WebSearch lacks technical depth
**Cost:** $0.01/query | **Speed:** 5-6s
**Use when:** WebSearch doesn't provide sufficient code examples or technical detail

### 📚 Anna's Archive (Supplement Only When Needed)
**→ Read the `annas-archive` snippet for:**
- Academic papers and research
- Technical books and textbooks
- When WebSearch lacks scholarly sources
**Use when:** Need academic foundation or comprehensive book content

## Decision Tree

```
Always start here ↓

1. Run WebSearch first
   ↓
2. Analyze results
   ↓
3. Are results sufficient?
   ├─ YES → Done! Use WebSearch results
   │
   └─ NO → What's missing?
      ├─ Code examples/technical depth?
      │  └─ Supplement with Exa (read exa snippet)
      │
      ├─ Academic papers/books?
      │  └─ Supplement with Anna's Archive (read annas-archive snippet)
      │
      └─ Both?
         └─ Supplement with both Exa AND Anna's Archive
```

## Recommended Search Pattern

### Step 1: Always Start with WebSearch
```typescript
// ALWAYS start here (free, fast)
const webResults = await WebSearch({ query: userQuery });
```

### Step 2: Analyze WebSearch Results
```typescript
// Check if results are sufficient
const analysis = {
  hasCodeExamples: checkForCode(webResults),
  hasAcademicDepth: checkForScholarship(webResults),
  hasSufficientDetail: checkQuality(webResults)
};
```

### Step 3: Supplement ONLY if Needed
```typescript
// Only add expensive tools if WebSearch has gaps
const supplements = [];

if (!analysis.hasCodeExamples) {
  // WebSearch lacks code depth → Add Exa
  supplements.push(exaSearch(query));
}

if (!analysis.hasAcademicDepth) {
  // WebSearch lacks academic sources → Add Anna's Archive
  supplements.push(annasArchive(query));
}

// Run supplements in parallel if needed
if (supplements.length > 0) {
  const supplementResults = await Promise.all(supplements);
  return synthesize([webResults, ...supplementResults]);
}

return webResults; // WebSearch was sufficient!
```

## Common Search Patterns

### Pattern 1: WebSearch Only (Most Common)
```
1. WebSearch provides sufficient results
2. Done! No need for other tools
```

### Pattern 2: WebSearch → Supplement with Exa
```
1. WebSearch gives overview
2. Lacks code examples or technical depth
3. Add Exa for production code (read exa snippet)
```

### Pattern 3: WebSearch → Supplement with Anna's Archive
```
1. WebSearch gives overview
2. Lacks academic foundation
3. Add Anna's Archive for papers/books (read annas-archive snippet)
```

### Pattern 4: WebSearch → Supplement with Both (Rare)
```
1. WebSearch gives overview
2. Lacks both code AND academic depth
3. Add Exa + Anna's Archive
```

## Quality Checklist

### Before Searching
- [ ] Identified information type (academic/code/web/all)
- [ ] Selected appropriate tool(s)
- [ ] Read relevant tool snippets for best practices

### During Search
- [ ] Using parallel execution where appropriate
- [ ] Following tool-specific optimization (see snippets)
- [ ] Cross-validating critical claims

### After Search
- [ ] Synthesized across source types
- [ ] Validated consistency
- [ ] Identified and addressed gaps
- [ ] Documented sources

## Key Principles

1. **WebSearch first, always** - It's free and fast, start here
2. **Supplement strategically** - Only add Exa/Anna's Archive if WebSearch has clear gaps
3. **Read the snippets** - Each tool has detailed guidance (`exa`, `websearch`, `annas-archive`)
4. **Cost-conscious** - Exa costs $0.01/query, use it when value justifies cost
5. **Gap-driven supplements** - Don't use all tools by default, use them to fill specific gaps

## Quick Reference

**For detailed implementation, always read:**
- `exa` snippet - Code examples, APIs, technical docs
- `websearch` snippet - Query optimization, current information
- `annas-archive` snippet - Academic papers, books, research