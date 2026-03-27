#!/bin/bash
set -euo pipefail

BASE_DIR="/usr/local/dashpi"
CONFIG_DIR="$BASE_DIR/config"

URL_FILE="$CONFIG_DIR/url.txt"
REFRESH_FILE="$CONFIG_DIR/refresh.txt"
CHECK_INTERVAL=5

get_url() {
    [[ -f "$URL_FILE" ]] && cat "$URL_FILE" || echo "https://example.com"
}

get_refresh() {
    if [[ -f "$REFRESH_FILE" ]]; then
        cat "$REFRESH_FILE"
    else
        echo 300
    fi
}

launch_browser() {
    local URL
    URL=$(get_url)

    echo "Launching Chromium with URL: $URL"

    chromium \
        --kiosk "$URL" \
        --start-fullscreen \
        --noerrdialogs \
        --disable-session-crashed-bubble \
        --disable-infobars \
        --disable-translate \
        --disable-features=TranslateUI \
        --incognito \
        --no-first-run \
        --check-for-update-interval=31536000 &

}

LAST_URL=""
LAST_REFRESH_TIME=0

# Optional: hide cursor
unclutter -idle 0 &

while true; do
    CURRENT_URL=$(get_url)
    CURRENT_REFRESH=$(get_refresh)

    # Restart if URL changed
    if [[ "$CURRENT_URL" != "$LAST_URL" ]]; then
        echo "URL changed → restarting Chromium"
        pkill chromium || true
        launch_browser
        LAST_URL="$CURRENT_URL"
        LAST_REFRESH_TIME=$(date +%s)
    fi

    # Restart if Chromium died
    if ! pgrep -x chromium >/dev/null; then
        echo "Chromium not running → restarting"
        launch_browser
        LAST_REFRESH_TIME=$(date +%s)
    fi

    # Handle auto-refresh timer
    NOW=$(date +%s)
    if (( NOW - LAST_REFRESH_TIME >= CURRENT_REFRESH )); then
        echo "Refreshing page to prevent burn-in..."
        pkill chromium || true
        launch_browser
        LAST_REFRESH_TIME=$NOW
    fi

    sleep $CHECK_INTERVAL
done