# ORCHESTRATION SYSTEM ARCHITECTURE ANALYSIS

## Executive Summary

This is a sophisticated multi-agent orchestration system built on Claude Code's subagent architecture that achieves context isolation through delegation, mandatory human oversight through hardwired escalation, and effective task completion through strict workflow enforcement.

The system's power derives from **separating concerns across isolated contexts**: Claude (200k) maintains state, agents get fresh contexts for individual tasks, and the stuck agent enforces human-in-the-loop decision making.

---

## 1. DIRECTORY STRUCTURE & AGENT DEFINITIONS

### The .claude/ Directory Layout

```
/root/repo/.claude/
├── CLAUDE.md                  # Orchestrator instructions (the conductor)
├── agents/
│   ├── coder.md              # Implementation specialist
│   ├── research.md           # Documentation fetcher (Jina AI)
│   ├── tester.md             # Visual QA specialist (Playwright)
│   └── stuck.md              # Human escalation point
└── (plus .research-cache/ for documentation storage)
```

### Why This Structure Works

1. **CLAUDE.md is the maestro's baton** - It's read by Claude Code on startup and instructs the main Claude instance to BE the orchestrator
2. **agents/*.md files are agent contracts** - Each defines one specialized role
3. **Single responsibility** - Each agent has ONE job, knows its boundaries
4. **.research-cache/** - Persistent storage for research files shared between agents

---

## 2. HOW SUBAGENTS ARE INVOKED & CONTEXT ISOLATION MAINTAINED

### The Invocation Mechanism: The Task Tool

From the agent instructions, subagents invoke each other using the **Task tool**:

```
Coder: "IMMEDIATELY invoke the `stuck` agent using the Task tool"
Tester: "THEN IMMEDIATELY invoke the `stuck` agent using the Task tool"
Research: "THEN IMMEDIATELY invoke the `stuck` agent using the Task tool"
```

**What the Task tool does (implied from system design):**
- Spawns a new agent with a fresh context window
- The invoked agent is a subagent instance (Claude model instance)
- Each gets its own isolated context - no shared memory
- Communication happens via structured return values

### Context Isolation Mechanism

```
ORCHESTRATOR (200k context)
    ├─ Maintains: todos, project state, progress
    ├─ Invokes: coder agent (fresh context)
    │   └─ Coder (50-100k context)
    │       ├─ Reads: only the one todo item
    │       ├─ Reads: research files if available
    │       └─ Returns: completion status
    │
    ├─ Invokes: tester agent (fresh context)
    │   └─ Tester (50-100k context)
    │       ├─ Reads: what was implemented
    │       ├─ Uses: Playwright MCP tools
    │       └─ Returns: pass/fail + screenshots
    │
    └─ Invokes: research agent (fresh context)
        └─ Research (50-100k context)
            ├─ Uses: Bash + curl for Jina AI
            ├─ Writes: .research-cache/[file].md
            └─ Returns: reference ID + summary
```

### Key Isolation Principles

1. **Stateless agents**: Each subagent begins with ZERO knowledge of previous tasks
2. **One todo at a time**: Orchestrator delegates single items, not batches
3. **File-based communication**: Research results shared via .research-cache directory
4. **Return values as contracts**: Each agent returns structured information (reference ID, completion status, etc.)
5. **No agent-to-agent calling**: Only orchestrator coordinates - maintains clear hierarchy

---

## 3. HOOKS & CONFIGURATION ENABLING ORCHESTRATION

### .claude/CLAUDE.md - The Master Prompt

This file is the **critical hook** that makes everything work:

```markdown
# YOU ARE THE ORCHESTRATOR

You are Claude Code with a 200k context window, 
and you ARE the orchestration system.
```

**What this accomplishes:**
- Instructs main Claude to adopt orchestrator role
- Provides the workflow (8-step mandatory process)
- Defines agent specifications (when to invoke, what to pass)
- Enforces rules (TodoWrite, research before coder, test everything)
- Creates mental model for all subagent invocations

### .mcp.json - Playwright Integration Hook

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "env": {}
    }
  }
}
```

**What this does:**
- Registers Playwright as an MCP (Model Context Protocol) server
- Tester agent automatically gets access to browser automation tools
- Enables screenshot capture, page navigation, element inspection
- Provides visual testing capabilities without additional setup

### Agent .md Files - Role & Tool Definitions

Each agent file has a YAML frontmatter:

**coder.md:**
```yaml
name: coder
tools: Read, Write, Edit, Glob, Grep, Bash, Task
model: sonnet
```

**research.md:**
```yaml
name: research
tools: Bash, Read, Write, Task
model: sonnet
```

**tester.md:**
```yaml
name: tester
tools: Task, Read, Bash
model: sonnet
```

**stuck.md:**
```yaml
name: stuck
tools: AskUserQuestion, Read, Bash, Glob, Grep
model: sonnet
```

**Why this matters:**
- Tool allocation matches job requirements
- `AskUserQuestion` ONLY on stuck agent (enforces human-in-loop)
- `Task` on all agents enables subagent invocation
- `Write` only on coder/research (prevents tester from modifying code)

---

## 4. RELATIONSHIP BETWEEN CLAUDE.MD & CLAUDE CODE FEATURES

### The Instruction-to-Feature Mapping

```
CLAUDE.md says...              Claude Code feature...
─────────────────────────────  ──────────────────────────
"Invoke research subagent"     Task tool + agent definition
"Pass research file path"      Bash + file system (shared)
"Create todo list"             TodoWrite tool (built-in)
"Test with Playwright"         MCP servers + .mcp.json
"Ask human via stuck"          AskUserQuestion tool
```

### How Claude.md Works with Claude Code

1. **File-based discovery**: Claude Code reads `.claude/agents/*.md` on startup
2. **Automatic agent registration**: Each agent in `agents/` directory is available
3. **Tool specification**: YAML frontmatter determines what each agent can do
4. **Context windows**: Each agent invocation is a fresh model instance
5. **MCP integration**: Tools like Playwright are injected automatically

### The Critical Innovation

Claude.md doesn't try to **control** Claude Code's behavior. Instead, it:
- **Instructs** the Claude instance running in Code
- **Defines workflows** that align with agent capabilities
- **Enforces rules** through clear directives ("MUST", "NEVER")
- **Creates mental models** for what each agent should do

The system works because Claude Code's agents feature provides the **mechanism**, and CLAUDE.md provides the **instructions for using that mechanism effectively**.

---

## 5. WHAT MAKES THE DELEGATION SYSTEM EFFECTIVE

### The Five Pillars of Effective Delegation

**1. Clear Boundaries**
- Each agent knows its ONE role
- No agent can do another's job
- Clear tool allocation prevents scope creep

**2. Mandatory Escalation**
```
Coder rule: "IF you encounter ANY error
            THEN IMMEDIATELY invoke the stuck agent
            NEVER proceed with half-solutions"
```
- No fallbacks allowed
- Errors explicitly escalate to stuck agent
- Prevents silent failures

**3. Single Task Focus**
```
"Delegate ONE todo at a time to coder"
"NEVER delegate multiple tasks simultaneously"
```
- Reduces cognitive load
- Clear success criteria
- Easy to verify completion

**4. State Maintenance by Orchestrator**
```
Orchestrator maintains:
- Todo list (via TodoWrite)
- Project vision
- Overall progress
- What's been tested
- What needs research
```
- Single source of truth
- No conflicting state across agents
- Visible progress tracking

**5. Mandatory Testing**
```
"Test EVERY implementation with tester"
"NEVER mark tests as passing without visual proof"
```
- Visual verification via Playwright screenshots
- No assumption-based testing
- Human-visible evidence

### The Workflow Loop That Makes It Work

```
┌─────────────────────────────────────────────────────┐
│                    ORCHESTRATOR                      │
│  (maintains todos, project state, 200k context)     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. Create todo list with TodoWrite               │
│  2. Check: Is research needed?                     │
│     YES → Invoke research (gets docs)              │
│  3. Invoke coder with ONE todo + research files   │
│  4. Invoke tester to verify implementation        │
│  5. If test fails:                                │
│     Invoke stuck (human decides next step)        │
│  6. Mark todo complete, iterate to next          │
│                                                    │
└─────────────────────────────────────────────────────┘
          ↓                    ↓                    ↓
      research agent      coder agent          tester agent
      (fresh context)    (fresh context)      (fresh context)
      (doc fetching)     (code writing)       (visual QA)
         + Jina AI          + File I/O          + Playwright
```

---

## 6. SPECIAL CONFIGURATION IN .mcp.json & OTHER CONFIG FILES

### .mcp.json - The Only Special Config

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "env": {}
    }
  }
}
```

**This is the only actual configuration file that enables special features.**

**What it provides:**
- Browser automation (navigate, click, fill forms)
- Screenshot capture (visual verification)
- DOM inspection (verify element structure)
- Multiple page sizes (responsive testing)

**Why it's critical:**
- Without Playwright, tester can't visually verify
- Enables screenshot-based proof in stuck agent escalations
- Makes testing trustworthy (what you see is what you get)

### No Other Config Files Needed

Notably, the system doesn't use:
- `claude-code.json` for settings (not needed)
- Database configs (state is in-context)
- API keys in config files (Jina API key is in research.md)
- Environment variable files (.env not used)

This minimalism is intentional - it keeps setup simple.

---

## 7. THE RESEARCH CACHE SYSTEM & JINA AI INTEGRATION

### How Research Cache Works

**Structure:**
```
.research-cache/
├── index.json                        # Manifest of all research
├── react-hooks-2025-10-19.md        # Timestamped research files
├── nextjs-routing-2025-10-19.md
└── playwright-api-2025-10-19.md
```

**The index.json format:**
```json
{
  "research_sessions": [
    {
      "id": "react-hooks-1729353600",
      "technology": "React Hooks",
      "timestamp": "2025-10-19T12:00:00Z",
      "file": "react-hooks-2025-10-19.md",
      "summary": "Official React hooks documentation..."
    }
  ]
}
```

### Jina AI Integration in Research Agent

The research agent uses two Jina AI APIs:

**1. Search API** (finding documentation)
```bash
curl "https://s.jina.ai/?q=React+hooks+official+docs" \
  -H "Authorization: Bearer [API_KEY]" \
  -H "X-Respond-With: markdown"
```
Returns: Search results in markdown format

**2. Reader API** (fetching specific URLs)
```bash
curl "https://r.jina.ai/https://react.dev/reference/react/hooks" \
  -H "Authorization: Bearer [API_KEY]"
```
Returns: Clean markdown version of web page

### The Research -> Coder Handoff

```
Research Agent:
1. Gets task: "Research React Server Components"
2. Calls Jina Search: "React Server Components official docs"
3. Gets results, identifies official React docs
4. Calls Jina Reader: https://react.dev/reference/rsc/...
5. Stores markdown in .research-cache/react-rsc-2025-10-19.md
6. Updates index.json with reference
7. Returns: ".research-cache/react-rsc-2025-10-19.md"

Orchestrator:
1. Receives research result
2. Invokes Coder with:
   - Todo: "Implement server components"
   - Research file: ".research-cache/react-rsc-2025-10-19.md"

Coder:
1. Reads todo
2. Reads .research-cache/react-rsc-2025-10-19.md
3. Understands best practices
4. Implements with confidence
5. Returns completion
```

### Why This Design Is Effective

- **Separation of concerns**: Research is separate from implementation
- **Knowledge capture**: Documentation is stored and reusable
- **Fresh context for each task**: Coder doesn't need to fetch docs itself
- **Traceable**: Every research session is logged with ID and timestamp
- **Jina AI advantage**: Gets latest documentation automatically

---

## 8. THE TESTER AGENT'S PLAYWRIGHT INTEGRATION

### What Playwright MCP Provides

From the tester.md instructions, these capabilities:

```
1. Navigate to pages
   → page.goto("http://localhost:3000")

2. Take screenshots
   → page.screenshot() saves visual proof

3. Click buttons
   → page.click("button.submit")

4. Fill forms
   → page.fill("input[type='email']", "user@example.com")

5. Inspect DOM
   → page.evaluate() runs JavaScript in browser

6. Test responsive design
   → Resize viewport for different screen sizes

7. Check for console errors
   → Monitor browser console during interactions
```

### The Visual Testing Workflow

```
Tester receives: "Verify React component renders"

1. Navigate to component URL
   → tester.goto("http://localhost:3000/component")

2. Take initial screenshot
   → Captures what page looks like

3. Verify visual elements
   → Check screenshot for expected elements
   → Compare against requirements

4. Interact with component
   → tester.click("button")
   → tester.screenshot() after click

5. Verify state changes
   → Screenshot shows new state
   → Compare with expectation

6. Test at different sizes
   → Resize to mobile (375px)
   → Resize to tablet (768px)
   → Resize to desktop (1920px)
   → Screenshot each size

7. Check for console errors
   → No JavaScript errors in browser console

8. Report results
   → Screenshots are proof
   → Pass/fail is visual fact, not assumption
```

### Why Playwright + Screenshots > Code Review

**Code review approach:**
```
Tester reads: "height: 100px"
Assumption: "Must be 100px tall"
Problem: Could be wrong, could be broken, could look bad
```

**Playwright screenshot approach:**
```
Tester sees: Screenshot shows button
Screenshot shows: Button is 100px tall
Screenshot shows: Button is blue, centered, clickable
Certainty: VERIFIED VISUALLY
```

### Critical Playwright Rules from tester.md

```
MUST:
- Take LOTS of screenshots - visual proof is everything
- Actually LOOK at screenshots and verify correctness
- Test at multiple screen sizes
- Click buttons and verify they work
- Fill forms and verify submission

MUST NOT:
- Assume something renders correctly without seeing it
- Skip screenshot verification
- Mark visual tests as passing without screenshots
- Ignore layout issues "because code looks right"
```

---

## 9. THE STUCK AGENT & HUMAN-IN-THE-LOOP ENFORCEMENT

### The Stuck Agent's Unique Position

```
Stuck Agent is the ONLY agent with:
- AskUserQuestion tool
- Authority to block progress
- Power to request human decision
- Permission to stop execution
```

**All other agents must:**
- Invoke stuck when encountering ANY problem
- Wait for human response
- Not proceed without explicit human decision
- Never use fallbacks or workarounds

### The Escalation Trigger Points

**Coder invokes stuck when:**
- Package won't install
- File path doesn't exist
- API call fails
- Command returns error
- Needs to make assumptions
- ANYTHING doesn't work first try

**Tester invokes stuck when:**
- Screenshots show incorrect rendering
- Elements missing or misplaced
- Layout is broken
- Interactive elements don't work
- Page won't load or throws errors
- Visual output is questionable

**Research invokes stuck when:**
- Jina AI returns errors
- API quota exceeded
- No documentation found
- Documentation seems outdated
- Multiple competing options exist

**Orchestrator invokes stuck when:**
- Strategic uncertainty about direction
- Conflicting requirements
- Need to choose between options

### The Question Format

Stuck agent doesn't just say "error occurred". It:

```
header: "Clear problem statement"
question: "What should we do?"
options:
  - label: "Option A", description: "Specific implementation"
  - label: "Option B", description: "Alternative approach"
  - label: "Option C", description: "Another path"
```

**From example in stuck.md:**
```
"The npm install failed with 'ENOENT: package.json not found'. 
How should we proceed?"

Options:
  - Initialize new package.json
  - Check different directory
  - Skip npm install
```

### The Human-in-Loop Guarantee

```
NO FALLBACKS                          INSTEAD, ASK HUMAN
─────────────────────────────────────────────────────────
Error during install?      →   Stuck: "pkg failed. Initialize new one?"
Test shows wrong layout?    →   Stuck: "Header misaligned. Fix or accept?"
Ambiguous requirement?      →   Stuck: "REST or GraphQL? Choose one"
Tech choice needed?         →   Stuck: "Three libraries available. Pick one"
Documentation not found?    →   Stuck: "Jina failed. Manual docs or skip?"
```

**The guarantee:** No blind assumptions, no automatic retries, no workarounds. Every problem goes to you.

---

## 10. ARCHITECTURAL DECISIONS THAT MAKE IT EFFECTIVE

### Decision #1: Orchestrator as Central State Manager

```
✓ Claude maintains 200k context with:
  - Complete project vision
  - All todos (what's done, what's pending)
  - Progress tracking
  - Knowledge of all implementations

✓ Agents are stateless:
  - Each gets one task
  - No memory of previous tasks
  - Fresh context each time
  - No accumulated state
```

**Why this works:** Single source of truth prevents state conflicts. Orchestrator can always "see" the full picture.

### Decision #2: One-Todo-At-A-Time Delegation

```
✗ Bad: Invoke coder with 5 todos at once
   - Can't track partial progress
   - Hard to test individually
   - Failed test affects multiple tasks
   - Unclear which todo caused error

✓ Good: Invoke coder with 1 todo
   - Clear success/failure
   - Easy to test
   - Problem isolated to one task
   - Can fix and retry without redoing others
```

**Why this works:** Enables precise testing and error handling. Every test is small and verifiable.

### Decision #3: Mandatory Testing After Every Implementation

```
✗ Bad: Implement 5 features, test once
   - Can't tell which feature broke tests
   - Rework is expensive

✓ Good: Implement feature, test, complete, move to next
   - Know immediately if working
   - Problem is isolated
   - Can handle issues right away
```

**Why this works:** Catches problems immediately while context is fresh. Prevents compound failures.

### Decision #4: Research Before Coding

```
✗ Bad: Coder encounters new technology
   "I'll figure it out as I go"
   
✓ Good: Research agent fetches docs first
   Coder reads docs, implements with confidence
```

**Why this works:** Coder starts with knowledge baseline. Reduces trial-and-error. Better code quality.

### Decision #5: Explicit Escalation (No Fallbacks)

```
✗ Bad: Code hits error
   Agent: "Let me try workaround..."
   May or may not work, hard to debug

✓ Good: Code hits error
   Agent: "I'm stuck, asking human"
   Human makes explicit decision
   Next attempt is intentional
```

**Why this works:** Every decision is visible and intentional. No hidden assumptions. Human maintains control.

### Decision #6: Tool Allocation by Role

```
Coder gets:       Read, Write, Edit, Glob, Grep, Bash, Task
Research gets:    Bash, Read, Write, Task
Tester gets:      Task, Read, Bash
Stuck gets:       AskUserQuestion, Read, Bash, Glob, Grep
```

**Why this works:** Prevents accidents (tester can't modify code), enforces responsibility (only stuck asks humans), enables jobs (coder has Write, tester has Playwright via MCP).

### Decision #7: File-Based Communication

```
Orchestrator → Research:  "Fetch React docs"
Research → File:          .research-cache/react-2025-10-19.md
File → Coder:            "Here's the research"
```

**Why this works:** 
- No need for API contracts
- Coder can read actual documentation (not just summary)
- Research is persistent and reusable
- Easy to debug (just read the .md file)

### Decision #8: Screenshots as Source of Truth

```
✗ Tester: "Code looks good"
   (no proof, just assumption)

✓ Tester: [screenshot showing correct layout]
   (visual proof you can see)
```

**Why this works:** Visual verification is objective. Can't argue with screenshots. No "but it should work" debates.

---

## 11. KEY MECHANISMS ENABLING CONTEXT ISOLATION

### Mechanism #1: Task Tool Creates Fresh Context

When orchestrator invokes:
```
invoke("coder", { todo: "Build X" })
```

Claude Code:
1. Creates new context window for coder agent
2. Loads coder.md (role definition)
3. Provides tools specified in coder.md
4. Runs coder with ONLY the provided data
5. Returns result to orchestrator
6. Closes coder context (garbage collected)

**Result:** Coder never has access to other todos, previous implementations, or orchestrator state. Fresh start every time.

### Mechanism #2: Model Specification Prevents Context Bleeding

Each agent specifies `model: sonnet` in YAML:
```yaml
name: coder
model: sonnet
```

**What this does:**
- Each invocation gets its own model instance
- Different model instances = no shared memory
- Can't learn from previous calls
- Complete isolation

### Mechanism #3: Tools as Capability Boundaries

```
Orchestrator can use:
  Read, Write, Edit, Glob, Grep, Bash, Task,
  TodoWrite, AskUserQuestion

Coder CANNOT use:
  AskUserQuestion (can't decide alone, must escalate)
  TodoWrite (can't manage project state)

Tester CANNOT use:
  Write, Edit (can't modify code)

Stuck MUST use:
  AskUserQuestion (that's its whole job)
```

**What this does:** Prevents agent from performing tasks outside their role.

### Mechanism #4: No Shared State Except Files

Agents communicate through:
- Return values (JSON-like structures)
- Files (.research-cache/*, code files, etc.)
- Never through shared variables or databases

**What this does:**
- Each agent works with what's explicitly passed
- No hidden side effects
- All communication is visible and traceable

---

## 12. THE "NO FALLBACKS" ENFORCEMENT MECHANISM

### How It's Enforced

**In every agent instructions:**
```markdown
CRITICAL: Handle Failures Properly
- IF you encounter ANY error
- IF something doesn't work
- IF you're tempted to use a fallback
- THEN IMMEDIATELY invoke stuck agent
- NEVER proceed with half-solutions
```

**What this accomplishes:**
1. Agents are explicitly told NOT to fallback
2. Given direct instruction to escalate instead
3. Told that escalation is mandatory, not optional
4. Told what tool to use (Task → invoke stuck)

### The Enforcement Loop

```
Agent hits error:
  ↓
Reads instructions: "NEVER fallback, invoke stuck"
  ↓
Finds tool: Task
  ↓
Invokes: stuck(problem_description)
  ↓
Stuck asks: AskUserQuestion
  ↓
Human responds with decision
  ↓
Stuck returns decision to original agent
  ↓
Agent implements human's decision
```

**The key:** Orchestrator has already established this pattern in CLAUDE.md. Each agent just follows its own version of the same rule.

### Why This Is Effective

```
Traditional AI:
- Hit error → try fallback → might work, might not
- Result is uncertain
- Problem is hidden

This system:
- Hit error → ask human → human decides
- Result is certain (human made decision)
- Problem is visible and documented
```

---

## 13. THE COMPLETE INFORMATION FLOW

```
┌──────────────────────────────────────────────────┐
│             USER GIVES PROJECT                   │
│  "Build a React todo app with server actions"    │
└────────────────┬─────────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────────┐
│     ORCHESTRATOR (200k context)                  │
│  1. Reads user requirement                       │
│  2. Creates TODO LIST:                           │
│     [ ] Set up Next.js                          │
│     [ ] Create components                       │
│     [ ] Add server actions                      │
│     [ ] Test all                                │
└────────────┬──────────────────────────────────────┘
             ↓
    CHECK: Does todo mention new tech?
    YES → Research phase
             ↓
┌──────────────────────────────────────────────────┐
│  RESEARCH AGENT (fresh context)                 │
│  Input:  Technology name                        │
│  Process: Use Jina AI to fetch docs             │
│           Save to .research-cache/              │
│  Output: Reference file path                    │
└────────────┬──────────────────────────────────────┘
             ↓
             Provides: .research-cache/react-rsc.md
                 ↓
┌──────────────────────────────────────────────────┐
│  ORCHESTRATOR (continues with research)         │
│  Invokes CODER with:                            │
│    - Todo: "Set up Next.js with server actions" │
│    - Research: ".research-cache/react-rsc.md"   │
└────────────┬──────────────────────────────────────┘
             ↓
┌──────────────────────────────────────────────────┐
│  CODER AGENT (fresh context)                    │
│  Input:  Todo + research file                   │
│  Process: Read research, understand pattern     │
│           Write code according to todo          │
│  Output: "Created files: pages/, components/"   │
└────────────┬──────────────────────────────────────┘
             ↓
             Error encountered?
             ↓                    ↓
            NO                   YES
             ↓                    ↓
    ┌────────────────┐     ┌────────────────┐
    │ Reports done   │     │ Invokes stuck  │
    └────────┬───────┘     └────────┬───────┘
             ↓                      ↓
             ↓             ┌──────────────────────────────────────────────────┐
             ↓             │  STUCK AGENT (fresh context)                    │
             ↓             │  Input: Problem description + context           │
             ↓             │  Ask: AskUserQuestion                           │
             ↓             │  User responds with choice                      │
             ↓             │  Output: Clear instruction                      │
             ↓             └────────────┬────────────────────────────────────┘
             ↓                          ↓
             ↓             Coder receives instruction and retries
             ↓                          ↓
             └──────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────┐
│  ORCHESTRATOR (receives coder completion)       │
│  Invokes TESTER with:                           │
│    - Verify: "Next.js app runs at localhost"    │
│    - Check: Server actions are accessible       │
└────────────┬──────────────────────────────────────┘
             ↓
┌──────────────────────────────────────────────────┐
│  TESTER AGENT (fresh context)                   │
│  Input:  What to test                           │
│  Process: Use Playwright MCP                    │
│           Navigate to pages                     │
│           Take screenshots                      │
│           Verify visually                       │
│  Output: Pass/fail + screenshots                │
└────────────┬──────────────────────────────────────┘
             ↓
       Test result?
       ↓            ↓
      PASS         FAIL
       ↓            ↓
    ┌──────┐   ┌────────────────────┐
    │ Done │   │ Invokes stuck with │
    └───┬──┘   │ screenshots        │
        ↓       └────────────┬───────┘
        ↓                    ↓
        ↓       Human sees screenshots, decides next step
        ↓                    ↓
        ↓       Coder retries based on feedback
        ↓                    ↓
        └────────────────────┘
                 ↓
┌──────────────────────────────────────────────────┐
│  ORCHESTRATOR (back with verified todo)         │
│  Mark todo: ✓ COMPLETE                          │
│  Next todo: [ ] Create components               │
│  Repeat cycle for next todo                     │
└──────────────────────────────────────────────────┘

... repeat until all todos complete ...

Finally: REPORT TO USER with all completed tasks ✓
```

---

## 14. CRITICAL ARCHITECTURAL INSIGHTS

### Why This System Beats Traditional Approaches

**Traditional approach:**
```
Orchestrator holds full context
Agents are stateful and persistent
Shared state causes conflicts
Errors are handled with fallbacks
Testing is implicit
Human is asked at end
```

**This system:**
```
Orchestrator holds state + big picture
Agents are stateless + fresh each time
No shared state = no conflicts
Errors escalate to human explicitly
Testing is mandatory + visual
Human is asked immediately when needed
```

### The Context Window Optimization

```
Single 200k context could do everything:
- Analyze requirement
- Research technology
- Write code
- Test code
- Handle errors

Cost: Uses all 200k for one task

Split across agents:
- Orchestrator (200k): manage todos
- Research (fresh 100k): fetch docs
- Coder (fresh 100k): write code
- Tester (fresh 100k): verify code
- Stuck (fresh 100k): handle problems

Cost: Better efficiency, isolation benefits outweigh costs
Benefit: Each agent has ONLY the context it needs
```

### The "Stuck Agent" Innovation

Most systems try to handle errors internally. This system:
1. Explicitly prevents error handling ("NEVER fallback")
2. Routes errors to human decision point (stuck agent)
3. Makes human input mandatory (AskUserQuestion)
4. Blocks progress until human responds
5. Ensures visibility and control

This is **defensive design** - assumes agents WILL encounter problems and builds human oversight into the flow.

---

## 15. WHAT WOULD BREAK THIS SYSTEM

If any of these changed, the system would fail:

1. **Removing the stuck agent** - No escalation path, agents would fallback
2. **Adding shared state between agents** - Conflicts and race conditions
3. **Removing TodoWrite updates** - Lose progress visibility
4. **Skipping testing** - Implement untested, problems accumulate
5. **Removing mandatory escalation rules** - Agents would try to solve everything
6. **Combining multiple todos in one task** - Can't isolate problems
7. **Removing .research-cache** - Can't share knowledge between agents
8. **Removing Playwright from tester** - Visual verification impossible
9. **Removing AskUserQuestion from stuck agent** - Human not in loop
10. **Removing tool restrictions** - Agents could step on each other's toes

---

## CONCLUSION

This orchestration system achieves effectiveness through:

1. **Clear separation of concerns** - Each agent has one job
2. **Context isolation** - Fresh context per task prevents contamination
3. **Mandatory escalation** - No fallbacks, explicit human involvement
4. **Single source of truth** - Orchestrator maintains state
5. **Visual verification** - Playwright screenshots as proof
6. **File-based communication** - Simple, traceable handoffs
7. **Hardwired rules** - Instructions are specific and non-negotiable
8. **One task at a time** - Enables precise testing and debugging
9. **Tool allocation by role** - Prevents agents from exceeding authority
10. **Human in the loop** - Explicit decision points via stuck agent

The system's strength is not in what it does automatically, but in **how it structures human oversight** around automated task delegation. It's a framework for **confident automation with guaranteed human control**.

