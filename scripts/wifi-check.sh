#!/usr/bin/env bash
# DashPi WiFi Watchdog
# Checks connectivity and restarts wlan0 if ping fails

set -e

# -------------------------------
# Config
# -------------------------------
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
CONFIG_FILE="$SYSTEM_CONFIG_DIR/wifi-watchdog.conf"

# shellcheck disable=SC1091
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[!] WiFi watchdog config not found: $CONFIG_FILE"
    exit 1
fi

# Load configuration
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Validate variables
: "${INTERFACE:?INTERFACE is not set in $CONFIG_FILE}"
: "${PING_TARGET:?PING_TARGET is not set in $CONFIG_FILE}"

LOG_FILE="/usr/local/dashpi/logs/wifi-watchdog.log"
mkdir -p "$(dirname "$LOG_FILE")"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$NOW] Checking WiFi ($INTERFACE -> $PING_TARGET)..." >> "$LOG_FILE"

if ! ping -c 1 -W 2 "$PING_TARGET" &> /dev/null; then
    echo "[$NOW] Ping failed — restarting $INTERFACE" >> "$LOG_FILE"
    sudo ip link set "$INTERFACE" down
    sleep 2
    sudo ip link set "$INTERFACE" up
    sleep 5
    if ping -c 1 -W 2 "$PING_TARGET" &> /dev/null; then
        echo "[$NOW] $INTERFACE restarted successfully" >> "$LOG_FILE"
    else
        echo "[$NOW] WARNING: $INTERFACE still unreachable!" >> "$LOG_FILE"
    fi
else
    echo "[$NOW] WiFi is up" >> "$LOG_FILE"
fi