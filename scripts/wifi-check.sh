#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi WiFi Watchdog
# Pings an external server and restarts wlan0 if connectivity fails
# -------------------------------------------------------------------

PING_TARGET="8.8.8.8"
IFACE="wlan0"
LOGFILE="$HOME/pp6-dashpi/logs/wifi-watchdog.log"
mkdir -p "$(dirname "$LOGFILE")"

if ! ping -c1 "$PING_TARGET" &>/dev/null; then
    echo "[$(date)] WiFi down — restarting $IFACE" | tee -a "$LOGFILE"
    sudo ip link set "$IFACE" down
    sleep 2
    sudo ip link set "$IFACE" up
    sleep 5
    echo "[$(date)] $IFACE restarted" | tee -a "$LOGFILE"
fi