---
description: Run linters across all three submodules
---

# Lint All Submodules

Run the appropriate linter for each submodule:

1. **iOS** (SwiftLint):
   ```bash
   cd ios && swiftlint lint --strict --quiet
   ```

2. **District** (Oxlint):
   ```bash
   cd district && pnpm oxlint
   ```

3. **Graph** (Oxlint):
   ```bash
   cd graph && pnpm lint
   ```

Run all three and report results. If any linter fails, show the failing output but continue running the remaining linters so all issues are surfaced at once.

$ARGUMENTS
