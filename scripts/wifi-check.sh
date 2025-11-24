#!/usr/bin/env bash
# WiFi Watchdog – Pi 4B 4GB
set -e

CONFIG_FILE="/usr/local/dashpi/config/wifi-watchdog.conf"
source "$CONFIG_FILE"

LOGFILE="$HOME/pp6-dashpi/logs/wifi-watchdog.log"
mkdir -p "$(dirname "$LOGFILE")"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
ping -c 1 "$PING_TARGET" &>/dev/null
if [[ $? -ne 0 ]]; then
    echo "[$NOW] Ping failed. Restarting $INTERFACE..." >> "$LOGFILE"
    sudo ip link set "$INTERFACE" down
    sleep 2
    sudo ip link set "$INTERFACE" up
else
    echo "[$NOW] Ping OK." >> "$LOGFILE"
fi