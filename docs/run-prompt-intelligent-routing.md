# Run-Prompt Intelligent Routing

## Overview

The `/run-prompt` command now intelligently routes prompts to the appropriate executor based on task type:

- **Code tasks** → `/coder` workflow (with automatic quality gates: standards + tests)
- **Non-code tasks** → `general-purpose` agent (no quality gates)

## How It Works

### 1. Frontmatter Detection (Explicit Control)

Add frontmatter to your prompt file to explicitly specify the executor:

```yaml
---
executor: coder
---
```

or

```yaml
---
executor: general-purpose
---
```

**When to use**: When you want explicit control over the execution workflow.

### 2. Auto-Detection (Smart Defaults)

If no frontmatter is specified, the system analyzes prompt content and counts indicators:

#### Code Task Indicators (+1 point each)
- Implementation verbs: "implement", "build", "create", "add feature", "develop", "code"
- Code modification: "modify", "edit", "update", "refactor", "fix bug"
- File operations: mentions of code files (.js, .ts, .py, .go, etc.)
- Component/class: "component", "class", "function", "module", "API", "endpoint"
- Testing: "test", "ensure tests pass", "add tests", "unit test"
- Quality: "coding standards", "code conventions", "follow standards"
- Tech stack: "React", "Node", "Django", "Go", "TypeScript", etc.

#### Non-Code Indicators (+1 point each)
- Research: "research", "investigate", "explore", "analyze", "study"
- Documentation: "document", "write documentation", "create guide"
- Analysis: "analyze", "review", "assess", "evaluate", "compare"
- Data tasks: "gather data", "collect information", "compile", "summarize"
- Reports: "create report", "generate summary", "write analysis"

#### Decision Rules
1. If code_score >= 3 → Route to `/coder`
2. If non_code_score > code_score AND code_score < 3 → Route to `general-purpose`
3. If code_score >= 2 AND mentions tests/standards → Route to `/coder`
4. Default (ambiguous) → Route to `/coder` (safer for quality)

## Example Prompts

### Example 1: Code Task (Auto-Detected)

**File**: `./prompts/001-implement-user-auth.md`

**Content**:
```markdown
<objective>
Implement a user authentication system with JWT tokens.
</objective>

<requirements>
1. Create authentication endpoints
2. Add comprehensive tests
3. Follow project coding standards
</requirements>
```

**Analysis**:
- Keywords: "implement" (1), "authentication" (1), "create" (1), "tests" (1), "standards" (1)
- Code score: 5
- **Decision**: Route to `/coder` ✓

**Execution**:
```bash
/run-prompt 001
```

**What Happens**:
1. Prompt routed to `/coder` workflow
2. Coder agent implements the feature
3. SubagentStop hook signals → coding-standards-checker runs
4. SubagentStop hook signals → tester runs
5. All quality gates applied automatically

**Output**:
```
✓ Executed: ./prompts/001-implement-user-auth.md
✓ Executor: coder (auto-detected)
✓ Quality gates: Standards ✓ | Tests ✓
✓ Archived to: ./prompts/completed/001-implement-user-auth.md
```

### Example 2: Research Task (Auto-Detected)

**File**: `./prompts/002-research-database-options.md`

**Content**:
```markdown
<research_objective>
Research and compare database options.
Document findings and create comparison report.
</research_objective>
```

**Analysis**:
- Keywords: "research" (1), "compare" (1), "document" (1), "report" (1)
- Non-code score: 4, Code score: 0
- **Decision**: Route to `general-purpose` ✓

**Execution**:
```bash
/run-prompt 002
```

**What Happens**:
1. Prompt routed to `general-purpose` agent
2. Agent performs research and creates report
3. No quality gates triggered (not needed for research)
4. Completes quickly without unnecessary checks

**Output**:
```
✓ Executed: ./prompts/002-research-database-options.md
✓ Executor: general-purpose (auto-detected)
✓ Archived to: ./prompts/completed/002-research-database-options.md
```

### Example 3: Frontmatter Override

**File**: `./prompts/003-quick-prototype-no-quality.md`

**Content**:
```yaml
---
executor: general-purpose
---

<objective>
Build a quick HTML prototype for internal demo.
Skip quality checks - speed over quality.
</objective>
```

**Analysis**:
- Frontmatter detected: `executor: general-purpose`
- Auto-detection **skipped** (frontmatter takes precedence)
- **Decision**: Route to `general-purpose` ✓

**Execution**:
```bash
/run-prompt 003
```

**What Happens**:
1. Frontmatter specification respected
2. Routed to `general-purpose` despite implementation keywords
3. No quality gates applied (as requested)
4. Fast prototype creation

**Output**:
```
✓ Executed: ./prompts/003-quick-prototype-no-quality.md
✓ Executor: general-purpose (frontmatter)
✓ Archived to: ./prompts/completed/003-quick-prototype-no-quality.md
```

## Parallel Execution

Execute multiple prompts simultaneously with mixed executors:

```bash
/run-prompt 001 002 003 --parallel
```

**What Happens**:
- All three prompts analyzed for task type
- All executed in parallel (single message, multiple tool calls)
- Prompt 001 (code) → `/coder` with quality gates
- Prompt 002 (research) → `general-purpose` without quality gates
- Prompt 003 (frontmatter) → `general-purpose` without quality gates
- Each follows its appropriate workflow independently

**Output**:
```
✓ Executed in PARALLEL:

- ./prompts/001-implement-user-auth.md (executor: coder, quality gates applied)
- ./prompts/002-research-database-options.md (executor: general-purpose)
- ./prompts/003-quick-prototype-no-quality.md (executor: general-purpose, frontmatter)

✓ All archived to ./prompts/completed/
```

## Sequential Execution

Execute prompts one after another:

```bash
/run-prompt 001 002 003 --sequential
```

**What Happens**:
- Prompt 001 analyzed → routed to `/coder` → full workflow (implement → standards → tests) → archived
- Prompt 002 analyzed → routed to `general-purpose` → research → archived
- Prompt 003 analyzed → routed to `general-purpose` → prototype → archived

**Benefits**:
- Each prompt completes fully before next starts
- Dependencies between prompts respected
- Clear progression through workflow

## Benefits

### Automatic Quality Gates
✅ Code tasks automatically get standards checks and tests
✅ No manual workflow management needed
✅ Consistent quality enforcement

### Lightweight Non-Code Tasks
✅ Research, documentation skip unnecessary quality gates
✅ Faster execution for appropriate task types
✅ No overhead for tasks that don't need code quality checks

### Flexible Control
✅ Frontmatter for explicit control when needed
✅ Auto-detection for smart defaults
✅ Override mechanism for special cases

### CI/CD Ready
✅ Autonomous execution with appropriate quality gates
✅ No manual intervention required
✅ Prompts route correctly regardless of execution environment

### Leverages Existing Infrastructure
✅ Reuses `/coder` hooks and quality gate workflows
✅ No duplication of orchestration logic
✅ Single source of truth for code quality process

## Migration Guide

### Old Workflow (Manual)
```bash
# Create prompt
/create-prompt Implement authentication

# Start new session
# Run prompt
/run-prompt 001

# Manually ensure quality
# Run tests manually
# Check standards manually
```

### New Workflow (Intelligent Routing)
```bash
# Create and run automatically (or use create-prompt decision tree)
/create-prompt Implement authentication
# Choose option 1 to run immediately

# OR create first, run later with automatic quality gates
/create-prompt Implement authentication
# Choose option 3 to save
/run-prompt 001  # Automatically routes to /coder with quality gates
```

### For CI/CD
```bash
# Single autonomous command
/run-prompt last  # Runs most recent prompt with appropriate executor
```

## Best Practices

1. **Let Auto-Detection Work**: Most prompts don't need frontmatter - the auto-detection is quite accurate

2. **Use Frontmatter for Edge Cases**: Only add frontmatter when:
   - You want to skip quality gates for prototypes
   - The prompt content is ambiguous
   - You need explicit control for special workflows

3. **Write Clear Prompts**: Include clear task verbs ("implement", "research", etc.) to help auto-detection

4. **Trust the Quality Gates**: Code tasks automatically get full quality workflow - don't skip it unless you have good reason

5. **Use Parallel for Independence**: If prompts can run simultaneously, use `--parallel` for faster execution

6. **Use Sequential for Dependencies**: If prompts depend on each other, use `--sequential` or default behavior

## Troubleshooting

### Prompt Routed to Wrong Executor?

**Add frontmatter** to explicitly control:
```yaml
---
executor: coder  # or general-purpose
---
```

### Quality Gates Too Slow for Prototype?

**Use frontmatter** to skip:
```yaml
---
executor: general-purpose
---
```

### Want to See Detection Logic?

The routing decision is shown in the output:
```
✓ Executor: coder (auto-detected)
```

or

```
✓ Executor: general-purpose (frontmatter)
```
