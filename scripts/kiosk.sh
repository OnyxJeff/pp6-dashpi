#!/usr/bin/env bash
# DashPi Kiosk – Desktop OS, Pi 4B 4GB
set -euo pipefail

CONFIG_FILE="$HOME/pp6-dashpi/config/dakboard-url.txt"
REFRESH_FILE="$HOME/pp6-dashpi/config/refresh-interval"

# Read DakBoard URL and refresh interval
URL=$(<"$CONFIG_FILE")
INTERVAL=$(<"$REFRESH_FILE")

echo "[+] Starting Chromium kiosk on HDMI (:0)..."

# Kill any existing Chromium instances
pkill -f chromium || true

# Disable screen blanking / DPMS for the desktop session
xset -display :0 dpms force off 2>/dev/null || true
xset -display :0 s off 2>/dev/null || true
xset -display :0 s noblank 2>/dev/null || true

# Launch Chromium in kiosk mode on HDMI
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
