#!/usr/bin/env bash
# DashPi WiFi Watchdog
# Checks connectivity and restarts wlan0 if unreachable
# Fully ShellCheck-friendly

set -euo pipefail

# shellcheck source=/dev/null
CONFIG_FILE="/usr/local/dashpi/config/wifi-watchdog.conf"

# Load configuration
source "$CONFIG_FILE"

# Logs
LOG_DIR="$HOME/pp6-dashpi/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/wifi-watchdog.log"

NOW=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$NOW] Checking WiFi connectivity..." | tee -a "$LOG_FILE"

# Test connectivity
if ! ping -c 1 "$PING_TARGET" &> /dev/null; then
    echo "[$NOW] Ping failed. Restarting $INTERFACE..." | tee -a "$LOG_FILE"
    if sudo ip link set "$INTERFACE" down && sudo ip link set "$INTERFACE" up; then
        echo "[$NOW] $INTERFACE restarted successfully." | tee -a "$LOG_FILE"
    else
        echo "[$NOW] Failed to restart $INTERFACE." | tee -a "$LOG_FILE"
    fi
else
    echo "[$NOW] WiFi is up." | tee -a "$LOG_FILE"
fi