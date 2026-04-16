---
description: Run checks across all three submodules
---

# Check All Submodules

Run the cross-submodule check script:

```bash
.claude/scripts/check-all.sh
```

This runs sequentially:
1. **ios/** — `swiftlint lint --strict`
2. **district/** — `moon run :check` (typecheck + lint + test)
3. **graph/** — `pnpm check:no-e2e` (typecheck + lint + unit tests)

Results are aggregated into a summary table at the end.

$ARGUMENTS
