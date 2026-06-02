#!/usr/bin/env bash
#
# install.sh — load the TradingFlow workflow into your local Claude Code.
#
# Claude Code auto-discovers workflows dropped into:
#   ~/.claude/workflows/      (user scope — available in every project)   [default]
#   ./.claude/workflows/      (project scope — shared with everyone who clones the repo)
# The installed file becomes the /tradingflow slash command.
#
# Usage:
#   ./install.sh [--project|--user]
#
#   ./install.sh                 # install into ~/.claude/workflows/ (user scope)
#   ./install.sh --project       # install into ./.claude/workflows/ instead
#
# No clone needed (remote install):
#   curl -fsSL https://raw.githubusercontent.com/lxcong/TradingFlow/main/install.sh | bash
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/lxcong/TradingFlow/main"
SRC_FILE="tradingflow.workflow.js"
DEST="$HOME/.claude/workflows"

for arg in "$@"; do
  case "$arg" in
    --project) DEST="$PWD/.claude/workflows" ;;
    --user)    DEST="$HOME/.claude/workflows" ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *)         echo "Unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# Running from a clone (the workflow file sits next to this script)?
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
mkdir -p "$DEST"
dest_file="$DEST/tradingflow.js"

if [ -n "$SELF_DIR" ] && [ -f "$SELF_DIR/$SRC_FILE" ]; then
  cp "$SELF_DIR/$SRC_FILE" "$dest_file"
elif curl -fsSL "$REPO_RAW/$SRC_FILE" -o "$dest_file"; then
  :
else
  echo "✗ Could not find $SRC_FILE (locally or at $REPO_RAW/$SRC_FILE)" >&2
  rm -f "$dest_file"
  exit 1
fi

echo "✓ Installed /tradingflow  →  $dest_file"

cat <<EOF

Done. In Claude Code (v2.1.154+, Dynamic workflows enabled in /config):
  • run it:    /tradingflow NVDA as of 2026-05-28
  • or browse: /workflows
First run asks you to approve the plan; pick "don't ask again" to skip it next time.
EOF
