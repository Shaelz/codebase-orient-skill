#!/usr/bin/env bash
# install-bootstrap-user.sh -- installs install-codebase-orient bootstrap skill to the user-level Claude Code skills directory
#
# This is the bootstrap skill (install-codebase-orient), not the orientation skill (codebase-orient).
# The bootstrap skill runs a first-pass orientation and generates .claude/skills/codebase-orient/
# inside a project. To install the orientation skill itself, use install-user.sh instead.
#
# Usage:
#   ./scripts/install-bootstrap-user.sh
#   ./scripts/install-bootstrap-user.sh --force

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../skills/install-codebase-orient" && pwd)"
DEST_DIR="$HOME/.claude/skills/install-codebase-orient"

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
echo "Verification:"
echo "  1. Restart Claude Code if it is currently running."
echo "  2. Open any project and type: /install-codebase-orient"
echo "  3. The skill will orient Claude and generate docs/ai/ and"
echo "     .claude/skills/codebase-orient/SKILL.md inside the project."
