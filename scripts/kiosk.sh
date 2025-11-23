#!/usr/bin/env bash
# DashPi Chromium Kiosk Launcher
# Launches Chromium in fullscreen kiosk mode with auto-reload

set -e

# -------------------------------
# Config paths
# -------------------------------
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
DAKBOARD_URL_FILE="$SYSTEM_CONFIG_DIR/dakboard-url.txt"
REFRESH_FILE="$SYSTEM_CONFIG_DIR/refresh-interval"

# -------------------------------
# Read config values
# -------------------------------
if [[ ! -f "$DAKBOARD_URL_FILE" ]]; then
    echo "[!] DakBoard URL file not found: $DAKBOARD_URL_FILE"
    exit 1
fi

if [[ ! -f "$REFRESH_FILE" ]]; then
    echo "[!] Refresh interval file not found: $REFRESH_FILE"
    exit 1
fi

DAKBOARD_URL=$(cat "$DAKBOARD_URL_FILE")
REFRESH_INTERVAL=$(cat "$REFRESH_FILE")

# Validate refresh interval is numeric
if ! [[ "$REFRESH_INTERVAL" =~ ^[0-9]+$ ]]; then
    echo "[!] Refresh interval invalid: $REFRESH_INTERVAL. Using default 15 minutes."
    REFRESH_INTERVAL=15
fi

# Convert minutes to seconds
REFRESH_SECONDS=$(( REFRESH_INTERVAL * 60 ))

# -------------------------------
# Launch Chromium in kiosk mode
# -------------------------------
echo "[+] Launching Chromium kiosk..."
# Kill any previous Chromium instances
pkill -f chromium || true

# Start X server if not running (headless setups may need X)
if ! pgrep Xorg > /dev/null; then
    echo "[*] Starting X server..."
    startx &
    sleep 5
fi

# Launch Chromium
chromium --kiosk "$DAKBOARD_URL" \
         --incognito \
         --noerrdialogs \
         --disable-translate \
         --disable-infobars \
         --disable-session-crashed-bubble &

CHROMIUM_PID=$!
echo "[+] Chromium launched with PID $CHROMIUM_PID"

# -------------------------------
# Optional: auto-reload
# -------------------------------
echo "[*] Starting auto-refresh every $REFRESH_INTERVAL minutes..."
while true; do
    sleep "$REFRESH_SECONDS"
    echo "[*] Refreshing Chromium..."
    # Reload via xdotool if installed, otherwise restart Chromium
    if command -v xdotool > /dev/null; then
        xdotool search --onlyvisible --class "Chromium" key F5
    else
        echo "[*] xdotool not found — restarting Chromium"
        pkill -f chromium || true
        chromium --kiosk "$DAKBOARD_URL" \
                 --incognito \
                 --noerrdialogs \
                 --disable-translate \
                 --disable-infobars \
                 --disable-session-crashed-bubble &
        CHROMIUM_PID=$!
    fi
done