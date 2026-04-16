#!/bin/bash
# submodule-status.sh
# Prints a status summary for all three submodules.
# Used by session-start hook and /submodule-status command.

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SUBMODULES=("ios" "district" "graph")

# Unified repo info
UNIFIED_BRANCH=$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "detached")
echo "district-unified ($UNIFIED_BRANCH)"
echo ""

for sub in "${SUBMODULES[@]}"; do
  SUB_PATH="$PROJECT_ROOT/$sub"

  if [ ! -d "$SUB_PATH/.git" ] && [ ! -f "$SUB_PATH/.git" ]; then
    printf "  %-12s  (not initialized)\n" "$sub/"
    continue
  fi

  # Branch
  BRANCH=$(git -C "$SUB_PATH" branch --show-current 2>/dev/null)
  if [ -z "$BRANCH" ]; then
    BRANCH="detached"
  fi

  # Dirty state
  DIRTY_COUNT=$(git -C "$SUB_PATH" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$DIRTY_COUNT" -eq 0 ]; then
    STATE="clean"
  else
    STATE="dirty ($DIRTY_COUNT)"
  fi

  # Ahead/behind remote
  UPSTREAM=$(git -C "$SUB_PATH" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  if [ -n "$UPSTREAM" ]; then
    AHEAD=$(git -C "$SUB_PATH" rev-list --count "$UPSTREAM..HEAD" 2>/dev/null || echo "0")
    BEHIND=$(git -C "$SUB_PATH" rev-list --count "HEAD..$UPSTREAM" 2>/dev/null || echo "0")
    SYNC="ahead $AHEAD behind $BEHIND"
    if [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ]; then
      SYNC="up-to-date"
    fi
  else
    SYNC="no upstream"
  fi

  # Last commit
  LAST_COMMIT=$(git -C "$SUB_PATH" log -1 --format='%h "%s"' 2>/dev/null || echo "no commits")

  printf "  %-12s %-12s %-14s %-20s %s\n" "$sub/" "$BRANCH" "$STATE" "$SYNC" "$LAST_COMMIT"
done
