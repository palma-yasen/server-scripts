#!/usr/bin/env bash

set -e

BASE_URL="https://raw.githubusercontent.com/palma-yasen/server-scripts/main/scripts"
TARGET_DIR="/usr/local/bin/server-scripts"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: install.sh must be run as root."
    exit 1
fi

echo "Installing server scripts..."

mkdir -p "$TARGET_DIR"

echo "  Downloading cg..."
curl -fsSL "$BASE_URL/cg.sh" -o "$TARGET_DIR/cg"
chmod 755 "$TARGET_DIR/cg"

echo "  Downloading s3-backup-rotate.sh..."
curl -fsSL "$BASE_URL/s3-backup-rotate.sh" -o "$TARGET_DIR/s3-backup-rotate.sh"
chmod 755 "$TARGET_DIR/s3-backup-rotate.sh"

echo
echo "Installation completed."
echo
echo "Installed scripts:"
echo "  $TARGET_DIR/cg"
echo "  $TARGET_DIR/s3-backup-rotate.sh"
