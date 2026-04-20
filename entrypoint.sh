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

# Find the web zip for this version
ZIP_URL=$(curl -sf "$MESHCORE_BASE_URL/$MESHCORE_VERSION/" | grep -oE 'href="[^"]*-web\.zip"' | grep -oE '"[^"]*"' | tr -d '"' | head -1)

if [ -z "$ZIP_URL" ]; then
    echo "[STARTUP] ERROR: Could not find web zip for version $MESHCORE_VERSION"
    exit 1
fi

# Handle relative vs absolute URLs
case "$ZIP_URL" in
    http*) FULL_ZIP_URL="$ZIP_URL" ;;
    /*) FULL_ZIP_URL="https://files.liamcottle.net$ZIP_URL" ;;
    *) FULL_ZIP_URL="$MESHCORE_BASE_URL/$MESHCORE_VERSION/$ZIP_URL" ;;
esac

echo "[STARTUP] Downloading: $FULL_ZIP_URL"
curl -L -o /tmp/meshcore-web.zip "$FULL_ZIP_URL"

echo "[STARTUP] Extracting..."
rm -rf /app/web/*
unzip -q /tmp/meshcore-web.zip -d /app/web/
rm /tmp/meshcore-web.zip

# Some zips extract into a subdirectory - flatten if needed
if [ ! -f /app/web/index.html ]; then
    SUBDIR=$(ls /app/web/ | head -1)
    if [ -f "/app/web/$SUBDIR/index.html" ]; then
        mv /app/web/$SUBDIR/* /app/web/
        rmdir /app/web/$SUBDIR
    fi
fi

echo "[STARTUP] MeshCore $MESHCORE_VERSION ready"
echo "[STARTUP] Starting nginx..."

exec nginx -g "daemon off;"
