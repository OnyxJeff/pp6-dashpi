#!/usr/bin/env bash
# Launch Chromium on Desktop OS
set -euo pipefail

CONFIG_FILE="$HOME/pp6-dashpi/config/dakboard-url.txt"
REFRESH_FILE="$HOME/pp6-dashpi/config/refresh-interval"

URL=$(<"$CONFIG_FILE")
INTERVAL=$(<"$REFRESH_FILE")

echo "[+] Starting Chromium kiosk on HDMI (:0)..."

# Kill existing Chromium
pkill -f chromium || true

# Disable screen blanking
xset s off
xset s noblank

# Launch Chromium in kiosk mode
chromium \
  --noerrdialogs \
  --disable-infobars \
  --kiosk "$URL" &

CHROMIUM_PID=$!
echo "[+] Chromium launched with PID $CHROMIUM_PID"

# Keep script alive to allow auto-refresh
while true; do
  sleep "${INTERVAL}m"
  if xdotool search --onlyvisible --class chromium >/dev/null 2>&1; then
      xdotool search --onlyvisible --class chromium windowactivate key F5
  else
      echo "[!] Chromium not running — restarting..."
      chromium --noerrdialogs --disable-infobars --kiosk "$URL" &
      CHROMIUM_PID=$!
  fi
done