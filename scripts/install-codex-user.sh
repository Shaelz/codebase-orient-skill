#!/usr/bin/env bash
# install-codex-user.sh - installs codebase-orient skill to the user-level Codex skills directory
#
# Usage:
#   ./scripts/install-codex-user.sh
#   ./scripts/install-codex-user.sh --force

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../skills/codebase-orient" && pwd)"
DEST_DIR="$HOME/.agents/skills/codebase-orient"

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
echo "Next step:"
echo "  1. Open any project in Codex."
echo "  2. Codex should detect the installed skill automatically."
echo "  3. If codebase-orient does not appear, restart Codex."
echo "  4. In Codex CLI/IDE, run /skills or type \$ to mention/select"
echo "     codebase-orient, then ask it to orient the repo."
