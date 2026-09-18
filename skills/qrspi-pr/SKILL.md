---
name: qrspi-pr
description: "QRSPI Phase 8: PR — Create the pull request with full design context drawn from the QRSPI artifacts. Use when all implementation slices are complete and the user wants to open a PR, or explicitly says 'qrspi pr'."
---

# QRSPI: PR

## Context

Create the pull request with full context from the design process. The PR description is rich because it draws from all the artifacts produced during the QRSPI workflow — the ticket, design decisions, implementation structure, and checkpoint results. This gives reviewers everything they need to understand why the code looks the way it does.

## Prerequisites

- All implementation slices must be complete (check tasks.json)

## Instructions

1. Locate the specs directory. Check for `.copilot-qrspi-active/` in the current directory first:
   ```bash
   ls .copilot-qrspi-active/tasks.json 2>/dev/null
   ```
   If not found, locate via the main repo:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_find_active_spec
   ```

2. Read `tasks.json` and verify all slices have `status: "complete"`. If any are incomplete, report which slices remain and suggest running the `qrspi-implement` skill first.

3. Read the following artifacts:
   - `manifest.json` (or `.copilot-qrspi-active/manifest.json`) — for branch name and ticket source
   - `ticket.md` — for the original requirement
   - `design.md` — for architectural decisions
   - `structure.md` — for the implementation approach

4. Gather the git diff information:
   ```bash
   git log --oneline main..HEAD
   git diff main...HEAD --stat
   ```

5. Generate the PR title following this repo's Conventional Commits standard: `<type>(scope): <short imperative description>` (see the team PR & Code Standards), kept under 70 characters.

6. Generate the PR body with these sections:

   **Summary** — 2-3 sentences describing what this PR does, derived from the ticket

   **Design Decisions** — Key decisions from design.md, condensed to the most important 3-5 points. Each should be a single sentence with brief rationale.

   **Changes** — Slice-by-slice summary of what was built. For each slice, one line describing what it delivers.

   **Testing** — What was tested and how, drawn from checkpoint results in tasks.json and structure.md checkpoints.

   **Related** — Links to the original ticket, and relative path to the design doc for full context.

7. Present the draft PR title and body to the user for review before creating it.

8. Wait for user approval or edits to the PR content.

9. Push the branch:
   ```bash
   git push -u origin {branch-name}
   ```
   If push fails due to network errors, retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s).

10. Create the PR as a draft:
    ```bash
    gh pr create --title "{title}" --body "{body}" --draft
    ```
    Use a HEREDOC for the body to preserve formatting.

11. Present the PR URL to the user.

12. Update `manifest.json`:
    ```bash
    source ~/.copilot/scripts/qrspi-utils.sh && qrspi_update_manifest <spec-dir> pr complete
    ```

13. Remind the user:
    - Review the PR themselves — they own this code (per team standards, no exceptions)
    - Add reviewers when ready
    - Undraft when ready for review
    - The design doc at `.copilot-qrspi-active/design.md` has full architectural context for reviewers
    - Do not self-merge; the PR author merges after approval, not the reviewer

## Output Format

**PR body format:**
```markdown
## Summary
{2-3 sentence description of the feature}

## Design Decisions
- **{Decision 1}:** {One sentence with rationale}
- **{Decision 2}:** {One sentence with rationale}
- **{Decision 3}:** {One sentence with rationale}

## Changes
| Slice | Description |
|---|---|
| {Slice 1 name} | {What it delivers} |
| {Slice 2 name} | {What it delivers} |
...

## Testing
- {Checkpoint 1}: {result}
- {Checkpoint 2}: {result}
...

## Related
- Ticket: {link or reference}
- Design doc: `.copilot-qrspi-active/design.md`
```

## Human Checkpoint

Present the draft PR title and body before creating it. The engineer reviews the description, may edit it, add context for reviewers, or adjust the title. The PR is created as a draft — the engineer undrafts it when they're ready for review.
