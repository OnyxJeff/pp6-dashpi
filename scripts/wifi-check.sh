#!/usr/bin/env bash
set -euo pipefail

LOGFILE="/home/potentpi6/pp6-dashpi/logs/wifi-check.log"

CONFIG_FILE="/usr/local/dashpi/config/wifi-watchdog.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "Missing config: $CONFIG_FILE"
    exit 1
fi

PING_HOST="${PING_TARGET:-8.8.8.8}"
INTERFACE="${INTERFACE:-wlan0}"

{
    echo "$(date '+%F %T') Checking WiFi..."
    if ! ping -c1 -W2 "$PING_HOST" >/dev/null 2>&1; then
        echo "$(date '+%F %T') WiFi down — restarting $INTERFACE..."
        ip link set "$INTERFACE" down || true
        sleep 2
        ip link set "$INTERFACE" up || true
        sleep 5

        if ! ping -c1 -W2 "$PING_HOST" >/dev/null 2>&1; then
            echo "$(date '+%F %T') Still down — rebooting Pi."
            /sbin/reboot
        else
            echo "$(date '+%F %T') WiFi restored."
        fi
    fi
} >> "$LOGFILE" 2>&1
