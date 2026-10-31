# GitLab MR Auto Resolve Loop

A companion Agent Skill to [`gitlab-mr-auto-fix`](../gitlab-mr-auto-fix/SKILL.md) that automatically resolves all GitLab Merge Request review threads **except** those requiring human direction, and polls every **10 minutes** (up to **6 rounds**) until no new threads need resolution.

## Behavior

1. **Delegates core workflow to `gitlab-mr-auto-fix`** (clean worktree checks, test/lint verification, safe git commit & push, and `zereight/gitlab-mcp` tool usage).
2. **Resolution Policy Override**:
   - **Resolves (`resolved: true`)**:
     - `ACTIONABLE` (after implementing fix, passing checks, pushing commit, and replying with SHA)
     - `ALREADY_FIXED` (after replying with evidence)
     - `OBSOLETE` (after replying why the code/comment is obsolete)
     - `DISAGREE` (after replying with the technical explanation)
   - **Leaves Unresolved (`HUMAN_DIRECTION_REQUIRED`)**:
     - Any request that is **ambiguous, conflicts with product behavior, requires a design decision, changes public API/schema, or has security/data-loss implications**. The agent replies with a clarification question and leaves the thread open for human decision.
3. **10-Minute Polling Loop (Max 6 Rounds)**:
   - After finishing a round of resolution, waits **10 minutes** (`600` seconds) and checks `mr_discussions` again.
   - Stops immediately when a check finds **no new threads needing resolution** (ignoring already-deferred `HUMAN_DIRECTION_REQUIRED` threads that have no new reviewer replies), or after **6 rounds** maximum.

