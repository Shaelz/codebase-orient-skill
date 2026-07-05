#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$SCRIPT_DIR/install-package.sh"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_ROOT="$(mktemp -d)"

cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

assert_throws() {
    local message="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "$message" >&2
        exit 1
    fi
}

for package in codebase-orient install-codebase-orient; do
    source_dir="$REPO_ROOT/skills/$package"
    dest="$TEST_ROOT/$package-dest"

    bash "$HELPER" "$package" "$source_dir" "$dest" >/dev/null
    assert_throws "Normal install did not refuse existing $package destination." \
        bash "$HELPER" "$package" "$source_dir" "$dest"

    printf 'preserve' > "$dest/extra.txt"
    bash "$HELPER" "$package" "$source_dir" "$dest" --force >/dev/null
    if [ ! -f "$dest/extra.txt" ]; then
        echo "Overlay reinstall deleted an extra $package file." >&2
        exit 1
    fi

    bash "$HELPER" "$package" "$source_dir" "$dest" --clean >/dev/null
    if [ -f "$dest/extra.txt" ]; then
        echo "Clean reinstall retained an extra $package file." >&2
        exit 1
    fi

    assert_throws 'Conflicting flags were accepted.' \
        bash "$HELPER" "$package" "$source_dir" "$dest" --force --clean

    rm -f "$dest/SKILL.md"
    mkdir -p "$dest/SKILL.md"
    assert_throws 'Overlay managed type conflict was accepted.' \
        bash "$HELPER" "$package" "$source_dir" "$dest" --force

    rm -rf "$dest"
    mkdir -p "$dest"
    printf 'keep' > "$dest/sentinel.txt"
    bad_source="$TEST_ROOT/$package-bad-source"
    cp -r "$source_dir" "$bad_source"
    printf '\ncorrupt\n' >> "$bad_source/SKILL.md"
    assert_throws 'Malformed source package was accepted.' \
        bash "$HELPER" "$package" "$bad_source" "$dest" --clean
    if [ ! -f "$dest/sentinel.txt" ]; then
        echo "Source validation failure mutated the destination." >&2
        exit 1
    fi
done

echo "Installer tests passed."
