#!/bin/bash
# submodule-safety.sh
# PreToolUse hook for Bash: blocks git commit/push when the command
# targets a submodule directory from the unified repo root.
# Prevents accidental detached HEAD commits in submodules.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Only check git commit and git push commands
if ! echo "$COMMAND" | grep -qE '(git\s+commit|git\s+push)'; then
  exit 0
fi

# Check if the command cds into a submodule first
SUBMODULES=("ios" "district" "graph")
for sub in "${SUBMODULES[@]}"; do
  if echo "$COMMAND" | grep -qE "(cd\s+$sub|cd\s+\./$sub)"; then
    echo "Blocked: You're about to run git commit/push inside the '$sub/' submodule from the unified repo. cd into '$sub/' explicitly in a separate command and use its own git workflow instead." >&2
    exit 2
  fi
done

exit 0
