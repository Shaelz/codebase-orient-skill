#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/install-package.sh" codebase-orient "$SCRIPT_DIR/../skills/codebase-orient" "$HOME/.agents/skills/codebase-orient" "$@"
echo "Select codebase-orient in Codex; restart Codex if it is not detected."
