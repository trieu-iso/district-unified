---
description: Pull latest changes for all submodules
---

# Update All Submodules

Pull the latest from each submodule's remote and merge:

```bash
git submodule update --remote --merge
```

After updating, show what changed:

```bash
.claude/scripts/submodule-status.sh
```

If any submodule had merge conflicts, report them and stop. Do not force-resolve conflicts automatically.

$ARGUMENTS
