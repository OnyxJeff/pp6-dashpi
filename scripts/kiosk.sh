#!/usr/bin/env bash
set -e

CONFIG_DIR="/usr/local/dashpi/config"
URL_FILE="$CONFIG_DIR/dakboard-url.txt"
REFRESH_FILE="$CONFIG_DIR/refresh-interval"

URL="$(cat "$URL_FILE")"
REFRESH_MINUTES="$(cat "$REFRESH_FILE")"

LOG_DIR="$HOME/pp6-dashpi/logs"
mkdir -p "$LOG_DIR"

LOGFILE="$LOG_DIR/kiosk.log"

echo "[+] Launching Chromium kiosk..." | tee -a "$LOGFILE"

# Kill any leftover Chromium before launching
pkill chromium || true

chromium \
  --noerrdialogs \
  --disable-infobars \
  --kiosk "$URL" \
  --incognito \
  --fast \
  --fast-start \
  --disable-translate \
  --disable-features=TranslateUI \
  --overscroll-history-navigation=0 \
  --check-for-update-interval=31536000 \
  --window-position=0,0 \
  >> "$LOGFILE" 2>&1 &
CHROME_PID=$!

echo "[+] Chromium launched with PID $CHROME_PID" | tee -a "$LOGFILE"

# Auto refresh loop
echo "[*] Starting auto-refresh every $REFRESH_MINUTES minutes..." | tee -a "$LOGFILE"

while true; do
    sleep $(( REFRESH_MINUTES * 60 ))
    # Send F5 to Chromium (refresh)
    xdotool search --onlyvisible --class "chromium" key F5 || true
done
