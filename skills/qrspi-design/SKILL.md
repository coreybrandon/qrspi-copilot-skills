---
name: qrspi-design
description: "QRSPI Phase 3: Design — Align on current state, desired end state, and architectural decisions. The highest-leverage review point in the workflow. Use when the user has completed qrspi-research and wants to move to design, or explicitly says 'qrspi design'."
---

# QRSPI: Design

## Context

The critical alignment phase — "brain surgery." The agent synthesizes its understanding of the current codebase (from research) with the desired feature (from the ticket) into a structured design document. This is where the human and agent align on architectural decisions before any code is written. This phase may iterate multiple times — that's expected and correct.

## Prerequisites

- Phase `research` must be complete (check manifest.json)

## Instructions

1. Locate the active spec directory:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_find_active_spec
   ```
   If the user names a specific feature, use `qrspi_spec_dir <feature-name>` instead.

2. Read `manifest.json` and verify `research` phase is complete:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_check_prereq <spec-dir> research
   ```

3. Read `ticket.md` from the spec directory. This is where the ticket is reintroduced after being deliberately excluded from research.

4. Read `research.md` from the spec directory.

5. Generate a ~200-line `design.md` with these sections:

   **Current State** — Summary of how the relevant parts of the codebase work today, drawn entirely from research.md. Include:
   - Architecture of affected components
   - Current data flow through relevant paths
   - Existing patterns the feature must integrate with

   **Desired End State** — What the system should look like after this feature ships, derived from the ticket. Include:
   - User-visible behavior changes
   - System-level changes
   - What success looks like

   **Key Design Decisions** — A numbered list of architectural choices. For each decision include:
   - The decision itself (clear, declarative statement)
   - Why this approach (reference patterns found in research)
   - What alternatives were considered and why they were rejected
   - What this decision implies downstream (testing, migration, performance)

   **Affected Components** — List of files/modules that will change, with a brief description of the nature of the change for each.

   **Risk Assessment** — What could go wrong:
   - Migration concerns
   - Backward compatibility issues
   - Performance implications
   - Edge cases that need handling

   **Open Questions for Human** — Anything the agent is uncertain about. Explicit "I don't know" signals. Things that require domain expertise or organizational context to resolve.

6. Present the complete `design.md` to the user for review. Explain this is the highest-leverage review point — their feedback here prevents wrong turns during implementation.

7. Wait for user feedback. The user may:
   - Redirect wrong patterns ("we moved away from that, use X instead")
   - Resolve design ambiguities
   - Catch wrong assumptions the research missed
   - Approve or modify the end-state vision
   - Answer the open questions
   - Edit `design.md` directly in their editor

8. If the user provides corrections or feedback:
   - Incorporate all changes
   - Rewrite the affected sections of `design.md`
   - Present the updated version for re-review
   - Repeat until the user approves

9. Once approved, write the final `design.md` to the spec directory.

10. Update `manifest.json`:
    ```bash
    source ~/.copilot/scripts/qrspi-utils.sh && qrspi_update_manifest <spec-dir> design complete
    ```

11. Confirm to the user and prompt them to proceed with the `qrspi-structure` skill when ready.

## Output Format

**design.md:**
```markdown
# Design: {Feature Name}

Date: YYYY-MM-DD
Ticket: {source reference}

## Current State

{How the relevant parts of the codebase work today}

## Desired End State

{What the system should look like after this feature ships}

## Key Design Decisions

### 1. {Decision title}
**Decision:** {Clear declarative statement}
**Rationale:** {Why this approach, referencing research findings}
**Alternatives considered:** {What else was considered and why rejected}
**Implications:** {What this means for testing, migration, performance}

### 2. {Next decision}
...

## Affected Components

| File/Module | Change Description |
|---|---|
| `path/to/file.ts` | {Brief description of change} |
...

## Risk Assessment

- **{Risk category}:** {Description and mitigation}
...

## Open Questions

1. {Question requiring human domain expertise}
...
```

## Human Checkpoint

This is the highest-leverage review in the entire workflow. Present the design for thorough review. Expect and welcome multiple rounds of iteration. The engineer's corrections here prevent cascading errors in structure, plan, and implementation. Do not rush past this phase.
