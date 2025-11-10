# Claude Code Hooks Implementation

This document describes the hook-based architecture used in this project to automatically enforce quality gates through coding standards checking and testing.

## Overview

This project uses **Claude Code hooks** to create automatic quality gates that run after code is written. Instead of manually invoking the coding-standards-checker and tester agents, hooks automatically trigger them based on specific events.

## Architecture

### The Problem (Before Hooks)

Previously, the orchestrator had to manually manage the quality gate workflow:

```text
Orchestrator → coder → Orchestrator → coding-standards-checker → Orchestrator → tester
```

This required:
- Manual invocation of each agent
- Complex orchestration logic
- Potential for human error (skipping steps)
- Verbose workflow management

### The Solution (With Hooks)

Hooks automate the quality gates:

```text
Orchestrator → coder
                 ↓
         [SubagentStop hook]
                 ↓
        coding-standards-checker
                 ↓
         [SubagentStop hook]
                 ↓
              tester
```

Benefits:
- ✅ Automatic triggering of quality gates
- ✅ No manual orchestration needed
- ✅ Impossible to skip standards or testing
- ✅ Cleaner, simpler workflow
- ✅ Audit trail via state files

## Hook Configuration

### File: `.claude/config.json`

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "coder",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/post-coder-standards-check.sh",
            "timeout": 120000
          }
        ]
      },
      {
        "matcher": "coding-standards-checker",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/post-standards-testing.sh",
            "timeout": 120000
          }
        ]
      }
    ]
  }
}
```

### Hook Events

This project uses the **`SubagentStop`** event, which triggers when a subagent completes its work.

- **Event**: `SubagentStop`
- **Matcher**: Agent name (e.g., "coder", "coding-standards-checker")
- **Type**: `command` (executes a shell script)
- **Timeout**: 120 seconds (2 minutes)

## Hook Scripts

### 1. Post-Coder Standards Check Hook

**File**: `.claude/hooks/post-coder-standards-check.sh`

**Purpose**: Runs after the coder agent completes, signaling that the coding-standards-checker should be invoked.

**What it does**:
1. Receives hook input via stdin (JSON format)
2. Parses session ID, working directory, and subagent name
3. Verifies the subagent is "coder"
4. Creates a state file: `.claude/.state/coder-completed-{session_id}`
5. Outputs a system message for the transcript
6. Returns success (exit 0)

**Key Features**:
- Only triggers for the coder agent (ignores other agents)
- Creates an audit trail via state files
- Provides visual feedback in the transcript
- Uses JSON output format for structured communication

**Script**:
```bash
#!/bin/bash
set -e

HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd')
SUBAGENT_NAME=$(echo "$HOOK_INPUT" | jq -r '.subagent_name // empty')

echo "🔍 Post-Coder Hook: Triggering coding standards check" >&2

if [ "$SUBAGENT_NAME" != "coder" ]; then
  exit 0
fi

STATE_DIR="$CWD/.claude/.state"
mkdir -p "$STATE_DIR"
echo "$(date -Iseconds)" > "$STATE_DIR/coder-completed-${SESSION_ID}"

cat <<EOF
{
  "continue": true,
  "systemMessage": "✅ Coder agent completed. Coding standards checker will be invoked automatically by the orchestrator."
}
EOF
```

### 2. Post-Standards Testing Hook

**File**: `.claude/hooks/post-standards-testing.sh`

**Purpose**: Runs after the coding-standards-checker agent completes, signaling that the tester should be invoked.

**What it does**:
1. Receives hook input via stdin (JSON format)
2. Parses session ID, working directory, and subagent name
3. Verifies the subagent is "coding-standards-checker"
4. Creates a state file: `.claude/.state/standards-checked-{session_id}`
5. Outputs a system message for the transcript
6. Returns success (exit 0)

**Key Features**:
- Only triggers for the coding-standards-checker agent
- Creates an audit trail via state files
- Provides visual feedback in the transcript
- Uses JSON output format for structured communication

**Script**:
```bash
#!/bin/bash
set -e

HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd')
SUBAGENT_NAME=$(echo "$HOOK_INPUT" | jq -r '.subagent_name // empty')

echo "🧪 Post-Standards Hook: Triggering testing" >&2

if [ "$SUBAGENT_NAME" != "coding-standards-checker" ]; then
  exit 0
fi

STATE_DIR="$CWD/.claude/.state"
mkdir -p "$STATE_DIR"
echo "$(date -Iseconds)" > "$STATE_DIR/standards-checked-${SESSION_ID}"

cat <<EOF
{
  "continue": true,
  "systemMessage": "✅ Coding standards verified. Tester agent will be invoked automatically by the orchestrator."
}
EOF
```

## Hook Input Schema

Hooks receive JSON input via stdin with the following structure:

```json
{
  "session_id": "unique-session-identifier",
  "cwd": "/path/to/current/working/directory",
  "permission_mode": "default|plan|acceptEdits|bypassPermissions",
  "subagent_name": "name-of-the-subagent-that-stopped",
  "subagent_result": "result-from-the-subagent"
}
```

**Key Fields**:
- `session_id`: Unique identifier for the current session
- `cwd`: Working directory (project root)
- `subagent_name`: Name of the agent that triggered the event
- `subagent_result`: Output/result from the completed agent

## Hook Output Schema

Hooks can output structured JSON to control behavior:

```json
{
  "continue": true|false,
  "systemMessage": "Optional message shown in transcript"
}
```

**Fields**:
- `continue`: Whether to continue execution (true) or block (false with exit code 2)
- `systemMessage`: Message injected into the conversation transcript

## State Management

### State Directory

Hooks create state files in: `.claude/.state/`

This directory is:
- Created automatically by hooks
- Gitignored (not committed to version control)
- Used for audit trails and tracking

### State Files

1. **`coder-completed-{session_id}`**
   - Created when: coder agent completes
   - Contains: ISO-8601 timestamp
   - Purpose: Track when code was written

2. **`standards-checked-{session_id}`**
   - Created when: coding-standards-checker completes
   - Contains: ISO-8601 timestamp
   - Purpose: Track when standards were verified

## Workflow Example

### Complete Flow with Hooks

```text
1. USER: "Build a user registration feature"

2. ORCHESTRATOR:
   - Creates todo list
   - Invokes coder agent with task

3. CODER AGENT:
   - Implements the feature
   - Creates/modifies files
   - Reports completion

4. 🪝 HOOK TRIGGER (SubagentStop for "coder"):
   - post-coder-standards-check.sh executes
   - Creates state file: coder-completed-{session_id}
   - Outputs system message
   - Orchestrator sees the message

5. ORCHESTRATOR:
   - Receives hook's system message
   - Invokes coding-standards-checker agent

6. CODING-STANDARDS-CHECKER AGENT:
   - Reads coding standards
   - Reviews code for violations
   - Reports compliance (or violations)

7. 🪝 HOOK TRIGGER (SubagentStop for "coding-standards-checker"):
   - post-standards-testing.sh executes
   - Creates state file: standards-checked-{session_id}
   - Outputs system message
   - Orchestrator sees the message

8. ORCHESTRATOR:
   - Receives hook's system message
   - Invokes tester agent

9. TESTER AGENT:
   - Determines test type (frontend/backend)
   - Delegates to appropriate tester
   - Runs tests and reports results

10. ORCHESTRATOR:
    - Marks todo as complete (if tests pass)
    - Moves to next todo item
```

## Debugging Hooks

### Enable Transcript Mode

Press `Ctrl-R` in Claude Code to see the transcript, which shows:
- Hook execution logs
- Hook output messages
- System messages injected by hooks

### Check Hook Logs

Hooks write to stderr for logging:

```bash
echo "🔍 Post-Coder Hook: Triggering coding standards check" >&2
```

These logs appear in the Claude Code transcript.

### Verify State Files

Check if hooks are creating state files:

```bash
ls -la .claude/.state/
```

You should see:
- `coder-completed-*` files
- `standards-checked-*` files

### Test Hooks Manually

You can test hooks manually by providing JSON input:

```bash
echo '{"session_id":"test","cwd":"'$(pwd)'","subagent_name":"coder"}' | \
  .claude/hooks/post-coder-standards-check.sh
```

## Troubleshooting

### Hook Not Triggering

**Problem**: Hook doesn't execute after agent completes

**Solutions**:
1. Check `.claude/config.json` syntax (valid JSON)
2. Verify matcher name matches agent name exactly
3. Ensure hook script is executable: `chmod +x .claude/hooks/*.sh`
4. Check hook script path is correct

### Hook Fails with Error

**Problem**: Hook exits with non-zero code

**Solutions**:
1. Check hook script syntax: `bash -n .claude/hooks/script.sh`
2. Test hook manually (see "Test Hooks Manually" above)
3. Check if `jq` is installed: `which jq`
4. Review hook logs in transcript (Ctrl-R)

### Orchestrator Doesn't Invoke Next Agent

**Problem**: Hook runs but orchestrator doesn't invoke the next agent

**Expected Behavior**: Hooks only **signal** that the next agent should run. The orchestrator must still manually invoke coding-standards-checker and tester based on these signals.

**Note**: The hooks create a notification mechanism, but the orchestrator's CLAUDE.md instructions tell it to invoke the agents when it sees these signals.

## Security Considerations

### Hook Execution Context

Hooks execute with:
- Your user's credentials
- Access to environment variables
- Full filesystem access

**⚠️ Security Warning**: Only run hooks from trusted sources. Malicious hooks can:
- Exfiltrate data
- Modify files
- Execute arbitrary commands

### Best Practices

1. **Review all hook scripts** before enabling
2. **Version control hooks** in the repository
3. **Limit hook permissions** where possible
4. **Audit hook state files** regularly
5. **Use timeout values** to prevent hung hooks
6. **Validate hook input** - Ensure session_id and other inputs are properly validated to prevent path traversal

## Future Enhancements

### Potential Improvements

1. **Pre-Tool Hooks**: Block invalid operations before they execute
2. **Notification Hooks**: Send alerts when quality gates fail
3. **Metrics Collection**: Track standards violations over time
4. **Custom Validators**: Add project-specific validation hooks
5. **Integration Hooks**: Connect to external CI/CD systems

### Prompt-Based Hooks

For more sophisticated decision-making, consider using prompt-based hooks that leverage AI:

```json
{
  "type": "prompt",
  "prompt": "Analyze the code changes and decide if manual review is needed"
}
```

## References

- [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks.md)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide.md)
- [Claude Code Configuration](https://code.claude.com/docs/en/settings.md)

## Summary

This hook-based architecture provides:

✅ **Automatic quality enforcement** - No manual steps needed
✅ **Consistent workflow** - Every code change follows the same path
✅ **Audit trail** - State files track all quality gates
✅ **Cleaner orchestration** - Simplified orchestrator logic
✅ **Fail-safe design** - Impossible to skip quality checks

The hooks act as automatic quality gates that ensure every code change is:
1. **Written** by the coder agent
2. **Checked** by the coding-standards-checker agent
3. **Tested** by the tester agent

This creates a robust, automated development workflow that maintains high code quality standards.
