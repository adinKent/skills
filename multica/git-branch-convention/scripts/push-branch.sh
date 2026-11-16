
#!/usr/bin/env bash
set -euo pipefail

REMOTE="${1:-origin}"
BRANCH="${2:?Usage: push-branch.sh <remote> <branch>}"

# Validate branch name
git check-ref-format --branch "$BRANCH" >/dev/null

# Resolve current HEAD
SHA="$(git rev-parse HEAD)"

# Check whether remote branch exists
REMOTE_SHA="$(
  git ls-remote --heads "$REMOTE" "refs/heads/$BRANCH" |
  awk '{print $1}'
)"

if [[ -n "$REMOTE_SHA" ]]; then
  # Do not overwrite an existing remote branch.
  if ! git merge-base --is-ancestor "$REMOTE_SHA" "$SHA"; then
    echo "ERROR: Remote branch diverged."
    echo "Remote: $REMOTE_SHA"
    echo "Local:  $SHA"
    exit 1
  fi
fi

# Push current HEAD without switching local branches.
git push "$REMOTE" \
  "HEAD:refs/heads/$BRANCH"

echo "Successfully pushed:"
echo "$SHA -> $REMOTE/$BRANCH"
