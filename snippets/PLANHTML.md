<planhtml>
---
description: Output a structured plan in HTML format before executing tasks
---

# PLAN MODE: Create Structured Plan in HTML

**VERIFICATION_HASH:** `9f53f723386ab19f`


When you receive this trigger, you MUST:

## Phase 1: Planning (REQUIRED FIRST)
ALWAYS create a comprehensive plan BEFORE taking any action. DO NOT skip this step.

### Planning Best Practices (2025)
1. **Think Before Acting**: Analyze the complete task context, requirements, and potential approaches
2. **Break Down Complexity**: Decompose large tasks into specific, actionable steps
3. **Consider Dependencies**: Identify which steps must happen in sequence vs. parallel
4. **Anticipate Edge Cases**: Think through potential issues and how to handle them
5. **Define Success Criteria**: Specify what "done" looks like for each step
6. **Progressive Refinement**: Start with high-level steps, then add detail

### Plan Structure Requirements
Your plan MUST include:

1. **Executive Summary** (always visible)
   - What is being requested
   - High-level approach (1-3 sentences)
   - Estimated complexity/time

2. **Prerequisites & Context** (collapsible)
   - Files/resources that need to be examined
   - Existing code/configurations to understand
   - Dependencies or blockers

3. **Step-by-Step Implementation** (primary focus)
   - Numbered steps in logical order
   - Each step should be specific and actionable
   - Include file paths and function names when applicable
   - Mark dependencies between steps
   - Indicate which steps can be done in parallel

4. **Testing & Validation** (collapsible)
   - How to verify each step works
   - Test cases to run
   - Expected outcomes

5. **Potential Issues & Mitigations** (collapsible)
   - Edge cases to consider
   - Common pitfalls
   - Fallback strategies

6. **Post-Implementation** (collapsible)
   - Documentation needs
   - Follow-up tasks
   - Maintenance considerations

## Phase 2: HTML Output Formatting

### HTML Style Guide Reference
**CRITICAL**: Search for and read the HTML snippet for the single source of truth on HTML formatting.
The HTML snippet contains complete specifications for:
- Chinese aesthetic color palette
- Compact, information-dense layout
- Progressive disclosure with collapsibles
- Two-column layout defaults
- Visual hierarchy and typography

### HTML Plan Structure
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Plan: [Task Name]</title>
    <style>
        /* Include ALL styles from HTML.md snippet */
    </style>
</head>
<body>
    <!-- Expand/Collapse Controls -->
    <div style="margin: 8px 0; text-align: right;">
        <button id="expand-all">Expand All</button>
        <button id="collapse-all">Collapse All</button>
    </div>

    <!-- Executive Summary (Always Visible) -->
    <div class="important-always-visible">
        <h1>📋 Task Plan: [Task Name]</h1>
        <div class="two-column-layout">
            <div>
                <h3>Objective</h3>
                <p>[What needs to be done]</p>
            </div>
            <div>
                <h3>Approach</h3>
                <p>[High-level strategy]</p>
                <div class="metric important">Complexity: [Low/Medium/High]</div>
            </div>
        </div>
    </div>

    <!-- Two-Column Layout for Main Content -->
    <div class="two-column-layout">
        <!-- Left Column: Implementation Steps -->
        <div class="collapsible critical" data-collapsible="open">
            <div class="collapsible-header">
                <span>⚡ Implementation Steps</span>
                <span class="arrow">▶</span>
            </div>
            <div class="collapsible-content">
                <ol class="dense-list">
                    <li><strong>Step 1:</strong> [Description]
                        <div class="indent-1 muted">File: path/to/file.ext</div>
                    </li>
                    <!-- More steps -->
                </ol>
            </div>
        </div>

        <!-- Right Column: Testing & Validation -->
        <div class="collapsible secondary" data-collapsible="closed">
            <div class="collapsible-header">
                <span>✓ Testing & Validation</span>
                <span class="arrow">▶</span>
            </div>
            <div class="collapsible-content">
                <ul class="dense-list">
                    <li><strong>Test 1:</strong> [Description]</li>
                    <!-- More tests -->
                </ul>
            </div>
        </div>

        <!-- Prerequisites (collapsed by default) -->
        <div class="collapsible secondary" data-collapsible="closed">
            <div class="collapsible-header">
                <span>📍 Prerequisites & Context</span>
                <span class="arrow">▶</span>
            </div>
            <div class="collapsible-content">
                <!-- Content -->
            </div>
        </div>

        <!-- Potential Issues (collapsed by default) -->
        <div class="collapsible secondary" data-collapsible="closed">
            <div class="collapsible-header">
                <span>⚠️ Potential Issues</span>
                <span class="arrow">▶</span>
            </div>
            <div class="collapsible-content">
                <!-- Content -->
            </div>
        </div>
    </div>

    <!-- Full-width sections -->
    <div class="collapsible full-width" data-collapsible="closed">
        <div class="collapsible-header">
            <span>📊 Post-Implementation</span>
            <span class="arrow">▶</span>
        </div>
        <div class="collapsible-content">
            <!-- Content -->
        </div>
    </div>

    <script>
        /* Include JavaScript from HTML.md snippet */
    </script>
</body>
</html>
```

## Phase 3: File Handling
1. **Write to file**: `claude_plan_[task_description].html`
2. **Open automatically**: `open claude_plan_[task_description].html`
3. **Inform user**: "Plan saved as claude_plan_[task_description].html and opened"

## Phase 4: User Confirmation
After presenting the plan in HTML:
1. Ask the user: "Review the plan. Would you like me to proceed with implementation?"
2. Wait for user confirmation before executing any steps
3. If user requests changes, update the plan HTML accordingly

## Key Principles
- **NEVER skip planning** - Always create the plan first
- **Be specific** - Vague plans lead to confusion
- **Think holistically** - Consider the entire system, not just the immediate task
- **Use HTML snippet styles** - Search for HTML.md for the single source of truth
- **Progressive disclosure** - Important info visible, details collapsed
- **Two-column layout** - Use columns for density and organization
- **Visual hierarchy** - Use colors and borders to indicate importance
- **User approval required** - Never execute without confirmation

## Workflow Summary
```
User Request → CREATE PLAN (this mode) → Output HTML → User Reviews → User Approves → Execute Steps
```

This ensures thoughtful, organized implementation with clear communication.
</planhtml>