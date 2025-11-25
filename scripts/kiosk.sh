#!/usr/bin/env bash
# Launch Chromium on actual HDMI (:0) for Pi 4B 4GB
set -euo pipefail

CONFIG_FILE="/usr/local/dashpi/config/dakboard-url.txt"
REFRESH_FILE="/usr/local/dashpi/config/refresh-interval"

# Read DakBoard URL and refresh interval
URL=$(<"$CONFIG_FILE")
INTERVAL=$(<"$REFRESH_FILE")

echo "[+] Starting Chromium kiosk on HDMI display (:0)..."

# Kill any existing Chromium instances
pkill -f chromium || true

# Check that X server is available
if ! xdpyinfo >/dev/null 2>&1; then
    echo "[!] No X server running on :0 — please start X before running this script."
    exit 1
fi

# Disable screen blanking / DPMS
xset -dpms
xset s off
xset s noblank

# Launch Chromium in kiosk mode on HDMI
chromium \
    --noerrdialogs \
    --disable-infobars \
    --kiosk "$URL" &

CHROMIUM_PID=$!
echo "[+] Chromium launched with PID $CHROMIUM_PID"

# Auto-refresh every $INTERVAL minutes
while true; do
    sleep "${INTERVAL}m"
    # Attempt to refresh Chromium safely
    if xdotool search --onlyvisible --class chromium >/dev/null 2>&1; then
        echo "[*] Refreshing dashboard..."
        xdotool search --onlyvisible --class chromium windowactivate key F5
    else
        echo "[!] Chromium not running — restarting..."
        chromium \
            --noerrdialogs \
            --disable-infobars \
            --kiosk "$URL" &
        CHROMIUM_PID=$!
    fi
done