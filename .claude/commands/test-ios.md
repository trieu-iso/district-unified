---
description: Run iOS unit tests via XcodeBuildMCP
---

# Test iOS App

Navigate to the `ios/` submodule and run tests using XcodeBuildMCP tools.

Use `mcp__xcodebuildmcp__test_sim_name_proj` with:
- **Workspace**: `District.xcworkspace`
- **Scheme**: `district-unit-tests`

For package-specific tests, use `mcp__xcodebuildmcp__swift_package_test` with the relevant package path under `ios/modules/`.

$ARGUMENTS
