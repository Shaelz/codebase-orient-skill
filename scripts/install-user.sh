#!/usr/bin/env bash
# install-user.sh — installs codebase-orient skill to the user-level Claude Code skills directory
#
# Usage:
#   ./scripts/install-user.sh
#   ./scripts/install-user.sh --force

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../skills/codebase-orient" && pwd)"
DEST_DIR="$HOME/.claude/skills/codebase-orient"

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

for f in "$SOURCE_DIR"/*; do
    [ -f "$f" ] || continue
    cp "$f" "$DEST_DIR/$(basename "$f")"
    echo "  Copied: $(basename "$f")"
done

echo ""
echo "Installation complete."
echo ""
echo "Verification:"
echo "  1. Restart Claude Code if it is currently running."
echo "  2. Open any project and type: /codebase-orient"
echo "  3. The skill should activate and begin orienting Claude to the codebase."
