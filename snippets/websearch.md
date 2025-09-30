# WebSearch Optimization Guide

**VERIFICATION_HASH:** `3bae729dadda6368`

## When to Use WebSearch

Use the `WebSearch` tool for:
- **Breaking news & current events** - Real-time information
- **General knowledge** - Broad overviews and summaries
- **Consumer products** - Reviews, comparisons, shopping
- **Local information** - Restaurants, services, businesses
- **Regulatory/legal info** - Multi-jurisdictional coverage
- **Trend analysis** - What's happening now

**Cost:** Free (no API charges)
**Speed:** 2-4 seconds typical

## Query Optimization Strategies

### 1. Query Decomposition

Break complex queries into focused sub-queries:

**❌ Too Complex:**
```
"Analyze AI trends and compare frameworks and recommend best practices"
```

**✅ Decomposed:**
```typescript
Promise.all([
  WebSearch({ query: "AI framework trends 2024 2025" }),
  WebSearch({ query: "LLM framework comparison benchmarks" }),
  WebSearch({ query: "AI development best practices production" })
])
```

**Examples:**

| Complex Query | Decomposed Sub-Queries |
|--------------|------------------------|
| "How do I fix authentication in my app?" | 1. "JWT authentication troubleshooting"<br>2. "Node.js authentication best practices"<br>3. "Common auth error solutions" |
| "Best database for my project" | 1. "SQL vs NoSQL comparison 2025"<br>2. "PostgreSQL performance benchmarks"<br>3. "Database scaling strategies" |

### 2. Query Expansion & Reformulation

**Add Context:**
```
Vague: "authentication error"
Better: "JWT token authentication error Node.js Express"
```

**Use Synonyms:**
```
machine learning → ML artificial intelligence deep learning
database optimization → query performance tuning indexing
responsive design → mobile-first adaptive layout
```

**Reformulation Pattern:**
```typescript
// Original vague query
const original = "How do I fix this?";

// Reformulated with context
const reformulated = "How to debug authentication errors in Node.js JWT tokens";

// With technical details
const specific = "JWT token expired error 401 Express.js middleware solution";
```

### 3. Multi-Strategy Parallel Search

Execute different query variations simultaneously:

```typescript
// Strategy A: Core + Expanded + Alternative
Promise.all([
  WebSearch({ query: "React Server Components performance" }),
  WebSearch({ query: "RSC server-side rendering optimization" }),
  WebSearch({ query: "Next.js App Router streaming speed" })
])

// Strategy B: Breadth-First Discovery
Promise.all([
  WebSearch({ query: "LLM frameworks", numResults: 3 }),
  WebSearch({ query: "language model APIs", numResults: 3 }),
  WebSearch({ query: "AI agent libraries", numResults: 3 })
])
```

### 4. Iterative Search with Gap Analysis

```typescript
async function iterativeWebSearch(query: string) {
  let round = 1;
  let allResults = [];
  let gaps = [];

  while (round <= 3) {
    // Refine query based on gaps
    const refinedQuery = round === 1
      ? query
      : refineBasedOnGaps(query, gaps);

    const results = await WebSearch({ query: refinedQuery });
    allResults.push(...results);

    // Analyze what's missing
    gaps = analyzeGaps(query, allResults);

    if (gaps.length === 0) break;
    round++;
  }

  return synthesize(allResults);
}
```

## Date-Aware Searching

Always include temporal context for time-sensitive queries:

```typescript
// ✅ Good - Includes year
"LLM frameworks 2024 2025"
"React 19 features release"
"TypeScript 5 new capabilities"

// ✅ Good - Temporal keywords
"latest Next.js updates"
"recent AI developments"
"current best practices"
"upcoming JavaScript features"

// ❌ Bad - No temporal context
"AI frameworks"
"React features"
"TypeScript capabilities"
```

**Current Date Context:** September 2025
- Use "2024 2025" for recent developments
- Use "2025" for cutting-edge information
- Avoid older years unless historical context needed

## Domain Filtering

Control which domains to include/exclude:

```typescript
// Only trusted sources
WebSearch({
  query: "React best practices",
  allowed_domains: ["reactjs.org", "github.com", "dev.to"]
})

// Exclude low-quality sites
WebSearch({
  query: "JavaScript tutorials",
  blocked_domains: ["spam.com", "low-quality-content.net"]
})

// Academic research only
WebSearch({
  query: "machine learning research",
  allowed_domains: ["arxiv.org", "scholar.google.com", "*.edu"]
})
```

## Query Clarity Guidelines

### Specificity Levels

| Level | Example | Result Quality |
|-------|---------|----------------|
| **Vague** | "AI stuff" | Poor - Too broad |
| **General** | "machine learning" | Moderate - Still broad |
| **Specific** | "transformer architecture in LLMs" | Good - Focused |
| **Highly Specific** | "BERT vs GPT transformer differences" | Excellent - Precise |

### Adding Technical Context

```typescript
// Base query
const base = "authentication error";

// + Technology
const withTech = "JWT authentication error Node.js";

// + Framework
const withFramework = "JWT authentication error Express.js middleware";

// + Error details
const withDetails = "JWT token expired 401 unauthorized Express.js middleware";
```

## Adaptive Search Depth

Match search depth to information needs:

```typescript
// Quick Answer (30 seconds)
const quick = await WebSearch({
  query: specificQuery,
  // Default 5 results, single query
});

// Moderate Depth (2-3 minutes)
const moderate = await Promise.all([
  WebSearch({ query: coreQuery }),
  WebSearch({ query: expandedQuery }),
  WebSearch({ query: alternativeQuery })
]);

// Deep Research (10+ minutes)
async function deepResearch(query: string) {
  // Round 1: Broad search
  const round1 = await multiQuerySearch(query);

  // Round 2: Gap-targeted
  const gaps = analyzeGaps(round1);
  const round2 = await Promise.all(
    gaps.map(gap => WebSearch({ query: gap }))
  );

  // Round 3: Deep dive on key findings
  const keyTopics = extractKeyTopics([...round1, ...round2]);
  const round3 = await Promise.all(
    keyTopics.map(topic => WebSearch({ query: topic }))
  );

  return synthesize([round1, round2, round3]);
}
```

## Result Analysis & Re-ranking

Use LLM to rank and filter results:

```typescript
async function reRankResults(query: string, results: any[]) {
  const prompt = `Rank these search results by relevance to: "${query}"

Results:
${results.map((r, i) => `${i + 1}. ${r.title} - ${r.snippet}`).join('\n')}

Consider:
- Specificity to query
- Recency (prefer 2024-2025)
- Source authority
- Depth of coverage

Output ranked indices (e.g., "3,1,5,2,4"):`;

  const ranking = await llm.generate(prompt);
  return reorderByRanking(results, ranking);
}
```

## Common Pitfalls & Solutions

### Pitfall 1: Too Broad
```
❌ "AI information"
✅ "GPT-4 API rate limits and pricing September 2025"
```

### Pitfall 2: Single Source
```
❌ Relying on first search result
✅ Cross-reference 3+ sources, validate claims
```

### Pitfall 3: Static Queries
```
❌ Repeating same query when results are poor
✅ Reformulate, expand, try different angles
```

### Pitfall 4: Ignoring Recency
```
❌ "React best practices" (could be outdated)
✅ "React 19 best practices 2025"
```

### Pitfall 5: No Gap Analysis
```
❌ Stopping after first search
✅ Identify missing info, iterate with targeted searches
```

## Advanced Techniques

### Contextual Search (Conversation-Aware)

```typescript
class ContextualWebSearch {
  private context: string[] = [];

  async search(query: string) {
    // Enrich with conversation context
    const enrichedQuery = this.context.length > 0
      ? `${this.context.join(' ')} ${query}`
      : query;

    const results = await WebSearch({ query: enrichedQuery });

    // Update context
    this.context.push(summarize(results));
    if (this.context.length > 3) {
      this.context.shift(); // Keep last 3 contexts
    }

    return results;
  }
}
```

### Multi-Source Validation

```typescript
async function validateClaim(claim: string) {
  // Search across different source types
  const [general, academic, news] = await Promise.all([
    WebSearch({ query: claim }),
    WebSearch({
      query: claim,
      allowed_domains: ["*.edu", "scholar.google.com"]
    }),
    WebSearch({
      query: `${claim} news 2025`,
      allowed_domains: ["nytimes.com", "reuters.com", "bbc.com"]
    })
  ]);

  // Analyze consistency
  return {
    claim,
    generalSupport: analyze(general),
    academicSupport: analyze(academic),
    newsSupport: analyze(news),
    confidence: calculateConsistency([general, academic, news])
  };
}
```

### Intelligent Query Clarification

```typescript
async function clarifyIfNeeded(query: string) {
  // Quick probe
  const probe = await WebSearch({ query });

  // Detect ambiguity
  if (hasMultipleInterpretations(probe)) {
    return {
      needsClarification: true,
      question: `Found multiple meanings for "${query}":
1. ${interpretation1}
2. ${interpretation2}
Which one?`,
      options: [interpretation1, interpretation2]
    };
  }

  return await fullSearch(query);
}
```

## Success Metrics

Evaluate search effectiveness:

- **Coverage**: Found all relevant information?
- **Accuracy**: Sources authoritative and cross-validated?
- **Efficiency**: Optimal queries for information density?
- **Freshness**: Information recency appropriate?
- **Relevance**: Results directly address query intent?

## Quick Reference Checklist

### Before Searching
- [ ] Query is specific and clear
- [ ] Included temporal context if time-sensitive
- [ ] Identified if decomposition needed
- [ ] Planned synonyms/variations

### During Search
- [ ] Using parallel queries for complex topics
- [ ] Domain filtering if source quality matters
- [ ] Monitoring for ambiguity/gaps
- [ ] Ready to reformulate if needed

### After Search
- [ ] Cross-referenced multiple sources
- [ ] Validated critical claims
- [ ] Identified gaps requiring follow-up
- [ ] Synthesized insights across results

## Integration with Other Tools

- **After WebSearch** → Use Exa for technical depth
- **After WebSearch** → Use Anna's Archive for academic foundation
- **Before WebSearch** → Use Exa to understand technical landscape first
- **Parallel with WebSearch** → Combine all three for comprehensive research