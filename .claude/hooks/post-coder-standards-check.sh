#!/bin/bash

# Post-Coder Standards Check Hook
# This hook runs automatically after the coder agent completes
# It triggers the coding-standards-checker agent to verify code quality

set -e

# Parse the hook input from stdin
HOOK_INPUT=$(cat)

# Extract session info
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd')
SUBAGENT_NAME=$(echo "$HOOK_INPUT" | jq -r '.subagent_name // empty')

# Log hook execution
echo "🔍 Post-Coder Hook: Triggering coding standards check" >&2
echo "   Session: $SESSION_ID" >&2
echo "   Subagent: $SUBAGENT_NAME" >&2

# Only trigger if this is the coder agent
if [ "$SUBAGENT_NAME" != "coder" ]; then
  echo "   Skipping: Not a coder agent completion" >&2
  exit 0
fi

# Create a state file to track that coder has completed
STATE_DIR="$CWD/.claude/.state"
mkdir -p "$STATE_DIR"
echo "$(date -Iseconds)" > "$STATE_DIR/coder-completed-${SESSION_ID}"

# Output message to be shown in the transcript
cat <<EOF
{
  "continue": true,
  "systemMessage": "✅ Coder agent completed. Coding standards checker will be invoked automatically by the orchestrator."
}
EOF

exit 0
