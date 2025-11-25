#!/usr/bin/env bash
# Launch Chromium on actual HDMI (:0) for Pi 4B 4GB Desktop OS
set -euo pipefail

CONFIG_FILE="/usr/local/dashpi/config/dakboard-url.txt"
REFRESH_FILE="/usr/local/dashpi/config/refresh-interval"

# Read DakBoard URL and refresh interval
URL=$(<"$CONFIG_FILE")
INTERVAL=$(<"$REFRESH_FILE")

echo "[+] Starting Chromium kiosk on HDMI display (:0)..."

# Kill any existing Chromium instances
pkill -f chromium || true

# Check that X server is available on :0
if ! xdpyinfo -display :0 >/dev/null 2>&1; then
    echo "[!] No X server running on :0 — start Desktop session first."
    exit 1
fi

# Disable screen blanking / DPMS
xset -display :0 -dpms
xset -display :0 s off
xset -display :0 s noblank

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
    if xdotool search --display :0 --onlyvisible --class chromium >/dev/null 2>&1; then
        echo "[*] Refreshing dashboard..."
        xdotool search --display :0 --onlyvisible --class chromium windowactivate key F5
    else
        echo "[!] Chromium not running — restarting..."
        chromium \
            --noerrdialogs \
            --disable-infobars \
            --kiosk "$URL" &
        CHROMIUM_PID=$!
    fi
done