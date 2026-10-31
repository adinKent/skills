---
name: gitlab-mr-auto-resolve-loop
description: Orchestrates gitlab-mr-auto-fix in a 10-minute polling loop (up to 6 rounds). Automatically fixes/replies and resolves all MR discussion threads except those requiring human direction (ambiguous requirements, product conflicts, design decisions, public API/schema changes, or security/data-loss implications), stopping once a post-wait check finds no new threads to resolve.
compatibility: OpenCode, Claude Code, Antigravity, Cursor
metadata:
  platform: gitlab
  mcp: zereight/gitlab-mcp
  depends_on: gitlab-mr-auto-fix
  workflow: autonomous-mr-resolve-loop
---

# GitLab MR Auto Resolve Loop

You are orchestrating an autonomous GitLab Merge Request (MR) resolution loop built on top of the **`gitlab-mr-auto-fix`** skill (`../gitlab-mr-auto-fix/SKILL.md`) using `zereight/gitlab-mcp` (`@zereight/mcp-gitlab`) and local `git`.

Before starting, read and follow all safety, worktree, verification, and git rules defined in `gitlab-mr-auto-fix` (`SKILL.md`), with the specific **Resolution Policy Override** and **10-Minute Polling Loop (Max 6 Rounds)** rules below.

---

## 1. Resolution Policy Override

Unlike the base `gitlab-mr-auto-fix` skill (which leaves `DISAGREE` or `OBSOLETE` threads open), this skill **automatically resolves all resolvable review threads EXCEPT items requiring human direction**:

### The Single Exception (`HUMAN_DIRECTION_REQUIRED`)
> **If a request is ambiguous, conflicts with product behavior, requires a design decision, changes public API/schema, or has security/data-loss implications, stop that item and ask for human direction rather than guessing.**

### How to Handle Each Thread Classification

| Classification | Action | Resolve Thread (`resolve_merge_request_thread`)? |
| :--- | :--- | :--- |
| **`ACTIONABLE`** | Implement fix, run checks, commit & push, reply with commit SHA and summary (`create_merge_request_discussion_note`). | **YES** (`resolved: true`), after push is verified. |
| **`ALREADY_FIXED`** | Verify in code/tests and reply with concrete evidence (file/line/test/commit). | **YES** (`resolved: true`), after posting the reply. |
| **`OBSOLETE`** | Verify the target code was removed/superseded and reply with a concise explanation. | **YES** (`resolved: true`), after posting the reply. |
| **`DISAGREE`** | Verify technical correctness (no product/API/security ambiguity), reply with a clear, respectful technical explanation of why the current code is intentional/correct. | **YES** (`resolved: true`), after posting the reply. |
| **`HUMAN_DIRECTION_REQUIRED`** (`NEEDS_CONTEXT`) | Request is ambiguous, conflicts with product behavior, requires a design decision, changes public API/schema, or has security/data-loss implications. Post a concise reply outlining the question/options for the human reviewer (if not already asked for the latest reviewer note). | **NO — NEVER resolve.** Leave unresolved for human direction. |

- Non-resolvable general MR notes (`resolvable: false`) still receive a reply when appropriate, and are tracked as acknowledged so they are not re-answered on subsequent rounds.

---

## 2. Polling & Execution Loop (10-Minute Interval, Max 6 Rounds)

Track state across rounds:
- `round`: starts at `1`, maximum `6`.
- `deferred_human_threads`: map of `discussion_id -> last_seen_note_id` for threads left open under `HUMAN_DIRECTION_REQUIRED`.

### Step-by-Step Loop

#### Step A — Inspect & Identify Pending Threads (Round `1..6`)
1. Run `get_merge_request` and fetch **all pages** of `mr_discussions` (`per_page: 100`) via `zereight/gitlab-mcp`.
2. Verify the MR is still `opened` and the local branch matches `source_branch`.
3. Filter unresolved, resolvable threads (`resolvable: true` and `resolved: false`):
   - A thread is **pending work** in this round if:
     - It has not been processed yet, **OR**
     - It was previously in `deferred_human_threads`, **AND** a human/reviewer has posted a new note since `last_seen_note_id`.
   - A thread in `deferred_human_threads` with **no new reviewer replies** since our question is considered **waiting on human direction** (do not spam duplicate replies, and do not count it as actionable work for this round).

#### Step B — Check Stopping Condition (On Round ≥ 2, or if Round 1 starts with nothing to resolve)
- If there are **zero pending threads to resolve** (i.e., all resolvable threads are either `resolved: true` or sitting in `deferred_human_threads` awaiting human response with no new replies):
  - **Stop the loop immediately** and output the final report.

#### Step C — Execute `gitlab-mr-auto-fix` with the Resolution Policy Override
1. Classify all pending threads for the current round.
2. For all `ACTIONABLE` threads:
   - Implement fixes, run tests/lint/typecheck/build, commit, and push to `origin HEAD:refs/heads/<source_branch>`.
   - Reply with the commit SHA and resolve each verified thread (`resolve_merge_request_thread` with `resolved: true`).
3. For `ALREADY_FIXED`, `OBSOLETE`, and `DISAGREE` threads:
   - Reply with the technical explanation/evidence (`create_merge_request_discussion_note`) and resolve the thread (`resolve_merge_request_thread` with `resolved: true`).
4. For `HUMAN_DIRECTION_REQUIRED` threads:
   - Reply with the specific clarification question (if not already posted for the latest note), record `discussion_id -> latest_note_id` in `deferred_human_threads`, and **leave unresolved**.

#### Step D — Check Round Limit & Wait 10 Minutes
1. If `round == 6`:
   - Maximum of 6 rounds reached. Do **not** wait another 10 minutes. Proceed to a final `mr_discussions` snapshot and output the final report.
2. If `round < 6`:
   - Announce that Round `round` is complete and that you are waiting **10 minutes (600 seconds)** before checking for new MR review comments (Round `round + 1` of `6`).
   - Wait 10 minutes:
     - **In agents with a native timer/scheduler tool** (e.g., Antigravity `schedule` with `DurationSeconds: 600`): schedule a 600-second one-shot timer to resume the next round.
     - **In shell/CLI environments without a native timer tool**: execute `sleep 600`.
   - Increment `round = round + 1` and return to **Step A**.

---

## 3. Final Report Format

When the loop finishes (either because a post-10-minute check found no new threads to resolve, or after Round 6 completes), report:

- **MR Summary**: MR URL, IID, `source_branch`, final HEAD commit SHA.
- **Rounds Executed**: `<N> / 6` (and why the loop exited: e.g., `No new threads after 10-minute check` or `Reached max 6 rounds`).
- **Resolved Threads**: List of `discussion_id`s resolved across all rounds, grouped by category (`ACTIONABLE`, `ALREADY_FIXED`, `OBSOLETE`, `DISAGREE`) with one-line summaries and commit SHAs where applicable.
- **Threads Left Unresolved for Human Direction (`HUMAN_DIRECTION_REQUIRED`)**: List each `discussion_id`, the reviewer's request, why it requires human direction (ambiguous / product behavior conflict / design decision / public API or schema change / security or data-loss risk), and the question posted.
- **Verification Status**: Tests, lint, typecheck, and build checks executed.
- **Final Status**:
  - `COMPLETE` — zero unresolved threads remain.
  - `WAITING_FOR_HUMAN` — all other threads are resolved; only `HUMAN_DIRECTION_REQUIRED` threads remain open awaiting human input.
  - `MAX_ROUNDS_REACHED` — 6 rounds completed, with new threads still arriving at the end of Round 6.
  - `BLOCKED` — stopped early due to failed tests/checks, dirty worktree, or concurrent branch modification.

