# Claude Code Agent Orchestration System v2 🚀

A simple yet powerful orchestration system for Claude Code that uses specialized agents to manage complex projects from start to finish, with mandatory human oversight and visual testing.

## 🎯 What Is This?

This is a **custom Claude Code orchestration system** that transforms how you build software projects using Test-Driven Development (TDD). Claude Code itself acts as the orchestrator with its 200k context window, managing the big picture while delegating individual tasks to specialized subagents:

- **🏗️ Architect Agent** - Expert prompt engineer that creates optimized implementation plans
- **🔴 Test-Creator Agent** - TDD specialist that writes tests FIRST (Red phase)
- **✍️ Coder Agent** - Implements code to make tests pass (Green phase)
- **✅ Coding Standards Checker Agent** - Quality gatekeeper that enforces coding standards
- **👁️ Tester Agent** - Verifies implementations using Playwright with screenshots
- **🆘 Stuck Agent** - Human escalation point when ANY problem occurs
- **🧠 Claude (You)** - The orchestrator with 200k context managing the big picture

## ⚡ Key Features

- **Test-Driven Development**: Tests written FIRST, then implementation follows (Red → Green → Refactor)
- **No Fallbacks**: When ANY agent hits a problem, you get asked - no assumptions, no workarounds
- **Visual Testing**: Playwright MCP integration for screenshot-based verification
- **Automatic Quality Gates**: Standards checks and testing applied to all code
- **Intelligent Routing**: Auto-detects task types and routes to appropriate workflow
- **Parallel Execution**: Run multiple independent tasks simultaneously
- **Human Control**: The stuck agent ensures you're always in the loop

## 🚀 Quick Start

### Prerequisites

1. **Claude Code CLI** installed ([get it here](https://docs.claude.com/en/docs/claude-code))
2. **Node.js** (for Playwright MCP)

### Installation

```bash
# Clone this repository to a temporary folder
git clone https://github.com/IncomeStreamSurfer/claude-code-agents-wizard-v2.git /tmp/claude-agents

# Navigate to your project root directory
cd /path/to/your/project

# Copy the .claude directory to your project
rsync -av /tmp/claude-agents/.claude/ ./.claude/

# Copy the orchestration documentation to your project root
cp /tmp/claude-agents/.claude/CLAUDE.md ./AGENTS.md

# Clean up temporary folder
rm -rf /tmp/claude-agents

# Start Claude Code in your project directory
claude
```

That's it! The agents are now configured in your project:
- `.claude/` directory contains all agent definitions and coding standards
- `AGENTS.md` in your project root documents the orchestration system

## 📖 How to Use

### Test-Driven Development with `/architect` (Recommended)

For new features and implementations, use the `/architect` command to follow TDD best practices:

```
You: "/architect Build a user authentication system with JWT"
```

**The `/architect` command flow:**
1. **Architect** analyzes your request and creates optimized, XML-structured prompts
2. Automatically saves prompts to `./prompts/` directory
3. Automatically invokes `/run-prompt` to execute the prompts
4. **test-creator** agent writes comprehensive failing tests first (TDD Red phase)
5. **coder** agent implements code to make tests pass (TDD Green phase)
6. **coding-standards-checker** validates code quality
7. **tester** verifies functionality with Playwright screenshots
8. Process repeats for each feature

**Why use `/architect`?**
- ✅ Tests written first ensure clear specifications
- ✅ Better test coverage from the start
- ✅ Implementation guided by tests
- ✅ Full quality gates applied automatically
- ✅ Supports parallel or sequential execution of multiple features

**Complete TDD Flow:**
```
/architect → creates prompts → /run-prompt → test-creator (Red) → coder (Green) → standards → tester
```

### Direct Orchestration with `/coder`

For manual control and iterative development, use the `/coder` slash command:

```
You: "/coder Build a todo app with React and TypeScript"
```

The `/coder` command activates orchestration mode, where Claude will:
1. Create a detailed todo list using TodoWrite
2. Delegate the first to-do to the **coder** subagent
3. The coder implements in its own clean context window
4. The **coding-standards-checker** validates code quality
5. Delegate verification to the **tester** subagent (Playwright screenshots)
6. If ANY problem occurs, the **stuck** subagent asks you what to do
7. Mark to-do complete and move to the next one
8. Repeat until project complete

### Execute Saved Prompts with `/run-prompt`

Execute one or more prompts from the `./prompts/` directory:

```bash
/run-prompt 005                    # Execute prompt 005
/run-prompt 005 006 007 --parallel # Execute three prompts in parallel
/run-prompt 005 006 --sequential   # Execute two prompts sequentially
```

**Intelligent routing:**
- Code tasks → TDD workflow (test-creator → coder → standards → tester)
- Research tasks → general-purpose agent (no quality gates)
- Can override with frontmatter in prompt files

### Other Commands

**`/refactor`** - Improve existing code quality:
```bash
/refactor src/utils.py          # Refactor a specific file
/refactor src/services/         # Refactor a directory
/refactor                       # Analyze entire project
```

**`/verifier`** - Investigate and verify code:
```bash
/verifier Does the codebase have email validation?
```

### General Usage

For exploratory tasks, questions, or non-coding requests, interact with Claude Code normally without specialized commands. Use:
- **`/architect`** for new features with TDD approach (recommended)
- **`/coder`** for direct orchestrated implementation with manual control
- **`/run-prompt`** for executing saved prompts
- **`/refactor`** for code quality improvements
- **`/verifier`** for code investigation

### The Workflows

#### TDD Workflow (`/architect` command)
```
USER: "/architect Build user authentication"
    ↓
ARCHITECT: Analyzes request, creates optimized prompts
    ↓
ARCHITECT: Saves to ./prompts/XXX-feature.md
    ↓
ARCHITECT: Automatically invokes /run-prompt
    ↓
RUN-PROMPT: Detects code task → routes to TDD workflow
    ↓
TEST-CREATOR (own context): Writes failing tests (Red phase)
    ├─→ Creates test files
    ├─→ Covers happy paths, edge cases, errors
    ├─→ Verifies tests fail correctly
    ↓
TEST-CREATOR: Reports tests created
    ↓
CODER (own context): Implements code to pass tests (Green phase)
    ├─→ Reads test specifications
    ├─→ Implements feature
    ├─→ Problem? → Invokes STUCK → You decide → Continue
    ↓
CODER: Reports completion
    ↓
CODING-STANDARDS-CHECKER (own context): Reviews code
    ├─→ Violations found? → Back to CODER → Re-check
    ↓
STANDARDS CHECKER: Reports compliance
    ↓
TESTER (own context): Playwright verification
    ├─→ Test fails? → Invokes STUCK → You decide → Continue
    ↓
TESTER: Reports success
    ↓
Feature complete with full test coverage ✅
```

#### Direct Orchestration Workflow (`/coder` command)
```
USER: "/coder Build X"
    ↓
CLAUDE: Creates detailed todos with TodoWrite
    ↓
CLAUDE: Invokes coder subagent for todo #1
    ↓
CODER (own context): Implements feature
    ↓
    ├─→ Problem? → Invokes STUCK → You decide → Continue
    ↓
CODER: Reports completion
    ↓
CLAUDE: Invokes coding-standards-checker subagent
    ↓
STANDARDS CHECKER (own context): Reviews code against standards
    ↓
    ├─→ Violations found? → Invokes CODER with fixes → Re-check
    ↓
STANDARDS CHECKER: Reports compliance
    ↓
CLAUDE: Invokes tester subagent
    ↓
TESTER (own context): Playwright screenshots & verification
    ↓
    ├─→ Test fails? → Invokes STUCK → You decide → Continue
    ↓
TESTER: Reports success
    ↓
CLAUDE: Marks todo complete, moves to next
    ↓
Repeat until all todos done ✅
```

## 🛠️ How It Works

### Claude (The Orchestrator)
**Your 200k Context Window**

- Creates and maintains comprehensive todo lists
- Sees the complete project from A-Z
- Delegates individual todos to specialized subagents
- Tracks overall progress across all tasks
- Maintains project state and context

**How it works**: Claude IS the orchestrator - it uses its 200k context to manage everything

### Architect Agent
**Prompt Engineering Specialist**

- Analyzes user requests and creates optimized prompts
- Uses XML structuring and best practices
- Intelligently determines single vs multiple prompts
- Determines parallel vs sequential execution strategy
- Saves prompts to `./prompts/` directory
- Automatically invokes `/run-prompt` to execute

**When it's used**: When you use `/architect` command for new features

### Test-Creator Agent (TDD Red Phase)
**Fresh Context Per Feature**

- Gets invoked FIRST for code tasks (TDD approach)
- Works in its own clean context window
- Writes comprehensive failing tests before implementation
- Covers happy paths, edge cases, and error handling
- Supports multiple testing frameworks (pytest, jest, Go test, etc.)
- Verifies tests fail for the RIGHT reasons
- Provides clear specifications for coder agent

**When it's used**: First step in TDD workflow for all code tasks

**Why it exists**: Tests written first provide clear specifications and ensure comprehensive test coverage

### Coder Agent (TDD Green Phase)
**Fresh Context Per Task**

- Gets invoked with ONE specific task and test specifications
- Works in its own clean context window
- Reads coding standards from `.claude/coding-standards/`
- Implements code to make failing tests pass
- **Never uses fallbacks** - invokes stuck agent immediately
- Reports completion back to orchestrator

**When it's used**: After test-creator provides tests, or directly via `/coder` command

### Coding Standards Checker Subagent
**Fresh Context Per Review**

- Gets invoked after each coder completion
- Works in its own clean context window
- Reads coding standards from `.claude/coding-standards/`
- Verifies code against ALL coding standards
- **Critical violations**: Sends code back to coder with detailed fixes
- **No violations**: Passes code to tester
- Uses Grep tool to efficiently scan for common violations
- Enforces: no default arguments, no env var access, dependency injection, thin controllers, etc.

**When it's used**: Claude invokes this IMMEDIATELY after coder completes, BEFORE testing begins

**Why it exists**: Ensures 100% coding standards compliance before any testing. Acts as a quality gatekeeper - no non-compliant code reaches the tester.

### Tester Subagent
**Fresh Context Per Verification**

- Gets invoked after each coder completion
- Works in its own clean context window
- Uses **Playwright MCP** to see rendered output
- Takes screenshots to verify layouts
- Tests interactions (clicks, forms, navigation)
- **Never marks failing tests as passing**
- Reports pass/fail back to Claude

**When it's used**: Claude delegates testing after every implementation

### Stuck Subagent
**Fresh Context Per Problem**

- Gets invoked when coder or tester hits a problem
- Works in its own clean context window
- **ONLY subagent** that can ask you questions
- Presents clear options for you to choose
- Blocks progress until you respond
- Returns your decision to the calling agent
- Ensures no blind fallbacks or workarounds

**When it's used**: Whenever ANY subagent encounters ANY problem

## 🚨 The "No Fallbacks" Rule

**This is the key differentiator:**

Traditional AI: Hits error → tries workaround → might fail silently
**This system**: Hits error → asks you → you decide → proceeds correctly

Every agent is **hardwired** to invoke the stuck agent rather than use fallbacks. You stay in control.

## 💡 Example Session

### TDD Workflow Example

```
You: "/architect Build a user authentication system with JWT"

Architect: Analyzes request
Architect: Creates prompt: ./prompts/001-user-authentication.md
Architect: Automatically invokes /run-prompt 001

Run-Prompt: Detects code task → routes to TDD workflow

Test-Creator (own context): Writes comprehensive failing tests
  - test_user_registration_with_valid_data()
  - test_user_login_with_valid_credentials()
  - test_jwt_token_generation()
  - test_jwt_token_validation()
  - test_authentication_with_invalid_credentials()
  - test_token_expiration()

Test-Creator: Runs tests → All fail (expected, no implementation yet)
Test-Creator: Reports 6 failing tests created ✓ (Red phase complete)

Coder (own context): Reads test specifications
Coder: Implements User model
Coder: Implements registration logic
Coder: Implements JWT token generation
Coder: Implements authentication middleware
Coder: Runs tests → All pass ✓ (Green phase complete)
Coder: Reports completion

Coding Standards Checker (own context): Reviews authentication code
Standards Checker: Checking for violations...
Standards Checker: No violations found ✓
Standards Checker: Reports compliance

Tester (own context): Uses Playwright to verify
Tester: Tests registration flow → Success ✓
Tester: Tests login flow → Success ✓
Tester: Takes screenshots of auth pages
Tester: Reports all tests passing ✓

Feature complete with full TDD cycle! ✅
```

### Direct Orchestration Example

```
You: "/coder Build a contact form"

Claude creates todos:
  [ ] Set up HTML structure
  [ ] Add contact form with validation
  [ ] Style with CSS
  [ ] Test form submission

Claude invokes coder(todo #1: "Set up HTML structure")

Coder (own context): Creates index.html
Coder: Reports completion to Claude

Claude invokes coding-standards-checker

Standards Checker (own context): Reviews index.html
Standards Checker: No violations found
Standards Checker: Reports compliance to Claude

Claude invokes tester("Verify HTML structure loads")

Tester (own context): Uses Playwright to navigate
Tester: Takes screenshot
Tester: Verifies HTML structure visible
Tester: Reports success to Claude

Claude: Marks todo #1 complete ✓

... and so on until all todos done
```

## 📁 Repository Structure

```
.
├── .claude/
│   ├── CLAUDE.md              # Project configuration and documentation
│   ├── agents/
│   │   ├── test-creator.md               # TDD specialist (writes tests first)
│   │   ├── coder.md                      # Implementation specialist
│   │   ├── coding-standards-checker.md   # Quality gatekeeper
│   │   ├── tester.md                     # Visual verification with Playwright
│   │   ├── refactorer.md                 # Code quality improvement
│   │   ├── verifier.md                   # Code investigation specialist
│   │   └── stuck.md                      # Human escalation
│   ├── commands/
│   │   ├── architect.md      # /architect - TDD workflow (creates prompts)
│   │   ├── run-prompt.md     # /run-prompt - Execute saved prompts
│   │   ├── coder.md          # /coder - Direct orchestration
│   │   ├── refactor.md       # /refactor - Code quality improvement
│   │   └── verifier.md       # /verifier - Code investigation
│   ├── coding-standards/
│   │   ├── README.md         # Coding standards overview
│   │   ├── general.md        # Language-agnostic principles
│   │   ├── python.md         # Python-specific standards
│   │   ├── typescript.md     # TypeScript-specific standards
│   │   ├── golang.md         # Go-specific standards
│   │   └── dotnetcore.md     # .NET Core-specific standards
│   └── hooks/
│       ├── post-coder-standards-check.sh    # Triggers standards check
│       └── post-standards-testing.sh        # Triggers testing
├── prompts/                   # Generated prompts (by /architect)
├── .mcp.json                  # Playwright MCP configuration
├── .gitignore
├── AGENTS.md                  # Orchestration system documentation
└── README.md
```

## 🎓 Learn More

### Resources

- **[SEO Grove](https://seogrove.ai)** - AI-powered SEO automation platform
- **[ISS AI Automation School](https://www.skool.com/iss-ai-automation-school-6342/about)** - Join our community to learn AI automation
- **[Income Stream Surfers YouTube](https://www.youtube.com/incomestreamsurfers)** - Tutorials, breakdowns, and AI automation content

### Support

Have questions or want to share what you built?
- Join the [ISS AI Automation School community](https://www.skool.com/iss-ai-automation-school-6342/about)
- Subscribe to [Income Stream Surfers on YouTube](https://www.youtube.com/incomestreamsurfers)
- Check out [SEO Grove](https://seogrove.ai) for automated SEO solutions

## 🤝 Contributing

This is an open system! Feel free to:
- Add new specialized agents
- Improve existing agent prompts
- Share your agent configurations
- Submit PRs with enhancements

## 📝 How It Works Under the Hood

This system leverages Claude Code's [subagent system](https://docs.claude.com/en/docs/claude-code/sub-agents):

1. **CLAUDE.md** provides project documentation and guidelines
2. **Slash commands** (`.claude/commands/*.md`) activate specific workflows
3. **Subagents** are defined in `.claude/agents/*.md` files
4. **Each subagent** gets its own fresh context window
5. **Main Claude** maintains the 200k context with project state
6. **Hooks** (`.claude/hooks/*.sh`) automate quality gate signaling
7. **Playwright MCP** is configured in `.mcp.json` for visual testing

The magic happens because:
- **Architect (fresh context)** = Creates optimized prompts with intelligent routing
- **Test-Creator (fresh context)** = Writes failing tests first (TDD Red phase)
- **Coder (fresh context)** = Implements code to pass tests (TDD Green phase)
- **Coding Standards Checker (fresh context)** = Enforces standards compliance
- **Tester (fresh context)** = Verifies functionality with visual testing
- **Stuck (fresh context)** = Handles problems with human input
- **Refactorer (on-demand via `/refactor`)** = Improves existing code quality
- **Verifier (on-demand via `/verifier`)** = Investigates codebase
- **Hooks system** = Automatically signals when to invoke quality gates
- **Coding standards** = Shared rules in `.claude/coding-standards/`
- **Each subagent** has specific tools and hardwired escalation rules

## 🎯 Best Practices

1. **Use `/architect` for new features** - Gets you TDD workflow with tests written first
2. **Review test specifications** - Test-creator provides clear contracts for implementation
3. **Review screenshots** - The tester provides visual proof of every implementation
4. **Make decisions when asked** - The stuck agent needs your guidance
5. **Don't interrupt the flow** - Let subagents complete their work
6. **Trust the TDD process** - Red (failing tests) → Green (implementation) → Refactor

## 🔥 Pro Tips

- **Use `/architect`** for new features with TDD approach (recommended)
- **Use `/coder`** for direct orchestration with manual control
- **Use `/run-prompt`** to execute saved prompts (supports parallel execution)
- **Use `/refactor`** to improve existing code quality on-demand
- **Use `/verifier`** to investigate and verify codebase claims
- Screenshots from tester are saved and can be reviewed
- Prompts support frontmatter to override executor (tdd, coder, or general-purpose)
- Each subagent has specific tools - check their `.md` files in `.claude/agents/`
- Subagents get fresh contexts - no context pollution!
- For exploration or questions, use Claude normally without slash commands

## 📜 License

MIT - Use it, modify it, share it!

## 🙏 Credits

Built by [Income Stream Surfer](https://www.youtube.com/incomestreamsurfers)

Powered by Claude Code's agent system and Playwright MCP.

---

**Ready to build something amazing?** Just run `claude` in this directory! 🚀

**TDD Workflow (Recommended):**
```
/architect Build a REST API with authentication and user management
```

**Direct Orchestration:**
```
/coder Build a REST API with authentication and user management
```

The TDD workflow writes tests first, then implements code to pass them - ensuring better quality and test coverage from the start!
