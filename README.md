# qrspi-copilot-skills

QRSPI (Questions → Research → Spec/Design → Plan → Implement) is a structured, phase-gated workflow for GitHub Copilot CLI agent sessions, designed to take a feature from ticket/idea to implementation with explicit human checkpoints between phases.

## Contents

- `scripts/qrspi-utils.sh` — shared bash helpers used by the skills (spec directory discovery, manifest management, prerequisite checks, repo name resolution, etc.)
- `skills/` — one skill per QRSPI phase, written for GitHub Copilot CLI's skill format:
  - `qrspi-init` — Phase 0: bootstrap a feature workspace from a ticket/issue/description
  - `qrspi-questions` — Phase 1: identify knowledge gaps with targeted questions
  - `qrspi-research` — Phase 2: gather objective codebase facts
  - `qrspi-design` — Phase 3: align on current/desired state and architectural decisions
  - `qrspi-structure` — Phase 4: define vertical slices with explicit signatures/types
  - `qrspi-plan` — Phase 5: tactical step-by-step implementation doc per slice
  - `qrspi-worktree` — Phase 6: create a git worktree and machine-readable task hierarchy
  - `qrspi-implement` — Phase 7: execute the plan slice by slice with human checkpoints
  - `qrspi-pr` — Phase 8: open the pull request with full design context

## Usage

1. Copy `scripts/qrspi-utils.sh` to `~/.copilot/scripts/qrspi-utils.sh` — every skill sources it from that exact path, so it must live there (create the `~/.copilot/scripts/` directory first if needed).
2. Copy the `skills/` directory's contents into your Copilot CLI skills location (e.g. `~/.copilot/skills/` or a project-level `.github/skills/`).
3. Invoke phases in order (e.g. "qrspi init", "qrspi questions", ...). Each phase reads/writes a `manifest.json` in the feature's spec directory to track progress and enforce prerequisites.

**Requirements:** `jq` must be installed (`brew install jq`). `qrspi-utils.sh` uses BSD `stat`/`date` syntax and is currently macOS-only.

## Acknowledgments

- The QRSPI methodology extends the RPI (Research-Plan-Implement) workflow originated by [Dex Horthy](https://github.com/dexhorthy), and is adapted from Alex Lavaee's blog post, [From RPI to QRSPI](https://alexlavaee.me/blog/from-rpi-to-qrspi/).
- `qrspi-utils.sh` is based on [jhuggart/dotfiles](https://github.com/jhuggart/dotfiles/blob/main/claude/scripts/qrspi-utils.sh).

