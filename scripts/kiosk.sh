#!/usr/bin/env bash
# Launch Chromium on HDMI display (:0) for Pi OS Desktop
set -euo pipefail

CONFIG_FILE="/usr/local/dashpi/config/dakboard-url.txt"
REFRESH_FILE="/usr/local/dashpi/config/refresh-interval"

URL=$(<"$CONFIG_FILE")
INTERVAL=$(<"$REFRESH_FILE")

echo "[+] Starting Chromium kiosk on HDMI (:0)..."

# Kill any existing Chromium
pkill -f chromium || true

# Ensure X server is running
if ! xdpyinfo >/dev/null 2>&1; then
    echo "[!] No X server running on :0 — start desktop session first."
    exit 1
fi

# Disable screen blanking / DPMS
xset -dpms
xset s off
xset s noblank

# Launch Chromium
chromium --noerrdialogs --disable-infobars --kiosk "$URL" &
CHROMIUM_PID=$!
echo "[+] Chromium launched with PID $CHROMIUM_PID"

# Auto-refresh loop
while true; do
    sleep "${INTERVAL}m"
    if xdotool search --onlyvisible --class chromium >/dev/null 2>&1; then
        echo "[*] Refreshing dashboard..."
        xdotool search --onlyvisible --class chromium windowactivate key F5
    else
        echo "[!] Chromium not running — restarting..."
        chromium --noerrdialogs --disable-infobars --kiosk "$URL" &
        CHROMIUM_PID=$!
    fi
done
