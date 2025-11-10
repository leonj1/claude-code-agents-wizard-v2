#!/bin/bash

# Post-Standards Testing Hook
# This hook runs automatically after the coding-standards-checker agent completes
# It triggers the tester agent to verify functionality

set -e

# Parse the hook input from stdin
HOOK_INPUT=$(cat)

# Extract session info
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd')
SUBAGENT_NAME=$(echo "$HOOK_INPUT" | jq -r '.subagent_name // empty')

# Log hook execution
echo "🧪 Post-Standards Hook: Triggering testing" >&2
echo "   Session: $SESSION_ID" >&2
echo "   Subagent: $SUBAGENT_NAME" >&2

# Only trigger if this is the coding-standards-checker agent
if [ "$SUBAGENT_NAME" != "coding-standards-checker" ]; then
  echo "   Skipping: Not a coding-standards-checker completion" >&2
  exit 0
fi

# Create a state file to track that standards check has completed
STATE_DIR="$CWD/.claude/.state"
mkdir -p "$STATE_DIR"
echo "$(date -Iseconds)" > "$STATE_DIR/standards-checked-${SESSION_ID}"

# Output message to be shown in the transcript
cat <<EOF
{
  "continue": true,
  "systemMessage": "✅ Coding standards verified. Tester agent will be invoked automatically by the orchestrator."
}
EOF

exit 0
