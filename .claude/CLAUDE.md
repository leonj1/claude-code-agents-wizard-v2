# Project Configuration

This project uses Claude Code with specialized agents and hooks for orchestrated development workflows.

## Available Commands

### `/coder` - Orchestrated Development
Use this command when you want to implement features with full orchestration:
- Automatically breaks down tasks into to-do items
- Delegates implementation to specialized coder agents
- Enforces coding standards through automated checks
- Runs tests automatically after implementation
- Provides comprehensive quality gates

**When to use**: For implementing new features, building projects, or complex multi-step coding tasks.

**Example**: `/coder Build a REST API with user authentication`

### `/refactor` - Code Refactoring
Use this command to refactor existing code to adhere to coding standards.

**When to use**: When you need to improve code quality without changing functionality.

**Example**: `/refactor src/components/UserForm.js`

## Project Structure

- `.claude/agents/` - Specialized agent configurations
- `.claude/coding-standards/` - Code quality standards
- `.claude/commands/` - Custom slash commands
- `.claude/hooks/` - Automated workflow hooks
- `.claude/config.json` - Project configuration

## Hooks System

This project uses Claude Code hooks to automatically enforce quality gates:

### Configured Hooks

1. **post-coder-standards-check.sh** - Triggers coding standards check after coder completes
2. **post-standards-testing.sh** - Triggers testing after standards check passes

Hooks create state files in `.claude/.state/` to track workflow completion.

## Documentation Guidelines

- Place markdown documentation in `./docs/`
- Keep `README.md` in the root directory
- Ensure all header/footer links have actual pages (no 404s)

## General Usage

For exploratory tasks, questions, or non-coding requests, you can interact with Claude Code normally without using the `/coder` command. Use `/coder` specifically when you want the full orchestrated development workflow with quality gates.
