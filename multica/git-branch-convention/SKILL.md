
---
name: git-branch-convention
description: Enforce conventional Git branch naming and GitLab remote delivery for all coding tasks. Use when starting, committing, or delivering issue-based work in Multica.
---

# Git Branch Convention

## Objective

Enforce consistent Git branch naming across all coding agents.

Do not change or rename a Multica-managed local worktree branch.

Generate a conventional remote branch and push the
completed work to that branch.

## 1. Branch Naming

Format:

`<type>/<jira-key>-<slug>`

Without Jira:

`<type>/<slug>`

Examples:

- feat/new-message-format
- feat/TWTC-18600-new-message-format
- fix/TWTC-18601-login-timeout
- refactor/reduce-rendering
- perf/improve-list-rendering
- docs/update-api-guide
- chore/update-dependencies

## 2. Branch Types

| Type | Usage |
|---|---|
| feat | New features |
| fix | Bug fixes |
| refactor | Code refactoring |
| perf | Performance improvements |
| docs | Documentation |
| test | Tests |
| chore | Maintenance |
| hotfix | Urgent fixes |

If the issue type is unclear, use feat.

## 3. Jira Detection

Determine Jira key in this order:

1. Issue identifier from Multica
2. Issue title
3. Issue description

Jira format:

`[A-Z][A-Z0-9]+-[0-9]+`

Examples:

- TWTC-18600
- PROJ-123
- APP2-456

Never use Multica internal IDs as Jira keys.

## 4. Slug Generation

Use the issue description as the primary source.

Rules:

1. Understand the actual task.
2. Generate a concise English summary.
3. Use lowercase.
4. Use kebab-case.
5. Remove unnecessary words and punctuation.
6. Keep the slug descriptive.
7. Prefer 3-8 words.

Fallback:
- Issue title
- Issue identifier
- Short task description

## 5. Worktree Safety

Multica manages its own local worktree branch.

NEVER:
- Rename the Multica-managed branch.
- Checkout another local branch.
- Create another local branch in the managed worktree.
- Modify Multica ownership refs.
- Force push.

The conventional branch is a remote delivery
reference, not a replacement for the local branch.

## 6. Commit and Push

Before delivery:

1. Inspect git status.
2. Review all changes.
3. Run relevant tests.
4. Commit all intended changes.
5. Generate the conventional branch name.
6. Push the current HEAD to the remote branch.

Example:

`git push origin HEAD:refs/heads/feat/TWTC-18600-new-message-format`

Do not push to a different remote without approval.

## 7. Existing Remote Branch

Before pushing:

- Check whether the remote branch exists.
- If it does not exist, create it.
- If it exists and points to the expected history,
  push normally.
- If it has diverged, STOP and report the conflict.
- Never force push or overwrite another person's work.

## 8. Delivery Report

Always report:

- Local Multica branch
- Remote branch
- Jira key (if available)
- Commit SHA
- Push result
- Test result

Do not claim successful delivery unless Git confirms
that the remote branch contains the intended commit.
