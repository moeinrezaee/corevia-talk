#!/usr/bin/env bash
# Pull the latest block/buzz `main` into this fork without losing local changes.
#
#   scripts/sync-upstream.sh            # fetch, rebrand, merge into the current branch
#   scripts/sync-upstream.sh --no-merge # only refresh the `upstream-branded` branch
#
# How it works
#   `upstream-branded` is a pure mirror of upstream, passed through
#   scripts/rebrand.py (Buzz -> Corevia Talk). It never contains local edits.
#   Each run appends one commit to it, then merges it into the current branch
#   (normally `main`). Git's 3-way merge uses the previous `upstream-branded`
#   commit as the base, so only what upstream changed since the last sync is
#   applied and local work stays. Conflicts appear only where upstream and
#   local edits touch the same lines.
#
# Local work is done directly on `main`, using the Corevia Talk names.
set -euo pipefail

UP_URL="${UPSTREAM_URL:-https://github.com/block/buzz.git}"
UP_REF="${UPSTREAM_REF:-main}"
BR="upstream-branded"
MERGE=1
[ "${1:-}" = "--no-merge" ] && MERGE=0

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if [ "$MERGE" = 1 ] && [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean; commit or stash first." >&2
  exit 1
fi

echo "==> Fetching $UP_URL $UP_REF"
git fetch --depth=1 "$UP_URL" "$UP_REF"
TIP="$(git rev-parse FETCH_HEAD)"

LAST=""
if git rev-parse -q --verify "refs/heads/$BR" >/dev/null; then
  LAST="$(git log -1 --format=%B "$BR" | sed -n 's/^Upstream-SHA: //p')"
fi
if [ "$LAST" = "$TIP" ]; then
  echo "Already up to date with upstream ($TIP)."
  exit 0
fi

WT="$(mktemp -d)"
cleanup() { git worktree remove --force "$WT" 2>/dev/null || true; rm -rf "$WT"; }
trap cleanup EXIT

echo "==> Rebranding upstream $TIP"
git worktree add --detach "$WT" "$TIP" >/dev/null
(cd "$WT" && python3 "$ROOT/scripts/rebrand.py" >/dev/null && git add -A)
TREE="$(cd "$WT" && git write-tree)"

PARENT=()
BOOTSTRAP=0
if [ -n "$LAST" ]; then PARENT=(-p "$BR"); else BOOTSTRAP=1; fi
COMMIT="$(git commit-tree "$TREE" ${PARENT[@]+"${PARENT[@]}"} -F - <<EOF
chore(upstream): rebranded mirror of block/buzz $UP_REF

Upstream-SHA: $TIP
EOF
)"
git update-ref "refs/heads/$BR" "$COMMIT"
echo "==> $BR -> $(git rev-parse --short "$COMMIT")"

[ "$MERGE" = 1 ] || exit 0

if [ "$BOOTSTRAP" = 1 ]; then
  # First run: the current branch already contains this upstream state.
  git merge -s ours --no-edit -m "chore: record upstream baseline $TIP" "$BR"
  echo "Baseline recorded. Future runs will merge upstream changes."
else
  echo "==> Merging $BR into $(git branch --show-current)"
  if ! git merge --no-edit -m "Merge upstream block/buzz $UP_REF ($TIP) into Corevia Talk" "$BR"; then
    echo >&2
    echo "Conflicts: resolve them, run 'git commit', then push. Local edits win" >&2
    echo "where they overlap; take upstream's side only if you want its change." >&2
    exit 1
  fi
fi
