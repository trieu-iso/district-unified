---
description: Build the iOS app via XcodeBuildMCP
---

# Build iOS App

Navigate to the `ios/` submodule and build using XcodeBuildMCP tools.

Use `mcp__xcodebuildmcp__build_sim_name_proj` with:
- **Workspace**: `District.xcworkspace`
- **Scheme**: `district-staging`
- **Configuration**: `Debug-Staging`

If the build fails, check:
1. Has `mise run generate` been run recently?
2. Are dependencies resolved? (`mise run install`)
3. Is the workspace present? (Not the `.xcodeproj`)

$ARGUMENTS
