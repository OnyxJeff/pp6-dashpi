#!/usr/bin/env bash
set -euo pipefail

LOGFILE="/var/log/wifi-check.log"
PING_HOST="8.8.8.8"

{
    echo "$(date '+%F %T') Checking WiFi..."

    if ! ping -c1 -W2 "$PING_HOST" >/dev/null 2>&1; then
        echo "$(date '+%F %T') WiFi down — restarting wlan0..."
        ip link set wlan0 down || true
        sleep 2
        ip link set wlan0 up || true
        sleep 5

        if ! ping -c1 -W2 "$PING_HOST" >/dev/null 2>&1; then
            echo "$(date '+%F %T') Still down — rebooting Pi."
            /sbin/reboot
        else
            echo "$(date '+%F %T') WiFi restored."
        fi
    fi
} >> "$LOGFILE" 2>&1