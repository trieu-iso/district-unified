# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

District is a SaaS multi-tenant marketplace platform (think Shopify x WhatNot x Discord). This unified repo links three submodules covering all platforms:

| Submodule | What | Stack |
| --- | --- | --- |
| `ios/` | Native iOS app | Swift, SwiftUI/UIKit, Tuist, SPM |
| `district/` | Web frontends, React Native (Android), shared packages | TypeScript, Next.js 16, React 19, Moonrepo, pnpm |
| `graph/` | Backend GraphQL API, workers, lambdas, infra | TypeScript, Yoga GraphQL, Drizzle ORM, AWS CDK, pnpm |

Each submodule has its own `AGENTS.md` (or `CLAUDE.md`) with detailed, submodule-specific guidelines. **Always read the relevant submodule's docs before working in it.**

## Git & SSH

This repo uses the `github-iso` SSH host alias (mapped to the `trieu-iso` GitHub account). All submodule URLs use `git@github-iso:isoapp/*`. If cloning or pushing fails with permission errors, verify the remote uses `github-iso` not `github.com`.

## Submodule Commands

```bash
git submodule update --init --recursive   # Initialize after clone
git submodule update --remote --merge     # Pull latest from all submodules
```

## iOS (`ios/`)

**Docs**: `ios/AGENTS.md` (symlinked as `ios/CLAUDE.md`)

### Setup
```bash
cd ios
mise trust && mise run install && mise run generate
```

### Build & Test
All Xcode operations use XcodeBuildMCP tools (never raw `xcodebuild`):
- Build: `mcp__xcodebuildmcp__build_sim_name_proj` (scheme: `district-staging`)
- Test: `mcp__xcodebuildmcp__test_sim_name_proj` (scheme: `district-unit-tests`)
- Package tests: `mcp__xcodebuildmcp__swift_package_test`

### Lint & Format
```bash
swiftlint lint --strict    # Lint (pinned 0.55.1 via mise)
swiftformat .              # Format (pinned 0.54.0 via mise)
```

### Key Architecture
- **Workspace**: Always use `District.xcworkspace`, never the `.xcodeproj`
- **Modules**: `modules/` contains SPM packages (Assets, DesignSystem, DistrictCore, DistrictGraphAPI, Features with 30+ feature packages)
- **Project generation**: Tuist generates the Xcode project from `Project.swift` -- don't edit project files manually; run `mise run generate` after config changes
- **GraphQL**: Three schemas (GraphSchema, DjangoSchema, HasuraSchema) under `modules/DistrictGraphAPI/`; generate with `mise run graphql:generate`
- **Resources**: Type-safe via R.swift; use `R.image.*` / `R.string.*` instead of string literals (enforced by SwiftLint custom rules)
- **DI**: Factory pattern (Needle is legacy)
- **Schemes**: `district-staging` (dev default), `district-alpha`, `district-production`, `district-debug-production`

### CI/CD
Bitrise CI with Fastlane. Alpha: tag `alpha/vX.Y.Z-rcN`. Production: tag `vX.Y.Z-rcN`.

## Web & Android (`district/`)

**Docs**: `district/AGENTS.md`

### Setup
```bash
cd district
proto use && pnpm install
```

### Build & Test
```bash
moon run <package>:check       # Typecheck + lint + test for one package
moon run <package>:typecheck   # Typecheck only (uses tsgo, never npx tsc)
moon run <package>:test        # Tests only (Bun test runner)
moon run <package>:fix         # Auto-fix lint/format
moon run :check                # All packages
```

### Lint & Format
- **Oxlint** (primary) + ESLint (legacy). Config: `packages/build-config/config/oxlint/parts/common.jsonc` and `react.jsonc`
- **Oxfmt** for formatting
- Read Oxlint rules before writing code -- they are strict and enforce "one way to do it"

### Key Architecture
- **Monorepo**: Moonrepo + pnpm workspaces. Moon IDs from `moon.yml` `id:` field (else directory name)
- **Apps**: `apps/web/` (Next.js 16 frontends: dashboard, discover, marketing, modweb), `apps/backend/` (Cloudflare Workers), `apps/native/bazaar` (React Native/Expo for Android)
- **Packages**: `@isoapp/*` scope in `packages/`. Key: `common` (isomorphic), `react-common`, `web-common`, `backend-common`, `db` (Drizzle schema/migrations), `web-modular-blocks`
- **React 19.2 + Compiler**: Use `use()` not `useContext`, skip `useCallback`/`useMemo`/`forwardRef`, use ref callbacks and `<Suspense>`
- **Next.js 16 PPR**: Cache Components with `<Suspense>` boundaries for partial pre-rendering
- **Tailwind 4**: Use TW4 syntax (e.g. `bg-(--color)` not `bg-[var(--color)]`)
- **Temporal**: Use `Temporal` APIs instead of `Date` (polyfilled globally except classic-web)
- **`exactOptionalPropertyTypes`**: `prop?: string` doesn't accept `undefined`; use `prop: string | undefined` when needed
- **Imports**: Use `##/*` for intra-package, `@isoapp/pkg/path` for cross-package. Never use relative imports. `.tsx` files require `.tsx` extension in import specifiers
- **No barrel files** except for composite components
- **classic-web warning**: Never use `apps/web/classic-web` for coding inspiration -- it's legacy

### Infrastructure
Pulumi with S3-backed state (no Pulumi Cloud). Read `district/docs/pulumi.md` before touching infra.

### CI/CD
GitHub Actions. Vercel for web deployments. PR titles must follow Conventional Commits.

## Backend (`graph/`)

**Docs**: `graph/AGENTS.md`

### Setup
```bash
cd graph
proto use && pnpm install
pnpm docker:start             # PostgreSQL + Redis via Docker
```

### Build & Test
```bash
pnpm dev:api                   # Start graph-server (watch mode)
pnpm dev:agents-api            # Start agents-api (watch mode)
pnpm typecheck                 # TypeScript checking (tsgo)
pnpm test:unit                 # Unit tests (Bun, .spec.ts files)
pnpm test:e2e                  # E2E tests (needs Docker, .e2e.ts files)
pnpm check                     # Full: typecheck + unit + lint + format + e2e
pnpm check:no-e2e              # CI check without e2e
pnpm generate                  # GraphQL codegen
```

### Lint & Format
```bash
pnpm lint                      # Oxlint
pnpm lint:fix                  # Oxlint auto-fix
pnpm format                    # Oxfmt
```

### Key Architecture
- **GraphQL**: Yoga server with GraphQL Modules. Schema in `packages/common/src/modules/*/schema/` with matching `resolvers/` folders
- **Apps**: `graph-server` (main API), `agents-api` (AI agents, Fastify), `live-realtime` (WebSocket), `graph-worker` (BullMQ -- **deprecated, do not add new jobs**), plus ~30 Lambda functions
- **Database**: Drizzle ORM on PostgreSQL. Schema in `packages/db/src/schema/*.ts` (hand-written, authoritative). Avoid Drizzle relational queries; use SQL-like syntax
- **N+1 prevention**: Use `DbLoader` for simple lookups, `scoped()` DataLoaders for complex queries. Never query inside field resolvers without batching
- **Imports**: Always absolute via tsconfig path aliases (`@/*`, `@server/*`, `@worker/*`, etc.). Never relative imports. No barrel exports
- **Patterns**: `ts-pattern` `match().exhaustive()` over switch; `radashi` utils; `date-fns` for dates; factory functions over classes
- **Test naming**: `.spec.ts` (unit) and `.e2e.ts` (integration). Never `.test.ts`
- **Environment**: Never modify `.env` files directly; use `.env.local` for overrides. Sync from Render via `pnpm pull:env:*`
- **Infra**: AWS CDK + SST. Entry point: `apps/cdk-core/cdk/app.ts`

### CI/CD
GitHub Actions. Render for API deployments. GraphQL Hive for schema management. PR titles must follow Conventional Commits.

## Cross-Cutting Conventions

- **PR titles**: All three repos enforce Conventional Commits (feat, fix, docs, style, refactor, perf, test, build, ci, revert)
- **PR bodies**: Must include a Test Plan section with checkbox format
- **GraphQL**: iOS consumes the graph server's schema. After schema changes in `graph/`, regenerate in `ios/` with `mise run graphql:schema && mise run graphql:generate`
- **Shared DB**: `district/packages/db` and `graph/packages/db` both define Drizzle schemas for the same PostgreSQL database
