#!/usr/bin/env bash
set -euo pipefail

PACKAGE="${1:?package is required}"
SOURCE_DIR="${2:?source directory is required}"
DEST_DIR="${3:?destination directory is required}"
shift 3

FORCE=false
CLEAN=false
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        --clean) CLEAN=true ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

if [ "$FORCE" = true ] && [ "$CLEAN" = true ]; then
    echo "Error: select overlay reinstall (--force) or clean reinstall (--clean), not both." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY="$SCRIPT_DIR/package-inventory.tsv"

digest_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        tr -d '\r' < "$1" | sha256sum | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        tr -d '\r' < "$1" | shasum -a 256 | awk '{print $1}'
    else
        echo "Error: sha256sum or shasum is required." >&2
        return 1
    fi
}

inventory_rows() {
    awk -F '\t' -v package="$PACKAGE" '$0 !~ /^#/ && $1 == package { print $2 "\t" $3 "\t" $4 }' "$INVENTORY"
}

validate_package() {
    local root="$1" label="$2" count=0 path expected policy actual
    while IFS=$'\t' read -r path expected policy; do
        [ -n "$path" ] || continue
        count=$((count + 1))
        if [ "$policy" != "lf" ]; then
            echo "Error: unsupported newline policy: $policy" >&2; return 1
        fi
        if [ ! -f "$root/$path" ]; then
            echo "Error: $label package is missing managed file: $path" >&2; return 1
        fi
        actual="$(digest_file "$root/$path")"
        if [ "$actual" != "$expected" ]; then
            echo "Error: $label package content mismatch: $path" >&2; return 1
        fi
    done < <(inventory_rows)
    if [ "$count" -eq 0 ]; then
        echo "Error: no inventory entry found for package: $PACKAGE" >&2; return 1
    fi
}

copy_managed() {
    local from="$1" to="$2" path expected policy
    while IFS=$'\t' read -r path expected policy; do
        [ -n "$path" ] || continue
        if [ -d "$to/$path" ]; then
            echo "Error: managed path is a directory but must be a file: $path" >&2; return 1
        fi
        mkdir -p "$(dirname "$to/$path")"
        cp -f "$from/$path" "$to/$path"
    done < <(inventory_rows)
}

report_extras() {
    local root="$1" relative path expected policy managed
    while IFS= read -r -d '' file; do
        relative="${file#"$root"/}"
        managed=false
        while IFS=$'\t' read -r path expected policy; do
            [ "$relative" = "$path" ] && managed=true && break
        done < <(inventory_rows)
        [ "$managed" = true ] || printf '  %s\n' "$relative"
    done < <(find "$root" -type f -print0)
}

echo "Source : $SOURCE_DIR"
echo "Dest   : $DEST_DIR"

# Source validation is deliberately before any destination mutation.
validate_package "$SOURCE_DIR" "Source"

if [ -e "$DEST_DIR" ] && [ "$FORCE" = false ] && [ "$CLEAN" = false ]; then
    echo "Error: destination already exists: $DEST_DIR" >&2
    echo "Select --force for overlay reinstall or --clean for clean reinstall." >&2
    exit 1
fi

if [ "$FORCE" = true ]; then
    [ -d "$DEST_DIR" ] || { echo "Error: overlay reinstall destination must be a directory: $DEST_DIR" >&2; exit 1; }
    copy_managed "$SOURCE_DIR" "$DEST_DIR"
    validate_package "$DEST_DIR" "Installed"
    echo "Overlay reinstall complete."
    extras="$(report_extras "$DEST_DIR")"
    if [ -n "$extras" ]; then
        echo "Extra destination files were preserved:"
        printf '%s\n' "$extras"
    fi
    exit 0
fi

parent="$(dirname "$DEST_DIR")"
leaf="$(basename "$DEST_DIR")"
mkdir -p "$parent"
stage="$(mktemp -d "$parent/.${leaf}.stage.XXXXXX")"
backup="$parent/.${leaf}.backup.$$"
moved_existing=false
cleanup() { [ -d "$stage" ] && rm -rf "$stage"; }
trap cleanup EXIT

copy_managed "$SOURCE_DIR" "$stage"
validate_package "$stage" "Staged"

if [ -e "$DEST_DIR" ]; then
    mv "$DEST_DIR" "$backup"
    moved_existing=true
fi

if ! mv "$stage" "$DEST_DIR" || ! validate_package "$DEST_DIR" "Installed"; then
    [ -e "$DEST_DIR" ] && rm -rf "$DEST_DIR"
    if [ "$moved_existing" = true ] && [ -e "$backup" ]; then mv "$backup" "$DEST_DIR"; fi
    echo "Error: installation replacement or final validation failed." >&2
    exit 1
fi

[ "$moved_existing" = true ] && rm -rf "$backup"
if [ "$CLEAN" = true ]; then echo "Clean reinstall complete."; else echo "Installation complete."; fi
