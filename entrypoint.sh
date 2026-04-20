#!/bin/sh
set -e

MESHCORE_BASE_URL="${MESHCORE_BASE_URL:-https://files.liamcottle.net/MeshCore}"
UPDATE_INTERVAL="${UPDATE_INTERVAL:-3600}" # seconds, default 1 hour
CURRENT_VERSION_FILE="/app/current_version"

get_latest_version() {
    curl -sf "$MESHCORE_BASE_URL/" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+/' | sort -V | tail -1 | tr -d '/'
}

download_version() {
    VERSION="$1"
    echo "[MESHCORE] Downloading version $VERSION..."

    ZIP_FILENAME=$(curl -sf "$MESHCORE_BASE_URL/$VERSION/" | grep -oE '[^"]+\-web\.zip' | head -1)
    if [ -z "$ZIP_FILENAME" ]; then
        echo "[MESHCORE] ERROR: Could not find web zip for version $VERSION"
        return 1
    fi

    FULL_ZIP_URL="$MESHCORE_BASE_URL/$VERSION/$ZIP_FILENAME"
    echo "[MESHCORE] Fetching: $FULL_ZIP_URL"
    curl -L -o /tmp/meshcore-web.zip "$FULL_ZIP_URL"

    echo "[MESHCORE] Extracting..."
    rm -rf /tmp/meshcore-extracted
    unzip -q /tmp/meshcore-web.zip -d /tmp/meshcore-extracted/
    rm /tmp/meshcore-web.zip

    INDEX=$(find /tmp/meshcore-extracted -name "index.html" | head -1)
    if [ -z "$INDEX" ]; then
        echo "[MESHCORE] ERROR: No index.html found in zip"
        rm -rf /tmp/meshcore-extracted
        return 1
    fi

    EXTRACT_DIR=$(dirname "$INDEX")
    rm -rf /app/web/*
    cp -r "$EXTRACT_DIR"/. /app/web/
    rm -rf /tmp/meshcore-extracted

    echo "$VERSION" > "$CURRENT_VERSION_FILE"
    echo "[MESHCORE] Version $VERSION installed successfully"
}

update_loop() {
    while true; do
        sleep "$UPDATE_INTERVAL"
        echo "[UPDATER] Checking for updates..."

        LATEST=$(get_latest_version)
        if [ -z "$LATEST" ]; then
            echo "[UPDATER] Could not fetch latest version, skipping"
            continue
        fi

        CURRENT=$(cat "$CURRENT_VERSION_FILE" 2>/dev/null || echo "none")

        if [ "$LATEST" = "$CURRENT" ]; then
            echo "[UPDATER] Already on latest version ($CURRENT), no update needed"
        else
            echo "[UPDATER] New version available: $LATEST (current: $CURRENT)"
            if download_version "$LATEST"; then
                echo "[UPDATER] Update complete, nginx will serve new files immediately"
            else
                echo "[UPDATER] Update failed, keeping current version"
            fi
        fi
    done
}

# --- Startup ---
echo "[STARTUP] Starting MeshCore Web..."
echo "[STARTUP] Base URL: $MESHCORE_BASE_URL"
echo "[STARTUP] Update interval: ${UPDATE_INTERVAL}s"

# Use pinned version or detect latest
if [ -n "$MESHCORE_VERSION" ]; then
    echo "[STARTUP] Using pinned version: $MESHCORE_VERSION"
    TARGET_VERSION="$MESHCORE_VERSION"
else
    echo "[STARTUP] Detecting latest version..."
    TARGET_VERSION=$(get_latest_version)
    if [ -z "$TARGET_VERSION" ]; then
        echo "[STARTUP] ERROR: Could not detect latest version"
        exit 1
    fi
fi

download_version "$TARGET_VERSION" || exit 1

echo "[STARTUP] MeshCore $TARGET_VERSION ready"
echo "[STARTUP] Starting nginx and update checker..."

# Start update loop in background (only if not pinned to a version)
if [ -z "$MESHCORE_VERSION" ]; then
    update_loop &
fi

exec nginx -g "daemon off;"
