---
name: qrspi-structure
description: "QRSPI Phase 4: Structure — Define vertical slices with explicit signatures and types (the feature's 'header file'). Use when the user has completed qrspi-design and wants to move to structure, or explicitly says 'qrspi structure'."
---

# QRSPI: Structure

## Context

Define the implementation path as vertical slices with explicit signatures and types. This is the "header file" for the feature — it specifies what will be built and in what order, without getting into step-by-step implementation details. Each slice is a thin end-to-end path that produces a testable, reviewable unit.

## Prerequisites

- Phase `design` must be complete (check manifest.json)

## Instructions

1. Locate the active spec directory:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_find_active_spec
   ```
   If the user names a specific feature, use `qrspi_spec_dir <feature-name>` instead.

2. Read `manifest.json` and verify `design` phase is complete:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_check_prereq <spec-dir> design
   ```

3. Read `design.md` from the spec directory.

4. Identify any **Shared Setup** that must happen before the first slice:
   - New dependencies to install
   - Database migrations to create
   - Configuration changes
   - New directories or project scaffolding
   - List these separately — they are done before Slice 1

5. Break the design into vertical slices following these principles:
   - Each slice delivers a thin end-to-end path (not a horizontal layer)
   - Order: mock/stub API → frontend integration → real data layer
   - Each slice produces something testable and reviewable
   - No slice should require more than ~200 lines of code changes
   - If a slice would be larger, split it into smaller slices
   - Identify dependencies between slices (which must complete before others)

6. For each slice, define:
   - **Name:** Short descriptive name
   - **Scope:** One-sentence description of what this slice delivers
   - **New/Modified Interfaces:** Function signatures, type definitions, API endpoints — with their purpose
   - **Files Touched:** Each file path with a brief description of what changes
   - **Checkpoint:** How to verify this slice works — specific tests to run and manual verification steps
   - **Dependencies:** Which slices (if any) must complete first

7. Generate `structure.md` with the shared setup and all slices.

8. Present the complete structure to the user. Ask them to review:
   - Slice ordering and dependencies
   - Scope and size of each slice (too big? too small?)
   - Interface signatures (do they match team conventions?)
   - Missing slices or unnecessary ones
   - Checkpoint adequacy (will these actually catch bugs?)

9. Wait for user feedback. Incorporate changes — reorder, split, merge, or modify slices as directed.

10. Once approved, write the final `structure.md` to the spec directory.

11. Update `manifest.json`:
    ```bash
    source ~/.copilot/scripts/qrspi-utils.sh && qrspi_update_manifest <spec-dir> structure complete
    ```

12. Confirm to the user and prompt them to proceed with the `qrspi-plan` skill when ready.

## Output Format

**structure.md:**
```markdown
# Implementation Structure: {Feature Name}

Date: YYYY-MM-DD
Design: design.md

## Shared Setup

- [ ] {Setup task 1 — e.g., Install dependency X}
- [ ] {Setup task 2 — e.g., Create migration for table Y}
...

---

## Slice 1: {Name}

**Scope:** {One sentence — what this slice delivers end-to-end}

**New/Modified Interfaces:**
- `functionName(param: Type): ReturnType` — {purpose}
- `interface/type Name { ... }` — {purpose}

**Files Touched:**
- `path/to/file.ts` — {what changes}
- `path/to/test.ts` — {what's tested}

**Checkpoint:**
- [ ] Test: {specific test description}
- [ ] Manual: {manual verification step}

**Dependencies:** None

---

## Slice 2: {Name}

**Scope:** {What this slice delivers}

**New/Modified Interfaces:**
...

**Files Touched:**
...

**Checkpoint:**
...

**Dependencies:** Slice 1

---

...
```

## Human Checkpoint

Review slice ordering, scope, and size. Verify that interface signatures match team conventions. Reorder, split, or merge slices as needed. Ensure checkpoints will actually catch regressions.
