---
name: qrspi-plan
description: "QRSPI Phase 5: Plan — Tactical step-by-step implementation doc per slice. Use when the user has completed qrspi-structure and wants to move to plan, or explicitly says 'qrspi plan'."
---

# QRSPI: Plan

## Context

Generate the tactical implementation document. Because alignment was achieved in Design and Structure, this phase is relatively mechanical — it translates the approved structure into concrete steps. The human review here is a light spot-check, not a deep architectural review.

## Prerequisites

- Phase `structure` must be complete (check manifest.json)

## Instructions

1. Locate the active spec directory:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_find_active_spec
   ```
   If the user names a specific feature, use `qrspi_spec_dir <feature-name>` instead.

2. Read `manifest.json` and verify `structure` phase is complete:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_check_prereq <spec-dir> structure
   ```

3. Read `structure.md` and `design.md` from the spec directory.

4. For each slice defined in `structure.md`, generate a tactical plan:
   - Numbered implementation steps — each step specifies the file path and what to write/change
   - Keep each step concrete and actionable ("Add function X to file Y that does Z")
   - Reference the interface signatures from structure.md
   - Reference relevant design decisions from design.md where they inform implementation choices

5. For each slice, include:
   - **Steps:** Numbered list of concrete implementation actions
   - **Tests:** Test file paths and what to test
   - **Checkpoint:** Commands to run to verify the slice works (e.g., `npm test -- --grep "slice-1"`, `go test ./pkg/...`)

6. Keep each slice's plan to ≤30 lines. If a slice needs more than 30 lines of plan, it's too big — flag it to the user and suggest splitting.

7. If `structure.md` included a **Shared Setup** section, generate the plan for that first, before the slices.

8. Generate the complete `plan.md`.

9. Present to the user for spot-check review. At this point the plan is heavily constrained by the approved design and structure, so the review should be light. Ask them to flag anything that looks off.

10. Incorporate any feedback.

11. Once approved, write the final `plan.md` to the spec directory.

12. Update `manifest.json`:
    ```bash
    source ~/.copilot/scripts/qrspi-utils.sh && qrspi_update_manifest <spec-dir> plan complete
    ```

13. Confirm to the user and prompt them to proceed with the `qrspi-worktree` skill when ready.

## Output Format

**plan.md:**
```markdown
# Implementation Plan: {Feature Name}

Date: YYYY-MM-DD
Structure: structure.md
Design: design.md

## Shared Setup

1. {Concrete setup step with file path}
2. {Next setup step}

**Verify:** {command to confirm setup is correct}

---

## Slice 1: {Name}

### Steps
1. In `path/to/file.ts`, add {specific function/type/change}
2. In `path/to/other.ts`, modify {specific function} to {specific change}
3. ...

### Tests
- `path/to/test.ts` — Test that {specific behavior}

### Checkpoint
- `npm test -- --grep "slice-1"`
- Manual: {verification step}

---

## Slice 2: {Name}

### Steps
1. ...

### Tests
- ...

### Checkpoint
- ...

---

...
```

## Human Checkpoint

Light spot-check review. The plan is heavily constrained by the already-approved design and structure. Flag anything that looks wrong or unclear, but deep architectural review happened in earlier phases.
