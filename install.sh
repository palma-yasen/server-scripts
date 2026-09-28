#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/scripts"
TARGET_DIR="/usr/local/bin/server-scripts"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: install.sh must be run as root."
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Scripts directory not found:"
    echo "  $SOURCE_DIR"
    exit 1
fi

echo "Installing server scripts..."

mkdir -p "$TARGET_DIR"

for script in "$SOURCE_DIR"/*.sh; do
    [ -f "$script" ] || continue

    filename="$(basename "$script")"

    if [ "$filename" = "cg.sh" ]; then
        target_name="cg"
    else
        target_name="$filename"
    fi

    cp "$script" "$TARGET_DIR/$target_name"
    chmod 755 "$TARGET_DIR/$target_name"

    echo "  Installed: $target_name"
done

echo
echo "Installation completed."
echo "Scripts installed to:"
echo "  $TARGET_DIR"
