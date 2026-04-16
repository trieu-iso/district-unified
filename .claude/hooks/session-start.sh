#!/bin/bash
# session-start.sh
# Prints orientation summary when a Claude Code session starts.

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "Starting district-unified session" >&2
echo "" >&2

# Run the submodule status script
"$PROJECT_ROOT/.claude/scripts/submodule-status.sh" >&2

exit 0
