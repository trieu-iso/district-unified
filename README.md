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
