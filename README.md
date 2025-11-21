# Claude Code TDD Orchestration System 🚀

**AI agents write your tests first, then implement code to pass them—automatically.**

Type `/architect Build user auth` → Failing tests written → Code implemented → Quality checked → Done.

## What Is This?

A **Test-Driven Development system for Claude Code** that uses specialized AI agents to build software the right way:

1. **Tests written FIRST** (you get clear specifications before any code)
2. **Code written to pass tests** (implementation guided by tests)
3. **Quality gates applied automatically** (standards + visual testing)
4. **Human in the loop** (you decide when problems occur)

**The magic:** AI agents work in fresh contexts, each specialized for one job. The orchestrator maintains the big picture while agents handle individual tasks.

## Quick Start (3 minutes)

### Install

```bash
# Clone to temporary folder
git clone https://github.com/IncomeStreamSurfer/claude-code-agents-wizard-v2.git /tmp/claude-agents

# Copy to your project
cd /path/to/your/project
rsync -av /tmp/claude-agents/.claude/ ./.claude/
cp /tmp/claude-agents/.claude/CLAUDE.md ./AGENTS.md
rm -rf /tmp/claude-agents

# Start Claude Code
claude
```

### Your First Feature

```bash
/architect Build a user authentication system with JWT
```

**What happens:**
1. ✅ Architect creates optimized implementation plan
2. 🔴 Test-creator writes failing tests (TDD Red phase)
3. ✅ Coder implements code to make tests pass (TDD Green phase)
4. ✅ Standards checker enforces code quality
5. 👁️ Tester verifies with Playwright screenshots

**Result:** Working, tested feature with full quality gates.

## How It Works

### The TDD Flow

```plaintext
/architect "Build feature X"
    ↓
📝 Architect: Creates optimized prompt → saves to ./prompts/
    ↓
🔴 Test-Creator: Writes failing tests FIRST
    • Happy paths
    • Edge cases
    • Error handling
    ↓
✅ Coder: Implements code to pass ALL tests
    ↓
✅ Standards-Checker: Enforces coding standards
    ↓
👁️ Tester: Visual verification with Playwright
    ↓
✅ Done: Working code + comprehensive tests
```

### The Agents

- **🏗️ Architect** - Creates optimized implementation plans
- **🔴 Test-Creator** - Writes tests FIRST (TDD Red phase)
- **✍️ Coder** - Implements code to pass tests (TDD Green phase)
- **✅ Standards-Checker** - Enforces code quality rules
- **👁️ Tester** - Visual verification with Playwright
- **🆘 Stuck** - Asks you when ANY problem occurs (no silent fallbacks)

---

## 📖 Complete Guide

### All Available Commands

#### `/architect` - TDD Workflow (Recommended)

Best for new features. Tests written first, then implementation:

```bash
/architect Build a user authentication system with JWT
```

**Flow:** Architect → Test-Creator (Red) → Coder (Green) → Standards → Tester

**Why:** Tests first = clear specifications, better coverage, quality gates included

#### `/coder` - Direct Orchestration

For manual control and iterative todo-based development:

```bash
/coder Build a todo app with React and TypeScript
```

**Flow:** Creates todos → Coder (one todo at a time) → Standards → Tester → Repeat

**Why:** Manual control, iterative workflow, human oversight per todo

#### `/run-prompt` - Execute Saved Prompts

Run one or more prompts from `./prompts/` directory:

```bash
/run-prompt 005                    # Single prompt
/run-prompt 005 006 007 --parallel # Parallel execution
/run-prompt 005 006 --sequential   # Sequential execution
```

**Why:** Batch operations, flexible execution, intelligent routing (TDD vs direct vs research)

#### `/refactor` - Code Quality

```bash
/refactor src/utils.py    # Refactor specific file
/refactor src/services/   # Refactor directory
```

#### `/verifier` - Code Investigation

```bash
/verifier Does the codebase have email validation?
```

### Detailed Workflow Diagrams

<details>
<summary><strong>Click to see TDD Workflow diagram</strong></summary>

```plaintext
/architect "Build user authentication"
    ↓
📝 Architect: Creates optimized prompt
    ↓
🔴 Test-Creator: Writes failing tests
    • Happy paths, edge cases, errors
    • Verifies tests fail correctly
    ↓
✅ Coder: Implements code to pass tests
    • Problem? → Stuck agent asks you
    ↓
✅ Standards-Checker: Reviews code
    • Violations? → Back to coder
    ↓
👁️ Tester: Playwright verification
    • Fails? → Stuck agent asks you
    ↓
✅ Done: Working + tested code
```

</details>

<details>
<summary><strong>Click to see Direct Orchestration workflow diagram</strong></summary>

```plaintext
/coder "Build X"
    ↓
📝 Orchestrator: Creates todo list
    ↓
✅ Coder: Implements todo #1
    • Problem? → Stuck agent asks you
    ↓
✅ Standards-Checker: Reviews code
    • Violations? → Back to coder
    ↓
👁️ Tester: Verifies implementation
    • Fails? → Stuck agent asks you
    ↓
✅ Todo #1 complete → Next todo
    ↓
Repeat until all todos done ✅
```

</details>

### Why This Works

**Fresh Contexts = Specialized Focus**
- Each agent gets its own clean context window
- No context pollution or confusion
- Agents stay focused on their specific job

**TDD = Quality Built-In**
- Tests first = clear specifications before coding
- Implementation guided by tests
- Better coverage, fewer bugs

**Human in the Loop = No Silent Failures**
- Stuck agent asks you when problems occur
- No blind fallbacks or assumptions
- You maintain control

<details>
<summary><strong>Click to see detailed agent descriptions</strong></summary>

#### Architect Agent
- Analyzes requests, creates optimized prompts
- Determines parallel vs sequential execution
- Saves to `./prompts/` and auto-executes

#### Test-Creator Agent (TDD Red)
- Writes failing tests FIRST
- Covers happy paths, edge cases, errors
- Supports pytest, jest, Go test, etc.
- Provides clear specifications for coder

#### Coder Agent (TDD Green)
- Implements code to pass tests
- Reads coding standards
- Never uses fallbacks → invokes stuck agent

#### Standards-Checker Agent
- Enforces code quality rules
- No default args, dependency injection, etc.
- Violations → back to coder

#### Tester Agent
- Playwright visual verification
- Screenshots + interaction testing
- Never marks failing tests as passing

#### Stuck Agent
- ONLY agent that asks you questions
- Blocks progress until you respond
- Returns your decision to calling agent

</details>

### Real Example: User Authentication

<details>
<summary><strong>Click to see complete TDD workflow example</strong></summary>

```bash
You: /architect Build a user authentication system with JWT
```

**What happens:**

1. **Architect** creates `./prompts/001-user-authentication.md`

2. **Test-Creator** writes 6 failing tests:
   - `test_user_registration_with_valid_data()`
   - `test_user_login_with_valid_credentials()`
   - `test_jwt_token_generation()`
   - `test_jwt_token_validation()`
   - `test_authentication_with_invalid_credentials()`
   - `test_token_expiration()`

3. **Coder** implements:
   - User model
   - Registration logic
   - JWT token generation
   - Authentication middleware
   - All tests now pass ✅

4. **Standards-Checker** reviews code → No violations ✅

5. **Tester** verifies with Playwright:
   - Registration flow ✅
   - Login flow ✅
   - Takes screenshots

**Result:** Working auth system with 6 tests, all passing, fully validated.

</details>

### What Gets Installed

```
your-project/
├── .claude/
│   ├── agents/        # 6 specialized agents
│   ├── commands/      # 5 slash commands
│   ├── coding-standards/  # Quality rules
│   └── hooks/         # Quality gate automation
└── AGENTS.md          # Documentation
```

<details>
<summary><strong>Click to see full directory structure</strong></summary>

```
.
├── .claude/
│   ├── agents/
│   │   ├── test-creator.md
│   │   ├── coder.md
│   │   ├── coding-standards-checker.md
│   │   ├── tester.md
│   │   ├── refactorer.md
│   │   ├── verifier.md
│   │   └── stuck.md
│   ├── commands/
│   │   ├── architect.md
│   │   ├── run-prompt.md
│   │   ├── coder.md
│   │   ├── refactor.md
│   │   └── verifier.md
│   ├── coding-standards/
│   │   ├── general.md
│   │   ├── python.md
│   │   ├── typescript.md
│   │   ├── golang.md
│   │   └── dotnetcore.md
│   └── hooks/
│       ├── post-coder-standards-check.sh
│       └── post-standards-testing.sh
├── prompts/           # Generated by /architect
└── AGENTS.md
```

</details>

---

## Advanced Topics

<details>
<summary><strong>Best Practices</strong></summary>

1. **Use `/architect` for new features** - TDD workflow with tests first
2. **Review test specs** - Test-creator provides clear contracts
3. **Review screenshots** - Visual proof of every implementation
4. **Trust the stuck agent** - Answer when asked
5. **Trust the TDD process** - Red → Green → Refactor

</details>

<details>
<summary><strong>Pro Tips</strong></summary>

- Use `/architect` for new features (recommended)
- Use `/coder` for manual orchestration
- Use `/run-prompt --parallel` for batch operations
- Screenshots saved for review
- Frontmatter overrides: `executor: tdd | coder | general-purpose`
- Check `.claude/agents/*.md` for agent details

</details>

<details>
<summary><strong>How It Works Under the Hood</strong></summary>

Uses Claude Code's [subagent system](https://docs.claude.com/en/docs/claude-code/sub-agents):

- Slash commands (`.claude/commands/*.md`) activate workflows
- Subagents (`.claude/agents/*.md`) get fresh context windows
- Hooks (`.claude/hooks/*.sh`) automate quality gates
- Coding standards (`.claude/coding-standards/`) shared across agents
- Playwright MCP for visual testing

Each agent has specific tools and hardwired stuck agent escalation.

</details>

---

## Community & Support

- **[Income Stream Surfers YouTube](https://www.youtube.com/incomestreamsurfers)** - Tutorials and AI automation
- **[ISS AI Automation School](https://www.skool.com/iss-ai-automation-school-6342/about)** - Community
- **[SEO Grove](https://seogrove.ai)** - AI-powered SEO automation

---

**Ready to build something amazing?**

```bash
# In your project directory
claude

# Then use TDD workflow (recommended)
/architect Build a REST API with authentication
```

Tests written first → Code to pass tests → Quality gates → Done ✅

---

**Built by** [Income Stream Surfer](https://www.youtube.com/incomestreamsurfers) | **License:** MIT
