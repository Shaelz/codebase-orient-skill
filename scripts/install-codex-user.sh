#!/usr/bin/env bash
# install-codex-user.sh — installs codebase-orient skill to the user-level Codex skills directory
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
echo "Verification:"
echo "  1. Restart or reload Codex if it is currently running — Codex may not"
echo "     pick up new skills until the session is refreshed."
echo "  2. Open any project and invoke the skill explicitly:"
echo "       Use codebase-orient to orient yourself to this repo."
echo "  3. The skill should activate and begin orienting Codex to the codebase."
