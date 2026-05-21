#!/usr/bin/env bash
# check-ascii-punctuation.sh - scan tracked repo-maintenance text for forbidden smart punctuation
#
# Checks files tracked by git for em dashes, en dashes, curly quotes,
# ellipsis, non-breaking spaces, and Unicode math symbols.
#
# Run before release or broad text changes to catch regressions.
# Requires: git, perl (standard on macOS and Linux)
#
# Usage:
#   ./scripts/check-ascii-punctuation.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

EXTS_PATTERN='\.(md|txt|ps1|sh|yml|yaml|json|toml|ini)$'

# Forbidden Unicode code points:
#   U+2014 em dash, U+2013 en dash
#   U+201C/D curly double quotes, U+2018/9 curly single quotes
#   U+2026 ellipsis, U+00A0 non-breaking space
#   U+2264 <=, U+2265 >=
FORBIDDEN_PATTERN='[\x{2014}\x{2013}\x{201C}\x{201D}\x{2018}\x{2019}\x{2026}\x{00A0}\x{2264}\x{2265}]'

FOUND=0

while IFS= read -r file; do
    if echo "$file" | grep -qE "$EXTS_PATTERN"; then
        if [ ! -f "$file" ]; then continue; fi
        if perl -CSD -ne "exit 1 if /$FORBIDDEN_PATTERN/" "$file" 2>/dev/null; then
            : # clean
        else
            perl -CSD -ne "
                chomp;
                if (/$FORBIDDEN_PATTERN/) {
                    print \"FAIL  $file:\$. [\$&]  \$_\n\";
                }
            " "$file"
            FOUND=1
        fi
    fi
done < <(git ls-files)

echo ""
if [ "$FOUND" -eq 0 ]; then
    echo "check-ascii-punctuation: all tracked text files are clean."
    exit 0
else
    echo "check-ascii-punctuation: forbidden smart punctuation found. See above." >&2
    exit 1
fi
