#!/usr/bin/env bash
set -euo pipefail

BASEDIR="/var/lib/monarc"
RELEASES="$BASEDIR/releases"
APP_LINK="$BASEDIR/fo"
DATA_DIR="$BASEDIR/fo-data"

# Ensure base directories exist
mkdir -p "$RELEASES" "$DATA_DIR"/{cache,DoctrineORMModule/Proxy,LazyServices/Proxy,import/files}

# Get latest version
VERSION=$(curl -s https://api.github.com/repos/monarc-project/MonarcAppFO/releases/latest | jq -r '.tag_name')
[ -z "$VERSION" ] && { echo "Failed to resolve app release version"; exit 1; }
RELEASE_NAME="MonarcAppFO-${VERSION}"
ARCHIVE_URL="https://github.com/monarc-project/MonarcAppFO/releases/download/${VERSION}/${RELEASE_NAME}.tar.gz"

# Extraction target
TARGET_DIR="$RELEASES/$RELEASE_NAME"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    echo "Downloading the latest Monarc version $VERSION"
    # --strip-components=1 prevents the "folder inside a folder" issue
    curl -L "$ARCHIVE_URL" | tar -xzf - -C "$TARGET_DIR" --strip-components=1
else
    echo "ERROR! $TARGET_DIR already exists!"; exit 1
fi

# Link data (remove existing folder in release if it exists to allow symlink)
rm -rf "$TARGET_DIR/data"
ln -sfn "$DATA_DIR" "$TARGET_DIR/data"

# Atomic switch of the main app link
ln -sfn "$TARGET_DIR" "$APP_LINK"

# change owner
chown -R www-data:www-data /var/lib/monarc