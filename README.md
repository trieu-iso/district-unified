# district-unified

A unified repository that links all District platform repos as git submodules for cross-platform development.

## Submodules

| Submodule | Repo | Description |
|-----------|------|-------------|
| `ios/` | [isoapp/ios](https://github.com/isoapp/ios) | District iOS native app |
| `district/` | [isoapp/district](https://github.com/isoapp/district) | Web and Android monorepo (TypeScript) |
| `graph/` | [isoapp/graph](https://github.com/isoapp/graph) | Backend monorepo |

## Getting Started

Clone with submodules:

```sh
git clone --recurse-submodules git@github-iso:trieu-iso/district-unified.git
```

If already cloned, initialize submodules:

```sh
git submodule update --init --recursive
```

## Updating Submodules

Pull latest changes for all submodules:

```sh
git submodule update --remote --merge
```

## Claude Code Setup

This repo includes a `.claude/` configuration that turns it into a cross-submodule command center.

### Commands

| Command | What it does |
|---------|-------------|
| `/build-ios` | Build iOS app via XcodeBuildMCP |
| `/test-ios` | Run iOS unit tests via XcodeBuildMCP |
| `/check-district` | Typecheck + lint + test the web/Android submodule |
| `/check-graph` | Typecheck + lint + unit test the backend submodule |
| `/check-all` | Run checks across all three submodules |
| `/lint-all` | Run linters across all three submodules |
| `/submodule-status` | Show git status of all submodules |
| `/submodule-update` | Pull latest for all submodules |
| `/sync-graphql` | Sync GraphQL schema changes from graph to iOS |

### Skills

| Skill | What it does |
|-------|-------------|
| `/research-project` | Comprehensive codebase research with parallel agents |
| `/cross-platform-trace` | Trace a feature end-to-end (DB -> GraphQL -> iOS/Web) |
| `/schema-sync` | Guided workflow for schema changes across submodules |
| `/submodule-health` | Detect drift and inconsistencies between submodules |

### Hooks

- **Session start**: Prints submodule status (branch, dirty state, ahead/behind) when a session begins
- **Submodule safety**: Blocks accidental `git commit`/`git push` inside submodules from the unified root

### Research Output

Research and trace documents are saved to `output/<platform>/` with sequential numbering:

```
output/
├── ios/           # iOS-focused research
├── web/           # Web/Android-focused research
├── backend/       # Backend-focused research
└── cross-platform/ # Cross-submodule research and health reports
```
