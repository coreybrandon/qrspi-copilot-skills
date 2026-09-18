---
name: qrspi-init
description: "QRSPI Phase 0: Init — Bootstrap a feature workspace from a ticket, issue, or description. Use when the user wants to start the QRSPI workflow (Questions-Research-Spec-Plan-Implement) for a new feature, or explicitly says 'qrspi init' / 'start qrspi'."
---

# QRSPI: Init

## Context

Bootstrap the feature workspace. Takes a ticket source (free text, GitHub issue URL/shorthand, ClickUp task ID/URL, or a local file), creates the spec directory structure, writes the initial ticket artifact and manifest, and creates the git branch. This is the entry point for the entire QRSPI workflow (Questions → Research → Design → Structure → Plan → Worktree → Implement → PR).

## Instructions

1. Determine the ticket source from the user's message:
   - GitHub issue URL (contains `github.com` and `/issues/`) → extract owner/repo and issue number
   - GitHub issue shorthand (`#42` or `org/repo#42`) → extract issue number
   - ClickUp task URL (contains `app.clickup.com/t/`) or a bare ClickUp task ID (typically a 6-9 character alphanumeric string, e.g. `86pjqmz`) → treat as **ClickUp**
   - A path to an existing local file (ends in `.md`/`.txt`, or otherwise resolves via `view`/`ls` to a real file on disk) → treat as a **local file** source
   - Anything else → treat as free text description
   - If the source is ambiguous or missing, ask the user for it before proceeding.

2. Fetch ticket content based on type:
   - **GitHub URL or shorthand:** Run `gh issue view <number> --json title,body,labels,assignees,comments` and capture the full output
   - **ClickUp task:** Use the `clickup_get_task` tool (ClickUp MCP server) with the extracted task ID to fetch title, description, status, assignees, and tags. If comments add useful context, also call `clickup_get_task_comments`. If the ClickUp MCP server is unavailable, ask the user to paste the ticket content instead.
   - **Local file:** Read the file's full contents as-is (preserve any existing headers/structure). Note the original file path so it can be recorded as the source and, if this is a pre-written design/spec doc rather than a short ticket, still copy it in verbatim — do not summarize or truncate it.
   - **Free text:** Use the provided text directly as the ticket content

3. Derive `{feature-name}` from the ticket title (or first line of free text):
   - Lowercase, replace non-alphanumeric chars with hyphens, collapse multiple hyphens, trim leading/trailing hyphens
   - Limit to 50 characters
   - Present the proposed name to the user for confirmation or override

4. Wait for user confirmation of the feature name. Accept any override they provide.

5. Derive `{repo}` by running:
   ```bash
   source ~/.copilot/scripts/qrspi-utils.sh && qrspi_repo_name
   ```

6. Create the spec directory:
   ```bash
   mkdir -p .copilot-qrspi/{repo}/specs/{feature-name}
   ```

7. Write `ticket.md` to the spec directory with:
   - A YAML-style header with source type, source URL (if applicable), and date
   - The raw ticket content (title, body, labels, comments — whatever was fetched)
   - Any metadata from the source (assignees, labels, ClickUp status, etc.)

8. Write `manifest.json` to the spec directory:
   ```json
   {
     "feature": "{feature-name}",
     "repo": "{repo}",
     "branch": "{feature-name}",
     "created": "ISO-8601-timestamp",
     "ticket_source": "github|clickup|file|text",
     "phases": {
       "init": { "status": "complete", "completed_at": "ISO-8601-timestamp" },
       "questions": { "status": "pending" },
       "research": { "status": "pending" },
       "design": { "status": "pending" },
       "structure": { "status": "pending" },
       "plan": { "status": "pending" },
       "worktree": { "status": "pending" },
       "implement": { "status": "pending" },
       "pr": { "status": "pending" }
     }
   }
   ```

9. Create the `.cache/` subdirectory inside the spec folder for future sub-agent scratch work:
   ```bash
   mkdir -p .copilot-qrspi/{repo}/specs/{feature-name}/.cache
   ```

10. Check if the git branch `{feature-name}` already exists:
    - If it exists locally, check it out
    - If not, create and checkout: `git checkout -b {feature-name}`
    - **Exception:** Only skip this branch creation/checkout step if the user has explicitly stated they want to stay on their current branch (e.g. "use my current branch", "don't create a new branch", "I already have a branch with work on it, use this one"). In that case, record the current branch name (`git branch --show-current`) as `"branch"` in the manifest instead, and do not run `git checkout -b`. Never infer this on your own from branch name or existing changes — only act on an explicit statement from the user.

11. Confirm to the user:
    - Feature name and branch created
    - Spec directory path
    - Summary of the ticket content
    - Prompt them to proceed with the `qrspi-questions` skill when ready

## Output Format

**ticket.md:**
```markdown
---
source: github|clickup|file|text
url: <source-url-if-applicable>
path: <original-local-file-path-if-applicable>
date: YYYY-MM-DD
---

# <Ticket Title>

<Full ticket body / description>

## Metadata
- Labels: ...
- Assignees: ...
- Comments: ...
```

**manifest.json:** JSON object as specified in step 8.

## Human Checkpoint

Present the derived feature name and branch name before creating them. The user must confirm or provide an override. Do not create the branch or directories until confirmed.
