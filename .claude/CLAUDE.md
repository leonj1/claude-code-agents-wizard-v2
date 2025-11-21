# Project Configuration

This project uses Claude Code with specialized agents and hooks for orchestrated development workflows.

## Available Commands

### `/architect` - Test-Driven Development Workflow
Use this command to create implementation prompts following TDD best practices:
- Expert prompt engineer creates optimized, XML-structured prompts
- Automatically routes to Test-Driven Development workflow
- Tests are written FIRST by test-creator agent (Red phase)
- Implementation follows to make tests pass (Green phase)
- Full quality gates: standards checks and testing
- Supports parallel or sequential execution of multiple prompts

**When to use**: For new features, implementations, or any coding task where you want TDD approach.

**Example**: `/architect Build a user authentication system with JWT`

**Flow**: architect → run-prompt → test-creator → coder → standards → tester

### `/coder` - Orchestrated Development
Use this command when you want to implement features with full orchestration:
- Automatically breaks down tasks into to-do items
- Delegates implementation to specialized coder agents
- Enforces coding standards through automated checks
- Runs tests automatically after implementation
- Provides comprehensive quality gates

**When to use**: For implementing new features, building projects, or complex multi-step coding tasks where you want direct manual orchestration.

**Example**: `/coder Build a REST API with user authentication`

### `/run-prompt` - Execute Saved Prompts
Use this command to execute one or more prompts from `./prompts/` directory:
- Automatically detects task type (TDD, direct code, or research)
- Routes to appropriate workflow based on task type
- Supports parallel execution with `--parallel` flag
- Supports sequential execution with `--sequential` flag
- Can specify executor via frontmatter in prompt files

**When to use**: To execute prompts created by `/architect` or manually created prompts.

**Examples**:
- `/run-prompt 005` (execute prompt 005)
- `/run-prompt 005 006 007 --parallel` (execute three prompts in parallel)
- `/run-prompt 005 006 --sequential` (execute two prompts sequentially)

### `/refactor` - Code Refactoring
Use this command to refactor existing code to adhere to coding standards.

**When to use**: When you need to improve code quality without changing functionality.

**Example**: `/refactor src/components/UserForm.js`

### `/verifier` - Code Verification and Investigation
Use this command to investigate source code and verify claims, answer questions, or determine if queries are true/false.

**When to use**: When you need to verify a claim about the codebase, answer questions about code structure or functionality, or investigate specific code patterns.

**Example**: `/verifier Does the codebase have email validation?`

## Project Structure

- `.claude/agents/` - Specialized agent configurations
  - `test-creator.md` - TDD specialist that writes tests first
  - `coder.md` - Implementation specialist
  - `coding-standards-checker.md` - Code quality verifier
  - `tester.md` - Functionality verification
  - `refactorer.md` - Code refactoring specialist
  - `verifier.md` - Code investigation specialist
  - `stuck.md` - Human escalation agent
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

## Workflow Comparison

### TDD Workflow (`/architect` → `/run-prompt`)
**Best for**: New features, clean implementations, comprehensive test coverage

**Flow**:
1. `/architect` creates optimized prompts
2. Automatically invokes `/run-prompt`
3. `test-creator` agent writes failing tests (TDD Red)
4. `coder` agent implements code to pass tests (TDD Green)
5. `coding-standards-checker` verifies code quality
6. `tester` validates functionality

**Benefits**:
- Tests written first ensure clear specifications
- Better test coverage
- Implementation guided by tests
- Full quality gates

### Direct Implementation (`/coder`)
**Best for**: Quick fixes, manual orchestration, iterative development

**Flow**:
1. Orchestrator breaks down task into todos
2. `coder` agent implements each todo
3. `coding-standards-checker` verifies code quality
4. `tester` validates functionality
5. Repeat for each todo item

**Benefits**:
- Manual control over task breakdown
- Direct implementation without test-first approach
- Iterative todo-based workflow

### Prompt Execution (`/run-prompt`)
**Best for**: Executing pre-created prompts, batch operations

**Flow**:
- Detects task type (TDD, direct code, or research)
- Routes to appropriate workflow
- Can execute multiple prompts in parallel or sequential
- Supports executor override via frontmatter

**Benefits**:
- Flexible execution strategies
- Batch processing
- Intelligent routing

## General Usage

For exploratory tasks, questions, or non-coding requests, you can interact with Claude Code normally without using specialized commands. Use:
- `/architect` for new features with TDD approach
- `/coder` for direct orchestrated implementation
- `/run-prompt` for executing saved prompts
- `/refactor` for code quality improvements
- `/verifier` for code investigation
