#!/usr/bin/env bash
# DashPi Chromium Kiosk – Desktop OS, auto-refresh, dynamic URL reload
set -euo pipefail

CONFIG_FILE="$HOME/pp6-dashpi/config/dakboard-url.txt"
REFRESH_FILE="$HOME/pp6-dashpi/config/refresh-interval"

# Check that inotifywait is installed
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "[!] Please install inotify-tools: sudo apt install inotify-tools"
    exit 1
fi

# Read refresh interval once at start
INTERVAL=$(<"$REFRESH_FILE")

echo "[+] Starting Chromium kiosk on HDMI (:0)..."

# Kill any existing Chromium instances
pkill -f kiosk.sh || true
pkill -f chromium || true

# Wait for X server (desktop session)
until xdpyinfo >/dev/null 2>&1; do
    echo "[*] Waiting for desktop session..."
    sleep 2
done

# Disable screen blanking / DPMS
xset -dpms
xset s off
xset s noblank

# Function to launch Chromium
launch_chromium() {
    local url="$1"
    echo "[+] Launching Chromium with URL: $url"
    chromium --noerrdialogs --disable-infobars --kiosk "$url" &
    CHROMIUM_PID=$!
}

# Initial launch
URL=$(<"$CONFIG_FILE")
launch_chromium "$URL"

# Watch for file changes and refresh periodically
while true; do
    # Use inotifywait to detect changes in the config file
    inotifywait -q -e close_write "$CONFIG_FILE"

    # Reload URL from file
    NEW_URL=$(<"$CONFIG_FILE")

    if [[ "$NEW_URL" != "$URL" ]]; then
        echo "[*] URL changed — navigating Chromium to new URL: $NEW_URL"
        URL="$NEW_URL"
        # Open the new URL in the existing Chromium window
        xdotool search --onlyvisible --class chromium windowactivate key --clearmodifiers ctrl+l type --delay 1 "$URL" key Return
    else
        echo "[*] Config file updated but URL unchanged — refreshing page."
        xdotool search --onlyvisible --class chromium windowactivate key F5
    fi

    # Also refresh Chromium periodically in case it hangs
    sleep "${INTERVAL}m"
    xdotool search --onlyvisible --class chromium windowactivate key F5
done
