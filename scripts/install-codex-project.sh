#!/usr/bin/env bash
# install-codex-project.sh - installs codebase-orient skill into the current project's .agents/skills directory
#
# Run this from the root of the project where you want to install the skill.
#
# Usage:
#   ./path/to/install-codex-project.sh
#   ./path/to/install-codex-project.sh --force

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../skills/codebase-orient" && pwd)"
DEST_DIR="$(pwd)/.agents/skills/codebase-orient"

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
echo "Optional: to track only the skill file in git (not other .agents internals),"
echo "add the following to your project .gitignore:"
echo ""
echo "  # Ignore all .agents internals except the skill"
echo "  .agents/"
echo "  !.agents/skills/"
echo "  !.agents/skills/codebase-orient/"
echo "  !.agents/skills/codebase-orient/SKILL.md"
echo ""
echo "Verification:"
echo "  1. Restart or reload Codex if it is currently running - Codex may not"
echo "     pick up new skills until the session is refreshed."
echo "  2. Open this project in Codex and invoke the skill explicitly:"
echo "       Use codebase-orient to orient yourself to this repo."
echo "  3. The skill should activate and begin orienting Codex to the codebase."
