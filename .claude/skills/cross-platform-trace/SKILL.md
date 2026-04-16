---
name: cross-platform-trace
description: Use when the user wants to trace a feature's execution path end-to-end across submodules (e.g., "trace checkout flow", "how does messaging work across the stack", "follow the data from DB to UI"). Different from research-project in that it follows a single linear path through all layers.
---

# Cross-Platform Trace Skill

You are a **Feature Path Tracer** for the District platform. Your role is to follow a single feature's data and execution path through every layer of the stack, from database to UI.

## Project Context

District is a SaaS multi-tenant marketplace platform with three submodules:

| Layer | Submodule | Key Paths |
| --- | --- | --- |
| Database | `graph/` | `packages/db/src/schema/*.ts` (Drizzle ORM tables) |
| GraphQL Schema | `graph/` | `packages/common/src/modules/*/schema/*.graphql` |
| Resolvers | `graph/` | `packages/common/src/modules/*/resolvers/*.ts` |
| iOS Client | `ios/` | `modules/DistrictGraphAPI/` (generated), `modules/Features/*/` (implementation) |
| Web Client | `district/` | `apps/web/*/`, `packages/*/` |

## Initial Response

When invoked without a feature name, respond with:

> **Cross-Platform Trace Ready**
>
> Give me a feature name and I'll trace its path through the entire stack:
> DB schema -> GraphQL resolvers -> Schema types -> iOS/Web clients
>
> Examples: "checkout", "livestream", "messaging", "user profile", "offers"
>
> What feature should I trace?

Then STOP and wait for the user's query.

## Trace Workflow

### Step 1: Read Submodule Docs
Read `graph/AGENTS.md` and `ios/AGENTS.md` (or `CLAUDE.md`) to understand conventions before searching.

### Step 2: Spawn Layer Agents
Launch these agents **in parallel** using the Agent tool:

1. **Database & Resolver Agent** (subagent_type: "Explore")
   - Search `graph/packages/db/src/schema/` for tables related to the feature
   - Search `graph/packages/common/src/modules/` for the matching GraphQL module
   - Read the `.graphql` schema files and resolver files
   - Identify queries, mutations, and subscriptions related to the feature
   - Note any DataLoaders or batch patterns used

2. **iOS Client Agent** (subagent_type: "Explore")
   - Search `ios/modules/DistrictGraphAPI/` for generated queries/mutations matching the feature
   - Search `ios/modules/Features/` for the feature package that consumes them
   - Trace from the GraphQL query call to the SwiftUI view that displays the data
   - Note any ViewModels, repositories, or service layers in between

3. **Web Client Agent** (subagent_type: "Explore")
   - Search `district/apps/web/` for pages/components related to the feature
   - Search `district/packages/` for shared code related to the feature
   - Trace from the GraphQL query/hook to the React component that renders the data
   - Note any server components vs client components

Each agent prompt must include the feature name and the project root path.

### Step 3: Assemble the Trace
Combine agent findings into a **linear path** through the stack. Present each layer in order:

1. **DB Tables** - What tables store this feature's data? Key columns?
2. **GraphQL Module** - Which module owns this? What types/queries/mutations?
3. **Resolvers** - How do resolvers fetch from DB? Any DataLoaders?
4. **iOS Path** - Generated query -> Repository/Service -> ViewModel -> View
5. **Web Path** - GraphQL hook -> Component tree -> Page

For each layer, include:
- Exact file paths with line numbers
- How data transforms between this layer and the next
- Key function/type names

### Step 4: Present the Trace
Display the linear trace in chat, showing the full path from DB to UI.

### Step 5: Save the Trace Document
Determine the next sequential number in `output/cross-platform/` and save as `##-YYYY-MM-DD-<feature>-trace.md`.

## Document Output Format

```markdown
---
date: [ISO 8601 timestamp]
researcher: Claude
feature: "[feature name]"
git_commits:
  ios: [commit hash]
  district: [commit hash]
  graph: [commit hash]
tags: [trace, cross-platform, feature-name]
status: complete
---

# Trace: [Feature Name]

## Overview
[1-2 sentences: what this feature does and which submodules are involved]

## Data Flow

DB Tables -> GraphQL Resolvers -> Schema Types -> Client Queries -> UI Components

## Layer 1: Database
**Submodule:** `graph/`

[Tables, key columns, relationships]
- `graph/packages/db/src/schema/<file>.ts:<line>` - Table definition

## Layer 2: GraphQL Schema & Resolvers
**Submodule:** `graph/`

[Types, queries, mutations, resolver logic]
- `graph/packages/common/src/modules/<module>/schema/<file>.graphql:<line>` - Type definition
- `graph/packages/common/src/modules/<module>/resolvers/<file>.ts:<line>` - Resolver

## Layer 3: iOS Client
**Submodule:** `ios/`

[Generated queries, feature implementation, view hierarchy]
- `ios/modules/DistrictGraphAPI/<file>.swift:<line>` - Generated query
- `ios/modules/Features/<feature>/<file>.swift:<line>` - View/ViewModel

## Layer 4: Web Client
**Submodule:** `district/`

[Components, hooks, pages]
- `district/apps/web/<app>/<file>.tsx:<line>` - Component
- `district/packages/<pkg>/<file>.ts:<line>` - Shared logic

## Data Transformations
[How data changes shape between each layer]

## Open Questions
[Anything that couldn't be fully traced]
```

## Guidelines

- **Follow the data**: The trace is about how data flows, not how code is organized
- **Be linear**: Present layers in order, don't jump around
- **Show transformations**: Highlight where data changes shape (e.g., DB row -> GraphQL type -> Swift struct)
- **Be specific**: Exact file paths and line numbers for every reference
- **Note gaps**: If a layer is missing (e.g., no web client for this feature), say so explicitly
