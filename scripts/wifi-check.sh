#!/usr/bin/env bash
# DashPi WiFi watchdog script
# shellcheck source=/usr/local/dashpi/config/wifi-watchdog.conf
# ==============================

CONFIG_FILE="/usr/local/dashpi/config/wifi-watchdog.conf"
LOGFILE="$HOME/pp6-dashpi/logs/wifi-watchdog.log"

mkdir -p "$(dirname "$LOGFILE")"
source "$CONFIG_FILE"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$NOW] Checking WiFi..." | tee -a "$LOGFILE"

if ! ping -I "$INTERFACE" -c 1 "$PING_TARGET" >/dev/null 2>&1; then
    echo "[$NOW] WiFi down, restarting $INTERFACE..." | tee -a "$LOGFILE"
    sudo ifdown "$INTERFACE" && sudo ifup "$INTERFACE"
else
    echo "[$NOW] WiFi is up." | tee -a "$LOGFILE"
fi