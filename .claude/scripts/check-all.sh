#!/bin/bash
# check-all.sh
# Runs checks in all three submodules sequentially and aggregates results.
# iOS: swiftlint --strict
# District: moon run :check
# Graph: pnpm check:no-e2e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

RESULTS=()
OVERALL_EXIT=0

run_check() {
  local name="$1"
  local dir="$2"
  shift 2
  local cmd=("$@")

  echo "=== Checking $name ==="
  echo "  Running: ${cmd[*]}"
  echo ""

  if [ ! -d "$dir" ]; then
    echo "  SKIP: $dir not found"
    RESULTS+=("$name/  SKIP  (directory not found)")
    echo ""
    return
  fi

  local output
  output=$(cd "$dir" && "${cmd[@]}" 2>&1)
  local rc=$?

  if [ $rc -eq 0 ]; then
    RESULTS+=("$name/  PASS")
  else
    RESULTS+=("$name/  FAIL")
    echo "$output" | tail -20
    OVERALL_EXIT=1
  fi
  echo ""
}

run_check "ios" "$PROJECT_ROOT/ios" swiftlint lint --strict --quiet
run_check "district" "$PROJECT_ROOT/district" moon run :check
run_check "graph" "$PROJECT_ROOT/graph" pnpm check:no-e2e

echo "=== Summary ==="
for result in "${RESULTS[@]}"; do
  printf "  %-14s\n" "$result"
done

exit $OVERALL_EXIT
