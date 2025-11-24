#!/usr/bin/env bash
# Launch Chromium on actual HDMI for Pi 4B 4GB
set -e

CONFIG_FILE="/usr/local/dashpi/config/dakboard-url.txt"
REFRESH_FILE="/usr/local/dashpi/config/refresh-interval"

URL=$(<"$CONFIG_FILE")
INTERVAL=$(<"$REFRESH_FILE")

echo "[+] Launching Chromium in kiosk mode..."
# Kill any existing Chromium instances
pkill -f chromium || true

# Launch Chromium on real display (:0) full-screen
export DISPLAY=:0
chromium --noerrdialogs --disable-infobars --kiosk "$URL" &
# shellcheck disable=SC2034
CHROMIUM_PID=$!

# Auto-refresh every $INTERVAL minutes
while true; do
    sleep "${INTERVAL}m"
    echo "[*] Refreshing dashboard..."
    xdotool search --onlyvisible --class chromium windowactivate key F5
done