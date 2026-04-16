---
description: Run typecheck, lint, and tests for the graph (backend) submodule
---

# Check Graph

Run the full check suite for the graph submodule (without e2e tests, which need Docker):

```bash
cd graph && pnpm check:no-e2e
```

For the full suite including e2e tests (requires Docker running):
```bash
cd graph && pnpm check
```

$ARGUMENTS
