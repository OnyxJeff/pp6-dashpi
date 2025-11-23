#!/usr/bin/env bash
# DashPi WiFi Watchdog
# shellcheck source=/usr/local/dashpi/config/wifi-watchdog.conf

CONFIG_FILE="/usr/local/dashpi/config/wifi-watchdog.conf"
# shellcheck disable=SC1090
source "$CONFIG_FILE"

LOGFILE="$HOME/pp6-dashpi/logs/wifi-watchdog.log"
NOW=$(date '+%Y-%m-%d %H:%M:%S')

ping -c1 "$PING_TARGET" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "[$NOW] WiFi down, restarting $INTERFACE..." >> "$LOGFILE"
    sudo ifdown "$INTERFACE" && sudo ifup "$INTERFACE"
else
    echo "[$NOW] WiFi OK." >> "$LOGFILE"
fi