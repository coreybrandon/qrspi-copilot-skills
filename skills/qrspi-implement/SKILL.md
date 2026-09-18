---
name: qrspi-implement
description: "QRSPI Phase 7: Implement — Execute the implementation plan slice by slice with human checkpoints between each. Use when the user has completed qrspi-worktree and wants to start building, or explicitly says 'qrspi implement'."
---

# QRSPI: Implement

## Context

Execute the implementation plan slice by slice. Each slice is built, tested, reviewed by the human, and committed before moving to the next. Progress is tracked in `tasks.json` so the workflow survives session restarts. This is the most complex skill — it loops through slices, delegates scouting to sub-agents for context gathering, and manages human checkpoints between each slice.

## Prerequisites

- Phase `worktree` must be complete (check manifest.json or tasks.json existence)
- Should be run from inside the worktree directory (where `.copilot-qrspi-active/` exists)

## Instructions

1. Locate the specs directory. Check for `.copilot-qrspi-active/` in the current directory:
   ```bash
   ls .copilot-qrspi-active/tasks.json
   ```
   If not found, check if we're in the main repo and look for the worktree path in the manifest. Guide the user to `cd` into the worktree.

2. Read `tasks.json` from `.copilot-qrspi-active/`.

3. Find the next pending slice (first slice where `status` is `"pending"`).

4. If no pending slices remain:
   - Report that all slices are complete
   - Show a summary of what was built
   - Prompt the user to proceed with the `qrspi-pr` skill when ready
   - Stop here

5. Mark the current slice as `"in_progress"` in `tasks.json`. Write the update to disk immediately.

6. Load only the current slice's section from `.copilot-qrspi-active/plan.md`.

7. Load relevant design decisions from `.copilot-qrspi-active/design.md` — only the decisions that apply to this slice, not the entire document.

8. For each step in the current slice:
   a. If the step requires understanding current file state, delegate to a scout via the `task` tool (agent_type: `explore`) to read the file and summarize its current structure
   b. Implement the code change as specified in the plan
   c. Run any per-step verifications if applicable

9. After all steps in the slice are complete, run the slice's checkpoint commands:
   ```bash
   # Commands from tasks.json checkpoint.commands
   ```

10. If a checkpoint command fails:
    - Show the full error output to the user
    - Diagnose the failure — read error messages, check the code
    - Attempt to fix the issue
    - Re-run the checkpoint
    - If the fix doesn't work after 2 attempts, ask the user how to proceed

11. If the checkpoint passes:
    - Update `tasks.json`: mark the slice as `"complete"`, set `checkpoint.passed = true`
    - Advance `current_slice` to the next index
    - Write the updated `tasks.json` to disk

12. Present the completed slice to the user:
    - Summary of what was implemented
    - Checkpoint results (pass/fail, output)
    - Run `git diff --stat` to show what changed
    - Run `git diff` for a full view if the changes are small (≤100 lines), otherwise just show the stat

13. Wait for user review. The user may:
    - Approve the slice → proceed to commit
    - Request changes → iterate on the code, re-run checkpoints
    - Reject the slice → discuss and potentially revise the approach

14. Once approved, commit the slice:
    ```bash
    git add -A
    git commit -m "feat({feature-name}): slice {N} - {slice name}"
    ```

15. Check context utilization (aim to keep it under ~40%; treat ~60% as the signal to restart). If the session has been running for many slices and context is getting long:
    - Suggest the user re-invoke the `qrspi-implement` skill in a fresh session
    - `tasks.json` tracks progress, so the new session picks up exactly where this one left off

16. Loop back to step 3 for the next slice.

## Sub-Agent Tasks

Delegate scouting sparingly during implementation — only when you need to understand the current state of a file you haven't read yet, or to check how a pattern is used elsewhere in the codebase.

Scout prompt template:
```
Read {file-path} and summarize:
1. Current exports/public interface
2. Key functions and their signatures
3. How this file relates to {context from the current slice}
Return a <=30-line summary.
```

## Output Format

Progress is tracked in `tasks.json` which is updated after each slice:
```json
{
  "slices": [
    { "name": "Slice 1: ...", "status": "complete", "checkpoint": { "passed": true } },
    { "name": "Slice 2: ...", "status": "in_progress", "checkpoint": { "passed": false } },
    { "name": "Slice 3: ...", "status": "pending", "checkpoint": { "passed": false } }
  ],
  "current_slice": 1
}
```

Each slice produces a git commit with message format: `feat({feature-name}): slice {N} - {slice name}`

## Human Checkpoint

After each completed slice:
1. Show diff summary and checkpoint results
2. Wait for explicit approval before committing
3. Accept iteration requests — fix issues and re-present
4. Only advance to the next slice after human approval
