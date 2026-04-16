---
description: Run typecheck, lint, and tests for the district (web/Android) submodule
---

# Check District

Run the full check suite for the district submodule:

```bash
cd district && moon run :check
```

This runs typecheck (tsgo), lint (oxlint), and tests (bun) across all packages.

For a single package:
```bash
cd district && moon run <package>:check
```

$ARGUMENTS
