#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
export COREVIA_TALK_TEST_PLATFORM=Darwin
mkdir -p "$HOME/Library/Application Support/xyz.block.coreviatalk.app.dev.example"
mkdir -p "$HOME/Library/Application Support/xyz.block.coreviatalk.app.dev.other"
mkdir -p "$HOME/Library/Application Support/xyz.block.coreviatalk.app"
mkdir -p "$HOME/.corevia-talk-dev"
touch "$HOME/.corevia-talk-dev/keep"
mkdir -p "$tmp/bin"
cat > "$tmp/bin/security" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$HOME/security-calls"
exit 1
MOCK
chmod +x "$tmp/bin/security"
export PATH="$tmp/bin:$PATH"

"$repo_root/scripts/reset-desktop-standalone-state.sh" \
    xyz.block.coreviatalk.app.dev.example corevia-talk-desktop-dev.example

[[ ! -e "$HOME/Library/Application Support/xyz.block.coreviatalk.app.dev.example" ]]
[[ -d "$HOME/Library/Application Support/xyz.block.coreviatalk.app.dev.other" ]]
[[ -d "$HOME/Library/Application Support/xyz.block.coreviatalk.app" ]]
[[ -f "$HOME/.corevia-talk-dev/keep" ]]
grep -Fx -- "delete-generic-password -s corevia-talk-desktop-dev.example" "$HOME/security-calls" >/dev/null

if "$repo_root/scripts/reset-desktop-standalone-state.sh" \
    xyz.block.coreviatalk.app corevia-talk-desktop >/dev/null 2>&1; then
    echo "expected production scope guard to reject reset" >&2
    exit 1
fi

echo "standalone desktop reset scope test passed"
