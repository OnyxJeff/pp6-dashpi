#!/usr/bin/env bash
# DashPi Chromium Kiosk Launcher
# shellcheck source=/usr/local/dashpi/config/dakboard-url.txt

CONFIG_FILE="/usr/local/dashpi/config/dakboard-url.txt"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] DakBoard URL file not found: $CONFIG_FILE"
    exit 1
fi

URL=$(cat "$CONFIG_FILE")
echo "[+] Launching Chromium kiosk with URL: $URL"

# Kill any existing Chromium instances
pkill chromium || true

# Start Chromium in kiosk mode
/usr/bin/chromium \
    --noerrdialogs \
    --kiosk "$URL" \
    --incognito \
    --disable-translate \
    --no-first-run \
    --disable-infobars &