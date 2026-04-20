#!/bin/sh
set -e

MESHCORE_BASE_URL="${MESHCORE_BASE_URL:-https://files.liamcottle.net/MeshCore}"
MESHCORE_VERSION="${MESHCORE_VERSION:-}"

echo "[STARTUP] Starting MeshCore Web..."
echo "[STARTUP] Base URL: $MESHCORE_BASE_URL"

# Determine latest version if not specified
if [ -z "$MESHCORE_VERSION" ]; then
    echo "[STARTUP] No version specified, detecting latest..."
    # Fetch the directory listing and parse the latest vX.X.X folder
    MESHCORE_VERSION=$(curl -sf "$MESHCORE_BASE_URL/" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+/' | sort -V | tail -1 | tr -d '/')
    if [ -z "$MESHCORE_VERSION" ]; then
        echo "[STARTUP] ERROR: Could not detect latest version"
        exit 1
    fi
fi

echo "[STARTUP] Using version: $MESHCORE_VERSION"

# Find the web zip filename for this version
ZIP_FILENAME=$(curl -sf "$MESHCORE_BASE_URL/$MESHCORE_VERSION/" | grep -oE '[^"]+\-web\.zip' | head -1)

if [ -z "$ZIP_FILENAME" ]; then
    echo "[STARTUP] ERROR: Could not find web zip for version $MESHCORE_VERSION"
    exit 1
fi

FULL_ZIP_URL="$MESHCORE_BASE_URL/$MESHCORE_VERSION/$ZIP_FILENAME"

echo "[STARTUP] Downloading: $FULL_ZIP_URL"
curl -L -o /tmp/meshcore-web.zip "$FULL_ZIP_URL"

echo "[STARTUP] Extracting..."
rm -rf /app/web/*
unzip -q /tmp/meshcore-web.zip -d /tmp/meshcore-extracted/
rm /tmp/meshcore-web.zip

# Find where index.html ended up and move everything to /app/web
INDEX=$(find /tmp/meshcore-extracted -name "index.html" | head -1)
if [ -z "$INDEX" ]; then
    echo "[STARTUP] ERROR: No index.html found in zip"
    exit 1
fi
EXTRACT_DIR=$(dirname "$INDEX")
cp -r "$EXTRACT_DIR"/. /app/web/
rm -rf /tmp/meshcore-extracted

echo "[STARTUP] MeshCore $MESHCORE_VERSION ready"
echo "[STARTUP] Starting nginx..."

exec nginx -g "daemon off;"
