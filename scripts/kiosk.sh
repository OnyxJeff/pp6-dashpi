#!/usr/bin/env bash
# DashPi kiosk launcher (Chromium)

# Path to DakBoard URL config
DAKBOARD_URL_FILE="/usr/local/dakpi/config/dakboard-url.txt"

if [[ ! -f "$DAKBOARD_URL_FILE" ]]; then
    echo "[ERROR] DakBoard URL file not found: $DAKBOARD_URL_FILE"
    exit 1
fi

URL=$(cat "$DAKBOARD_URL_FILE")

echo "[+] Launching Chromium kiosk with URL: $URL"

# Kill any existing Chromium instances first
pkill chromium-browser || true

# Start Chromium in kiosk mode
/usr/bin/chromium-browser \
    --noerrdialogs \
    --kiosk \
    --incognito "$URL" \
    --disable-translate \
    --no-first-run \
    --window-size=800,600 \
    --disable-infobars &

echo "[+] Chromium kiosk started."