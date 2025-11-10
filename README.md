# Claude Code Agent Orchestration System v2 🚀

A simple yet powerful orchestration system for Claude Code that uses specialized agents to manage complex projects from start to finish, with mandatory human oversight and visual testing.

## 🎯 What Is This?

This is a **custom Claude Code orchestration system** that transforms how you build software projects. Claude Code itself acts as the orchestrator with its 200k context window, managing the big picture while delegating individual tasks to specialized subagents:

- **🧠 Claude (You)** - The orchestrator with 200k context managing todos and the big picture
- **✍️ Coder Subagent** - Implements one todo at a time in its own clean context
- **✅ Coding Standards Checker Subagent** - Quality gatekeeper that enforces coding standards before testing
- **👁️ Tester Subagent** - Verifies implementations using Playwright in its own context
- **🆘 Stuck Subagent** - Human escalation point when ANY problem occurs

## ⚡ Key Features

- **No Fallbacks**: When ANY agent hits a problem, you get asked - no assumptions, no workarounds
- **Visual Testing**: Playwright MCP integration for screenshot-based verification
- **Todo Tracking**: Always see exactly where your project stands
- **Simple Flow**: Claude creates todos → delegates to coder → tester verifies → repeat
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

### Starting a Project

When you want to build something, just tell Claude your requirements:

```
You: "Build a todo app with React and TypeScript"
```

Claude will automatically:
1. Create a detailed todo list using TodoWrite
2. Delegate the first todo to the **coder** subagent
3. The coder implements in its own clean context window
4. The **coding-standards-checker** validates code quality
5. Delegate verification to the **tester** subagent (Playwright screenshots)
6. If ANY problem occurs, the **stuck** subagent asks you what to do
7. Mark todo complete and move to the next one
8. Repeat until project complete

**Optional**: Use the `/refactor` slash command to improve existing code quality:
```bash
/refactor src/utils.py          # Refactor a specific file
/refactor src/services/         # Refactor a directory
/refactor                       # Analyze entire project
```

### The Workflow

```
USER: "Build X"
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

### Coder Subagent
**Fresh Context Per Task**

- Gets invoked with ONE specific todo item
- Works in its own clean context window
- Reads coding standards from `.claude/coding-standards/`
- Writes clean, functional code following standards
- **Never uses fallbacks** - invokes stuck agent immediately
- Reports completion back to Claude

**When it's used**: Claude delegates each coding todo to this subagent

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

```
You: "Build a landing page with a contact form"

Claude creates todos:
  [ ] Set up HTML structure
  [ ] Create hero section
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

Claude invokes coder(todo #2: "Create hero section")

Coder (own context): Implements hero section
Coder: Reports completion to Claude

Claude invokes coding-standards-checker

Standards Checker (own context): Reviews hero section code
Standards Checker: VIOLATION - Function has default argument
Standards Checker: Invokes coder with violation report

Coder (own context): Fixes default argument violation
Coder: Reports completion to Claude

Claude invokes coding-standards-checker (re-check)

Standards Checker (own context): Reviews fixed code
Standards Checker: No violations found
Standards Checker: Reports compliance to Claude

Claude invokes tester("Verify hero section renders")

Tester (own context): Uses Playwright
Tester: ERROR - image file not found
Tester: Invokes stuck subagent

Stuck (own context): Asks YOU:
  "Hero image 'hero.jpg' not found. How to proceed?"
  Options:
  - Use placeholder image
  - Download from Unsplash
  - Skip image for now

You choose: "Download from Unsplash"

Stuck: Returns your decision to coder
Coder: Proceeds with Unsplash download
Coder: Reports completion to Claude

... and so on until all todos done
```

## 📁 Repository Structure

```
.
├── .claude/
│   ├── CLAUDE.md              # Orchestration instructions for main Claude
│   ├── agents/
│   │   ├── coder.md                      # Coder subagent definition
│   │   ├── refactorer.md                 # Refactorer subagent definition
│   │   ├── coding-standards-checker.md   # Standards checker subagent definition
│   │   ├── tester.md                     # Tester subagent definition
│   │   └── stuck.md                      # Stuck subagent definition
│   ├── commands/
│   │   └── refactor.md        # /refactor slash command (on-demand refactoring)
│   └── coding-standards/
│       ├── README.md         # Coding standards overview
│       ├── general.md        # Language-agnostic principles
│       ├── python.md         # Python-specific standards
│       ├── typescript.md     # TypeScript-specific standards
│       └── golang.md         # Go-specific standards
├── .mcp.json                  # Playwright MCP configuration
├── .gitignore
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

1. **CLAUDE.md** instructs main Claude to be the orchestrator
2. **Subagents** are defined in `.claude/agents/*.md` files
3. **Each subagent** gets its own fresh context window
4. **Main Claude** maintains the 200k context with todos and project state
5. **Playwright MCP** is configured in `.mcp.json` for visual testing

The magic happens because:
- **Claude (200k context)** = Maintains big picture, manages todos
- **Coder (fresh context)** = Implements one task at a time following standards
- **Coding Standards Checker (fresh context)** = Enforces standards compliance before testing
- **Tester (fresh context)** = Verifies one implementation at a time
- **Stuck (fresh context)** = Handles one problem at a time with human input
- **Refactorer (on-demand via `/refactor`)** = Improves existing code quality when needed
- **Coding standards** = Shared rules in `.claude/coding-standards/` that refactorer, coder, and standards checker follow
- **Each subagent** has specific tools and hardwired escalation rules

## 🎯 Best Practices

1. **Trust Claude** - Let it create and manage the todo list
2. **Review screenshots** - The tester provides visual proof of every implementation
3. **Make decisions when asked** - The stuck agent needs your guidance
4. **Don't interrupt the flow** - Let subagents complete their work
5. **Check the todo list** - Always visible, tracks real progress

## 🔥 Pro Tips

- Use `/agents` command to see all available subagents
- Use `/refactor` command to improve existing code quality on-demand
- Claude maintains the todo list in its 200k context - check anytime
- Screenshots from tester are saved and can be reviewed
- Each subagent has specific tools - check their `.md` files
- Subagents get fresh contexts - no context pollution!

## 📜 License

MIT - Use it, modify it, share it!

## 🙏 Credits

Built by [Income Stream Surfer](https://www.youtube.com/incomestreamsurfers)

Powered by Claude Code's agent system and Playwright MCP.

---

**Ready to build something amazing?** Just run `claude` in this directory and tell it what you want to create! 🚀
