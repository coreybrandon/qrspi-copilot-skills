---
name: qrspi-questions
description: "QRSPI Phase 1: Questions — Identify knowledge gaps with targeted technical questions before research begins. Use when the user has completed qrspi-init and wants to move to the questions phase, or explicitly says 'qrspi questions'."
---

# QRSPI: Questions

## Context

Identify what the agent doesn't know before diving into research. Forces the model to think critically about the codebase through targeted technical questions organized by concern area. The human's domain expertise shapes these questions, which then drive the research phase.

## Prerequisites

- Phase `init` must be complete (check manifest.json)

## Instructions

1. Locate the active spec directory:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_find_active_spec
   ```
   If the user names a specific feature, use `qrspi_spec_dir <feature-name>` instead.

2. Read `manifest.json` and verify `init` phase is complete:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_check_prereq <spec-dir> init
   ```

3. Read `ticket.md` from the spec directory.

4. Analyze the ticket content and the current codebase context to generate 8–15 technical questions. Organize them into these concern areas:

   **Existing Patterns:**
   - What patterns does this codebase use for the relevant domain?
   - How are similar/related features currently implemented?

   **Data Flow:**
   - Where does the relevant data originate?
   - What transformations happen between key components?

   **Contracts & Interfaces:**
   - What public interfaces would be affected?
   - What do consumers of the affected modules expect?

   **Testing:**
   - What testing patterns exist for similar features?
   - What fixtures, factories, or test utilities are available?

   **Constraints:**
   - Are there performance requirements or SLAs?
   - Rate limits, auth boundaries, or security considerations?

   **Dependencies:**
   - What external services or libraries are involved?
   - Version constraints or compatibility concerns?

5. Present the complete question list to the user. Explain that they should:
   - Add questions the agent missed (domain knowledge the agent can't infer)
   - Remove questions that aren't relevant
   - Reword questions to be more specific to their codebase
   - Reorder by priority if desired

6. Wait for user feedback (use the ask_user tool if a focused decision is needed). Incorporate their additions, removals, and edits.

7. If the user provides changes, regenerate the list with their modifications and present again for final approval.

8. Once approved, write `questions.md` to the spec directory.

9. Update `manifest.json`:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_update_manifest <spec-dir> questions complete
   ```

10. Confirm to the user and prompt them to proceed with the `qrspi-research` skill when ready.

## Output Format

**questions.md:**
```markdown
# Technical Questions

Generated from: {ticket title}
Date: YYYY-MM-DD

## Existing Patterns
1. {question}
2. {question}

## Data Flow
3. {question}
4. {question}

## Contracts & Interfaces
5. {question}
6. {question}

## Testing
7. {question}
8. {question}

## Constraints
9. {question}
10. {question}

## Dependencies
11. {question}
12. {question}
```

## Human Checkpoint

Present the full question list for review. The user adds, removes, rewords, or reorders questions. This is where the engineer's domain expertise shapes the entire research phase — take their edits seriously and incorporate them fully.
