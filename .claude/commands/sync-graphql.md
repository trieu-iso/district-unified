---
description: Sync GraphQL schema changes from graph to iOS
---

# Sync GraphQL Schema

Guided workflow for syncing GraphQL schema changes from the graph submodule to the iOS submodule.

## Steps

1. **Check for uncommitted changes in graph/**:
   ```bash
   cd graph && git status --porcelain
   ```
   If dirty, warn the user and ask whether to proceed.

2. **Run GraphQL codegen in graph/**:
   ```bash
   cd graph && pnpm generate
   ```

3. **Fetch the latest schema for iOS**:
   ```bash
   cd ios && mise run graphql:schema
   ```

4. **Generate Swift types from the schema**:
   ```bash
   cd ios && mise run graphql:generate
   ```

5. **Verify iOS still builds**:
   Use `mcp__xcodebuildmcp__build_sim_name_proj` with `District.xcworkspace` and `district-staging` scheme.

6. **Report what changed**:
   ```bash
   cd ios && git diff --stat modules/DistrictGraphAPI/
   ```

If any step fails, stop and report the error. Do not continue to the next step.

$ARGUMENTS
