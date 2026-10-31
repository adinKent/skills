# GitLab MR Auto Review & Fix

A portable Agent Skill for OpenCode, Claude Code, Antigravity, and Cursor. It uses the [`zereight/gitlab-mcp`](https://github.com/zereight/gitlab-mcp) (`@zereight/mcp-gitlab`) MCP server to inspect GitLab Merge Requests, fetch discussion threads, reply to review feedback, and resolve verified threads.

## Install

### Recommended: project-local (shared by OpenCode and Claude Code)

Copy this directory into your repository as:

```text
.claude/skills/gitlab-mr-auto-fix/
  SKILL.md
```

OpenCode discovers `.claude/skills/...` as a Claude-compatible skill location, and Claude Code discovers it natively.

Alternatively, install globally:

```bash
mkdir -p ~/.claude/skills
cp -R gitlab-mr-auto-fix ~/.claude/skills/
```

For OpenCode-only global installation, copy it to:

```bash
~/.config/opencode/skills/gitlab-mr-auto-fix/
```

## Prerequisites

- `git`
- [`zereight/gitlab-mcp`](https://github.com/zereight/gitlab-mcp) (`@zereight/mcp-gitlab`) MCP server configured in your coding agent
- Project test/lint/build dependencies

### Configure `zereight/gitlab-mcp`

Example MCP configuration:

```json
{
  "mcpServers": {
    "gitlab": {
      "command": "npx",
      "args": ["-y", "@zereight/mcp-gitlab"],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "<your-gitlab-token>",
        "GITLAB_API_URL": "https://gitlab.com/api/v4"
      }
    }
  }
}
```

The GitLab identity must be allowed to push to the MR source branch and resolve discussions. Do not put access tokens in `SKILL.md`, shell scripts, prompts, or repository files.

## Run

Open the repository at the MR source branch in your agent, then ask:

```text
Use @gitlab-mr-auto-fix to process every review comment on the current GitLab MR.
Fix actionable feedback, run the relevant checks, commit and push to the MR source
branch, reply to fixed threads, resolve only verified threads, and repeat until
complete or blocked. Do not merge the MR.
```

## Important behavior

- Requires a clean worktree before starting to prevent accidental inclusion of unrelated user changes.
- Pushes normally (`git push origin HEAD:refs/heads/<source_branch>`); never force-pushes.
- Resolves only after a verified fix has been pushed.
- Does not merge or approve the MR.
- Stops on ambiguous product/security/API decisions, concurrent branch changes, failed checks, or safety limits.
- General non-resolvable comments can be replied to but cannot truthfully be marked resolved.
- Default workflow limits are 5 fix/push iterations and 20 threads per invocation; adjust in `SKILL.md` deliberately if your review process needs different limits.

## `zereight/gitlab-mcp` tools used

- `get_merge_request` / `list_merge_requests`: Retrieve MR metadata (`iid`, `state`, `draft`, `source_branch`, `target_branch`, `sha`, `diff_refs`, `web_url`, `description`).
- `get_merge_request_diffs` / `list_merge_request_diffs`: Inspect MR diffs and changed files.
- `mr_discussions`: Fetch all MR discussion pages (`project_id`, `merge_request_iid`, `page`, `per_page`).
- `create_merge_request_discussion_note`: Reply in an existing discussion thread (`project_id`, `merge_request_iid`, `discussion_id`, `body`).
- `create_merge_request_note`: Add a top-level MR comment when replying to non-threaded feedback.
- `resolve_merge_request_thread`: Resolve a discussion thread (`project_id`, `merge_request_iid`, `discussion_id`, `resolved: true`).
