#!/usr/bin/env bash
# install-project.sh - installs codebase-orient skill into the current project's .claude/skills directory
#
# Run this from the root of the project where you want to install the skill.
#
# Usage:
#   ./path/to/install-project.sh
#   ./path/to/install-project.sh --force

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../skills/codebase-orient" && pwd)"
DEST_DIR="$(pwd)/.claude/skills/codebase-orient"

FORCE=false
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

echo "Source : $SOURCE_DIR"
echo "Dest   : $DEST_DIR"

if [ -d "$DEST_DIR" ]; then
    if [ "$FORCE" = false ]; then
        echo "Error: destination already exists: $DEST_DIR" >&2
        echo "Re-run with --force to overwrite." >&2
        exit 1
    fi
    echo "[--force] Overwriting existing installation."
fi

mkdir -p "$DEST_DIR"

cp -rf "$SOURCE_DIR/." "$DEST_DIR/"
echo "  Copied skill contents."

echo ""
echo "Installation complete."
echo ""
echo "Optional: to track only the skill file in git (not other .claude internals),"
echo "add the following to your project .gitignore:"
echo ""
echo "  # Ignore all .claude internals except the skill"
echo "  .claude/"
echo "  !.claude/skills/"
echo "  !.claude/skills/codebase-orient/"
echo "  !.claude/skills/codebase-orient/SKILL.md"
echo ""
echo "Note: this script does not touch .claude/settings.local.json."
echo ""
echo "Verification:"
echo "  1. Restart Claude Code if it is currently running."
echo "  2. Open this project in Claude Code and type: /codebase-orient"
echo "  3. The skill should activate and begin orienting Claude to the codebase."
