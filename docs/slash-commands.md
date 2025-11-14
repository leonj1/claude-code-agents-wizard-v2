# Slash Commands Guide

This project provides specialized slash commands to activate different workflows in Claude Code.

## Available Commands

### `/coder` - Orchestrated Development

**Purpose**: Activate full orchestration mode for complex development projects.

**When to use**:
- Building new features from scratch
- Implementing multi-step projects
- When you want automatic quality gates (coding standards + testing)
- Projects that benefit from structured todo tracking

**Example usage**:
```
/coder Build a REST API with user authentication and JWT tokens
/coder Create a React dashboard with charts and data tables
/coder Implement a CLI tool for file processing
```

**What happens**:
1. Claude analyzes requirements and creates detailed todos
2. Each todo is delegated to the coder subagent
3. After implementation, coding-standards-checker validates code quality
4. After standards check, tester verifies functionality with Playwright
5. Human is consulted (via stuck agent) if any problems occur
6. Process repeats until all todos are complete

### `/refactor` - Code Quality Improvement

**Purpose**: Refactor existing code to meet coding standards without changing functionality.

**When to use**:
- Improving code quality in existing files
- Ensuring consistency with project coding standards
- Cleaning up technical debt
- Preparing code for production

**Example usage**:
```
/refactor src/utils.py                    # Single file
/refactor src/services/                   # Directory
/refactor                                 # Whole project
```

**What happens**:
1. Analyzes the specified code
2. Identifies violations of coding standards
3. Refactors code to meet standards
4. Preserves all existing functionality
5. Reports changes made

### `/verifier` - Code Verification and Investigation

**Purpose**: Investigate source code to verify claims, answer questions, or determine if queries are true/false.

**When to use**:
- Verifying claims about the codebase
- Answering questions about code structure or functionality
- Investigating specific code patterns or features
- Determining if certain implementations exist
- Fact-checking architectural decisions

**Example usage**:
```bash
/verifier Does the codebase have email validation?
/verifier Is this project using microservices architecture?
/verifier Are there any functions that handle user authentication?
/verifier Does the API support pagination?
```

**What happens**:
1. Parses the query or claim
2. Uses memory-efficient search strategy (Glob/Grep before Read)
3. Gathers concrete evidence from the codebase
4. Formulates determination (TRUE/FALSE/PARTIALLY TRUE/CANNOT DETERMINE)
5. Provides structured report with file paths, line numbers, and code snippets
6. Escalates to stuck agent if query is ambiguous or evidence is insufficient

## When NOT to Use Slash Commands

You don't need slash commands for:
- **Exploring the codebase** - Just ask questions normally
- **Reading files or understanding code** - Use normal conversation
- **Quick one-off changes** - Small edits don't need orchestration
- **Answering questions** - Get explanations without workflows
- **Debugging investigations** - Explore issues conversationally

## Command Comparison

| Task | Command | Notes |
|------|---------|-------|
| Build new feature | `/coder` | Full orchestration with quality gates |
| Improve existing code | `/refactor` | Quality-focused, no new features |
| Verify claims | `/verifier` | Evidence-based investigation |
| Ask questions | None | Regular conversation |
| Explore codebase | None | Regular conversation |
| Quick fixes | None | Direct implementation |

## Tips

1. **Use `/coder` for projects**: When starting something new, activate orchestration mode
2. **Use `/refactor` for maintenance**: Clean up existing code periodically
3. **Use `/verifier` for fact-checking**: Verify claims about the codebase with evidence
4. **Skip commands for exploration**: Questions and research don't need workflows
5. **Trust the process**: Once activated, let the orchestration complete
6. **Respond to stuck agent**: When problems occur, provide guidance to continue

## Architecture

All commands leverage the agent system:

- **`/coder`**: Activates orchestrator → coder → standards-checker → tester loop
- **`/refactor`**: Activates refactorer agent with coding standards focus
- **`/verifier`**: Activates verifier agent for evidence-based investigation

All commands use:
- Specialized subagents (`.claude/agents/`)
- Coding standards (`.claude/coding-standards/`)
- Automated hooks (`.claude/hooks/`)
- Human escalation (stuck agent when problems occur)

## More Information

- See `.claude/commands/coder.md` for full orchestrator instructions
- See `.claude/commands/refactor.md` for refactoring workflow
- See `.claude/commands/verifier.md` for verification workflow
- See `.claude/CLAUDE.md` for project configuration
- See `README.md` for complete system documentation
