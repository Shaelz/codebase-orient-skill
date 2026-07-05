#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/install-package.sh" codebase-orient "$SCRIPT_DIR/../skills/codebase-orient" "$HOME/.claude/skills/codebase-orient" "$@"
echo "Invoke with /codebase-orient. Restart Claude Code if needed."
