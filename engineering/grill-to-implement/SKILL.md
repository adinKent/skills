---
name: grill-to-implement
description: End-to-end feature delivery pipeline that runs /grill-with-docs -> /to-spec -> /to-tickets -> /implement-spec. Only Stage 1 (grill-with-docs) interacts with the user to resolve design decisions; once grilling completes, to-spec, to-tickets, and implement-spec execute automatically without further user prompts until implementation and code review are complete.
disable-model-invocation: true
compatibility: OpenCode, Claude Code, Antigravity, Cursor
metadata:
  workflow: grill-to-implement-pipeline
  stages: grill-with-docs, to-spec, to-tickets, implement-spec
---

# Grill-to-Implement Pipeline (`/grill-with-docs` -> `/to-spec` -> `/to-tickets` -> `/implement-spec`)

Run the complete four-stage engineering pipeline from initial idea to verified code:

1. **Stage 1: `/grill-with-docs` (Interactive)** — Interview the user relentlessly to resolve all ambiguities, architectural decisions, and domain vocabulary while updating ADRs/glossary as needed.
2. **Stage 2: `/to-spec` (Autonomous)** — Synthesize the completed interview into a complete Spec without asking further questions.
3. **Stage 3: `/to-tickets` (Autonomous)** — Break the Spec into tracer-bullet vertical-slice tickets with blocking edges without pausing to quiz the user.
4. **Stage 4: `/implement-spec` (Autonomous)** — Implement every ticket along the dependency frontier using TDD (`tdd`) and run final `code-review` until the entire feature is complete and verified.

---

## Global Rules

- **Human Interaction Boundary**: **ONLY Stage 1 (`/grill-with-docs`) asks the user questions.** As soon as Stage 1 is complete (all open design branches are resolved or the user says to proceed), execute Stages 2, 3, and 4 **continuously and autonomously in a single uninterrupted flow** without stopping for confirmation between or within stages.
- **No Issue Tracker Fallback (Local `.md` Mode)**: If no external issue tracker (GitHub, GitLab, Linear, etc.) is configured or specified, never stop or ask the user to run `/setup-matt-pocock-skills`. Automatically store the spec and tickets locally under `.scratch/<feature-slug>/`:
  - Spec file: `.scratch/<feature-slug>/spec.md`
  - Ticket files: `.scratch/<feature-slug>/issues/<NN>-<slug>.md`
- **Never Commit Scratch/Ticket `.md` Files**: Never `git add` or `git commit` `.scratch/`, `.scratch/<feature-slug>/spec.md`, or `.scratch/<feature-slug>/issues/*.md` at any point during or after the workflow. Ensure all code commits in Stage 4 exclude `.scratch/`.

---

## Stage-by-Stage Execution

### Stage 1: `/grill-with-docs` (Interactive Interview + Domain Modeling)

Invoke or follow **`grill-with-docs`** (`../../upstream/mattpocock/grill-with-docs/SKILL.md`, combining `grilling` and `domain-modeling`):

1. Explore the codebase first so you never ask the user questions that the repository already answers.
2. Grill the user one focused decision branch at a time to stress-test requirements, edge cases, failure modes, boundaries, and domain terminology.
3. Maintain/update project domain documentation (such as glossary or ADRs) when key terminology or hard-to-reverse architectural decisions crystallize.
4. **Transition Trigger**: Once all decision branches have been resolved (or when the user indicates the answers are sufficient / says "go ahead"), announce:
   > *"Grilling complete. Proceeding autonomously through `/to-spec` -> `/to-tickets` -> `/implement-spec`."*
   Immediately begin Stage 2 in the same turn if no user input is pending.

---

### Stage 2: `/to-spec` (Autonomous Spec Synthesis)

Invoke or follow **`to-spec`** (`../../upstream/mattpocock/to-spec/SKILL.md`) with the following **autonomous overrides**:

- **Override 1 (No Seam Confirmation Prompt)**: Identify the highest, cleanest testing seam(s) based on the codebase and Stage 1 discussion, and record them directly in `## Testing Decisions`. **Do NOT pause to ask the user whether the seams match their expectations.**
- **Override 2 (Tracker / Local Fallback)**:
  - If an external issue tracker is configured, publish the spec there and apply `ready-for-agent`.
  - Otherwise, write the full spec using `<spec-template>` (`Problem Statement`, `Solution`, extensive `User Stories`, `Implementation Decisions`, `Testing Decisions`, `Out of Scope`, `Further Notes`) to `.scratch/<feature-slug>/spec.md` (do **not** stage or commit this file).
- Immediately proceed to Stage 3 without waiting for user input.

---

### Stage 3: `/to-tickets` (Autonomous Vertical-Slice Breakdown)

Invoke or follow **`to-tickets`** (`../to-tickets/SKILL.md`) with the following **autonomous overrides**:

- **Override 1 (Skip Step 4 "Quiz the user")**: Draft the tracer-bullet vertical slices (or expand–contract batches for wide refactors) and self-verify that:
  - Each ticket cuts a narrow, end-to-end verifiable vertical slice through all required layers.
  - Blocking edges (`Blocked by`) only gate on genuine dependencies, with prefactoring tickets first.
  - Print the numbered summary table in chat for visibility, **do NOT ask the user for approval**, and immediately publish/write the tickets.
- **Override 2 (Local `.md` Tickets Default & No-Commit Rule)**:
  - If no external issue tracker is configured, write one file per ticket to `.scratch/<feature-slug>/issues/<NN>-<slug>.md` (numbered `01`, `02`, … in dependency order) using `<local-ticket-template>`.
  - **Never `git add` or `git commit` `.scratch/<feature-slug>/issues/*.md`.**
- Immediately proceed to Stage 4 without waiting for user input.

---

### Stage 4: `/implement-spec` (Autonomous Implementation & Verification)

Invoke or follow **`implement-spec`** (`../../upstream/mattpocock/implement-spec/SKILL.md`) with the following **autonomous overrides**:

1. Read the spec (`.scratch/<feature-slug>/spec.md` or tracker issue) and all tickets (`.scratch/<feature-slug>/issues/<NN>-<slug>.md` or tracker issues) to build the dependency graph and identify the initial **frontier** (tickets with no unresolved blockers).
2. Create or work on the integration branch as appropriate for the repository.
3. Process the ticket frontier until every ticket is complete:
   - Use subagents in isolated worktrees/branches when parallelizing independent frontier tickets, or execute sequentially in the current workspace if only one ticket is on the frontier or worktrees are unavailable.
   - For each ticket, follow the **`tdd`** skill (`../../upstream/mattpocock/tdd/SKILL.md`): write failing tests at the agreed seam, implement minimal code to pass, refactor, run typecheck/lint/tests, and commit **only project source/test/doc files** (strictly excluding `.scratch/`).
   - As each ticket completes, update its status (mark `**Status:** done` and check off `[x]` acceptance criteria in `.scratch/<feature-slug>/issues/<NN>-<slug>.md` without committing `.scratch/`, or close the issue on the external tracker) and unlock newly unblocked tickets on the frontier.
4. Once all tickets are implemented and merged into the integration branch, run the **`code-review`** skill (`../../upstream/mattpocock/code-review/SKILL.md`) across the full diff and automatically fix any issues found.
5. Run the full test suite, typecheck, and linter one final time to confirm everything is green, verify `git status` has no staged/committed `.scratch/` files, and present the final completion report.

