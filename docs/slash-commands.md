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
| Ask questions | None | Regular conversation |
| Explore codebase | None | Regular conversation |
| Quick fixes | None | Direct implementation |

## Tips

1. **Use `/coder` for projects**: When starting something new, activate orchestration mode
2. **Use `/refactor` for maintenance**: Clean up existing code periodically
3. **Skip commands for exploration**: Questions and research don't need workflows
4. **Trust the process**: Once activated, let the orchestration complete
5. **Respond to stuck agent**: When problems occur, provide guidance to continue

## Architecture

Both commands leverage the agent system:

- **`/coder`**: Activates orchestrator → coder → standards-checker → tester loop
- **`/refactor`**: Activates refactorer agent with coding standards focus

All commands use:
- Specialized subagents (`.claude/agents/`)
- Coding standards (`.claude/coding-standards/`)
- Automated hooks (`.claude/hooks/`)
- Human escalation (stuck agent when problems occur)

## More Information

- See `.claude/commands/coder.md` for full orchestrator instructions
- See `.claude/commands/refactor.md` for refactoring workflow
- See `.claude/CLAUDE.md` for project configuration
- See `README.md` for complete system documentation
