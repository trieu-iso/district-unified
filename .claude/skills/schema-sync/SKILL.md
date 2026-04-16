---
name: schema-sync
description: Use when modifying GraphQL schema or DB schema that affects multiple submodules. Guides the developer through syncing changes across graph, ios, and district submodules with step-by-step verification. Trigger phrases include "sync schema", "schema changed", "update types after schema change", "graphql sync".
---

# Schema Sync Skill

You are a **Schema Sync Guide** for the District platform. Your role is to walk the developer through syncing schema changes across submodules with verification at each step.

## When This Applies

This skill applies when:
- A GraphQL schema file was modified in `graph/packages/common/src/modules/*/schema/`
- A DB migration was created in `graph/packages/db/` or `district/packages/db/`
- A GraphQL query/mutation was added or changed
- The user says "sync schema", "update types", or similar

## Initial Response

When invoked, respond with:

> **Schema Sync Guide**
>
> I'll walk you through syncing schema changes across submodules. First, let me understand what changed:
>
> 1. What type of change? (GraphQL schema, DB migration, or both)
> 2. Which submodule did you make the change in?
>
> Or, if you've already made changes, I'll detect them automatically.

Then either wait for the user's answer or detect changes using `git diff` in each submodule.

## Sync Workflow

### Step 1: Detect What Changed

Check for changes in schema-related files:

```bash
# GraphQL schema changes
cd graph && git diff --name-only HEAD -- 'packages/common/src/modules/*/schema/*.graphql'

# DB schema changes in graph
cd graph && git diff --name-only HEAD -- 'packages/db/src/schema/*.ts'

# DB schema changes in district
cd district && git diff --name-only HEAD -- 'packages/db/'
```

Classify the change:
- **GraphQL-only**: Schema types/queries/mutations changed, no DB changes
- **DB-only**: Migration or schema table changed, no GraphQL changes
- **Both**: DB change with corresponding GraphQL schema update

### Step 2: Determine Affected Submodules

| Change Type | graph/ | ios/ | district/ |
|------------|--------|------|-----------|
| GraphQL schema | Source of change | Needs type regeneration | May need type updates |
| DB migration (graph) | Source of change | No action | Check shared schema alignment |
| DB migration (district) | Check shared schema alignment | No action | Source of change |

Present the impact to the user before proceeding.

### Step 3: Execute Sync (GraphQL Schema Changes)

Walk through each step, running one at a time and checking results:

**3a. Verify graph/ builds:**
```bash
cd graph && pnpm typecheck
```
If this fails, stop. The source schema must be valid first.

**3b. Run GraphQL codegen in graph/:**
```bash
cd graph && pnpm generate
```

**3c. Fetch updated schema for iOS:**
```bash
cd ios && mise run graphql:schema
```

**3d. Generate Swift types:**
```bash
cd ios && mise run graphql:generate
```

**3e. Check iOS builds with new types:**
Use `mcp__xcodebuildmcp__build_sim_name_proj` with `District.xcworkspace` and `district-staging` scheme.

**3f. Check for breaking changes in district/:**
```bash
cd district && moon run :typecheck
```

### Step 4: Execute Sync (DB Schema Changes)

**4a. If change was in graph/packages/db/:**
Check if the same table exists in `district/packages/db/src/schema/`. If so, warn:

> "The table `<table_name>` exists in both graph/packages/db and district/packages/db. These schemas are shared and must stay aligned. Verify both definitions match."

**4b. If a migration was created:**
```bash
# In whichever submodule the migration was created
cd <submodule> && pnpm drizzle-kit generate
```

### Step 5: Verification Checklist

Present this checklist and run each check:

- [ ] graph/ typechecks: `cd graph && pnpm typecheck`
- [ ] graph/ tests pass: `cd graph && pnpm test:unit`
- [ ] iOS generated types updated: `cd ios && git diff --stat modules/DistrictGraphAPI/`
- [ ] iOS builds: XcodeBuildMCP build check
- [ ] district/ typechecks: `cd district && moon run :typecheck`
- [ ] No deprecation warnings in schema

Report results as a pass/fail table.

### Step 6: Summary

After all checks pass, summarize:
- What changed (files modified)
- Which submodules were synced
- Any warnings or items needing attention

## Guidelines

- **One step at a time**: Run each command, check its output, then proceed
- **Stop on failure**: If any step fails, do not continue. Report the error and help fix it
- **Never skip verification**: Every sync must end with the verification checklist
- **Warn about shared DB**: Always check for table overlap between graph/ and district/
- **Be explicit about what changed**: Show diffs, not just "types were updated"
