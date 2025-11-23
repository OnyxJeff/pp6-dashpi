#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi Kiosk Launcher
# Loads your dashboard in a lightweight fullscreen browser
# -------------------------------------------------------------------

URL_FILE="/usr/local/dashpi/config/dakboard-url.txt"
if [ ! -f "$URL_FILE" ]; then
    echo "[ERROR] URL file not found: $URL_FILE"
    exit 1
fi

URL=$(cat "$URL_FILE")

# Disable screen blanking / DPMS
xset -dpms
xset s off
xset s noblank

# Start minimal window manager
matchbox-window-manager &

# Loop to auto-restart browser if it crashes
while true; do
    /usr/bin/kweb \
        --fullscreen \
        --nozoom \
        --nonavbar \
        --disablecontextmenu \
        --private \
        "$URL"
    sleep 2
done