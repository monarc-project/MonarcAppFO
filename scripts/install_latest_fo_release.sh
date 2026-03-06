#!/usr/bin/env bash
set -euo pipefail

BASEDIR="/var/lib/monarc"
RELEASES="$BASEDIR/releases"
APP_LINK="$BASEDIR/fo"
DATA_DIR="$BASEDIR/fo-data"

function error() { echo "Error: $1" > /dev/stderr; exit 1; }

# ensure no existing release is present
if [ -f "$APP_LINK/config/autoload/local.php" ]; then
    echo "Existing Monarc installation found! Run the UPDATE script instead:";
    echo "    https://github.com/monarc-project/MonarcAppFO/blob/master/INSTALL/UPDATE.ubuntu.md";
    error "Aborting installation.";
fi

# Ensure base directories exist
mkdir -p "$RELEASES" "$DATA_DIR"/{cache,DoctrineORMModule/Proxy,LazyServices/Proxy,import/files}

# Get latest version
VERSION=$(curl -s https://api.github.com/repos/monarc-project/MonarcAppFO/releases/latest | jq -r '.tag_name')
if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    error "Failed to resolve app release version"
fi
RELEASE_NAME="MonarcAppFO-${VERSION}"
ARCHIVE_URL="https://github.com/monarc-project/MonarcAppFO/releases/download/${VERSION}/${RELEASE_NAME}.tar.gz"

# Extraction target
TARGET_DIR="$RELEASES/$RELEASE_NAME"
test -d "$TARGET_DIR" && error "$TARGET_DIR already exists!"
mkdir -p "$TARGET_DIR"

echo "Downloading the latest Monarc version $VERSION"
# --strip-components=1 prevents the "folder inside a folder" issue
curl -L "$ARCHIVE_URL" | tar -xzf - -C "$TARGET_DIR" --strip-components=1

# if data folder exist in release - remove it to allow symlink
rm -rf "$TARGET_DIR/data"
# Link data folder into release folder
ln -sfn "$DATA_DIR" "$TARGET_DIR/data"

# Link the release into the app folder
ln -sfn "$TARGET_DIR" "$APP_LINK"

# change owner
chown -R www-data:www-data "$BASE_DIR"

echo "Monarc version $VERSION files was installed successfully!"
echo "No database or web-server configuration changes were made."
echo "Follow the installation instruction for the next steps."