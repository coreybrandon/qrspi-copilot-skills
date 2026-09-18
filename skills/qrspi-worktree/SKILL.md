---
name: qrspi-worktree
description: "QRSPI Phase 6: Worktree — Create a git worktree and machine-readable task hierarchy for implementation. Use when the user has completed qrspi-plan and wants to move to worktree, or explicitly says 'qrspi worktree'."
---

# QRSPI: Worktree

## Context

Create an isolated git worktree for implementation and parse the plan into a machine-readable task list. This keeps the main workspace clean while the feature is being built, and gives the implement phase a structured task file to track progress slice by slice.

## Prerequisites

- Phase `plan` must be complete (check manifest.json)

## Instructions

1. Locate the active spec directory:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_find_active_spec
   ```
   If the user names a specific feature, use `qrspi_spec_dir <feature-name>` instead.

2. Read `manifest.json` and verify `plan` phase is complete:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_check_prereq <spec-dir> plan
   ```

3. Read the branch name and feature name from `manifest.json`.

4. Read `plan.md` from the spec directory.

5. **Exception — skip the worktree entirely:** Only if the user has explicitly stated they want to implement in-place on the current branch/checkout (e.g. "don't create a worktree", "implement here", "use my current branch") — skip straight to step 13, using the current working directory in place of `{worktree-path}` (i.e. write `tasks.json` to `.copilot-qrspi-active/tasks.json` in the repo root instead of a separate worktree, and skip branch/worktree creation). Never infer this on your own; only act on an explicit statement.

6. Determine the worktree path. By default:
   ```bash
   repo=$(source ~/.copilot/scripts/qrspi-utils.sh && qrspi_repo_name)
   worktree_path="../${repo}-${feature_name}"
   ```
   Present the proposed worktree path to the user for confirmation or override.

7. Wait for user confirmation of the worktree location.

8. Ensure the branch exists:
   ```bash
   git branch --list {branch-name}
   ```
   If it doesn't exist, create it: `git branch {branch-name}`

9. Create the git worktree:
   ```bash
   git worktree add {worktree-path} {branch-name}
   ```

10. Copy the spec directory into the worktree so artifacts are accessible during implementation:
   ```bash
   mkdir -p {worktree-path}/.copilot-qrspi-active
   cp -r <spec-dir>/* {worktree-path}/.copilot-qrspi-active/
   ```

11. Parse `plan.md` into a structured `tasks.json` file. Extract each slice and its steps:
    ```json
    {
      "feature": "{feature-name}",
      "repo": "{repo}",
      "worktree": "{worktree-path}",
      "slices": [
        {
          "name": "Slice 1: {slice name}",
          "status": "pending",
          "steps": [
            "Step 1 description",
            "Step 2 description"
          ],
          "tests": ["path/to/test.ts — description"],
          "checkpoint": {
            "commands": ["npm test -- --grep slice-1"],
            "passed": false
          }
        }
      ],
      "current_slice": 0
    }
    ```

12. If `plan.md` includes a **Shared Setup** section, include it as a special first entry in the slices array with `"name": "Shared Setup"`.

13. Write `tasks.json` to `{worktree-path}/.copilot-qrspi-active/tasks.json` (or, in the in-place exception from step 5, to `.copilot-qrspi-active/tasks.json` in the current directory).

14. Update `manifest.json` in the original spec directory:
    ```bash
    source ~/.copilot/scripts/qrspi-utils.sh && qrspi_update_manifest <spec-dir> worktree complete
    ```

15. Present to the user:
    - Worktree path and how to `cd` into it (or, if run in-place, confirm work will continue in the current directory)
    - Task breakdown summary (number of slices, total steps)
    - Instructions: "Open a new session in the worktree directory and invoke the qrspi-implement skill to start building" (or "run the qrspi-implement skill now" if in-place)

## Output Format

**tasks.json:** JSON object as specified in step 11.

The worktree will contain:
```
{worktree-path}/
├── .copilot-qrspi-active/
│   ├── ticket.md
│   ├── manifest.json
│   ├── questions.md
│   ├── research.md
│   ├── design.md
│   ├── structure.md
│   ├── plan.md
│   └── tasks.json
├── (all repo files on the feature branch)
```

## Human Checkpoint

Confirm the worktree location before creation. Optionally review the task breakdown. The user may adjust the worktree path if the default conflicts with their workspace layout.
