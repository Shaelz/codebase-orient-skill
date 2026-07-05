#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/install-package.sh" install-codebase-orient "$SCRIPT_DIR/../skills/install-codebase-orient" "$HOME/.claude/skills/install-codebase-orient" "$@"
echo "Invoke the bootstrap with /install-codebase-orient. Restart Claude Code if needed."
