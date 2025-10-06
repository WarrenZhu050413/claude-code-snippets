# Search Strategy Guide

**VERIFICATION_HASH:** `7f22b25e35f3c1f8`

## Overview
**IMPORTANT: Start with WebSearch, then supplement with Codex/Exa/Anna's Archive ONLY if needed.**

WebSearch is free and fast (2-4s). Use it as your primary search tool. Only add supplementary tools when WebSearch results are insufficient or require deeper analysis.

## Primary Strategy: WebSearch First

### Default Workflow
```
1. Start with WebSearch (free, fast, broad coverage)
2. Analyze results for gaps or complexity
3. If gaps exist or task is complex:
   - Need deep analysis or multi-step research? → Use Codex
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

### 🤖 Codex (For Complex Analysis & Multi-Step Research)
**→ Read the `codex` snippet for:**
- Autonomous multi-step research with reasoning
- Heavy analytical tasks requiring synthesis
- Complex queries needing deep investigation
- When WebSearch provides results but deeper analysis is needed
**Cost:** API usage (OpenAI/Anthropic) | **Speed:** 10-30s depending on complexity
**Use when:** Task requires autonomous research, multi-source synthesis, or complex reasoning beyond simple search results

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
2. Analyze results and task complexity
   ↓
3. Are results sufficient?
   ├─ YES → Done! Use WebSearch results
   │
   └─ NO → What's missing or needed?
      ├─ Need deep analysis/multi-step research?
      │  └─ Use Codex (read codex snippet)
      │     → Codex can autonomously search + reason + synthesize
      │
      ├─ Code examples/technical depth?
      │  └─ Supplement with Exa (read exa snippet)
      │
      ├─ Academic papers/books?
      │  └─ Supplement with Anna's Archive (read annas-archive snippet)
      │
      └─ Multiple gaps?
         └─ Combine tools: Codex + Exa + Anna's Archive
            → Use Codex for complex research orchestration
```

## Recommended Search Pattern

### Step 1: Always Start with WebSearch
```typescript
// ALWAYS start here (free, fast)
const webResults = await WebSearch({ query: userQuery });
```

### Step 2: Analyze WebSearch Results & Task Complexity
```typescript
// Check if results are sufficient and assess task needs
const analysis = {
  needsDeepAnalysis: requiresMultiStepReasoning(query),
  needsComplexSynthesis: requiresCrossSynthesis(webResults),
  hasCodeExamples: checkForCode(webResults),
  hasAcademicDepth: checkForScholarship(webResults),
  hasSufficientDetail: checkQuality(webResults)
};
```

### Step 3: Supplement ONLY if Needed
```typescript
// For complex analytical tasks, delegate to Codex
if (analysis.needsDeepAnalysis || analysis.needsComplexSynthesis) {
  // Codex autonomously handles web search + reasoning + synthesis
  return codexResearch(query); // Read 'codex' snippet for details
}

// For specific gaps, use targeted supplements
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

### Pattern 2: WebSearch → Delegate to Codex (For Complex Research)
```
1. WebSearch gives initial overview
2. Task requires deep analysis, multi-step reasoning, or synthesis
3. Delegate to Codex for autonomous research (read codex snippet)
   → Codex handles its own web searching + reasoning + synthesis
```

### Pattern 3: WebSearch → Supplement with Exa
```
1. WebSearch gives overview
2. Lacks code examples or technical depth
3. Add Exa for production code (read exa snippet)
```

### Pattern 4: WebSearch → Supplement with Anna's Archive
```
1. WebSearch gives overview
2. Lacks academic foundation
3. Add Anna's Archive for papers/books (read annas-archive snippet)
```

### Pattern 5: WebSearch → Supplement with Multiple Tools
```
1. WebSearch gives overview
2. Multiple gaps identified
3. Combine tools strategically:
   - Codex for orchestration + synthesis
   - Exa for code examples
   - Anna's Archive for academic papers
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
2. **Consider complexity** - For multi-step research or deep analysis, use Codex
3. **Supplement strategically** - Only add supplementary tools if WebSearch has clear gaps
4. **Read the snippets** - Each tool has detailed guidance (`codex`, `exa`, `websearch`, `annas-archive`)
5. **Cost-conscious** - Consider API costs (Codex uses OpenAI/Anthropic, Exa costs $0.01/query)
6. **Gap-driven supplements** - Don't use all tools by default, use them to fill specific gaps

## Quick Reference

**For detailed implementation, always read:**
- `websearch` snippet - Query optimization, current information
- `codex` snippet - Autonomous research, multi-step analysis, synthesis
- `exa` snippet - Code examples, APIs, technical docs
- `annas-archive` snippet - Academic papers, books, research