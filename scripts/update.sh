#!/usr/bin/env bash
# DashPi Auto-Updater Script
LOGFILE="$HOME/pp6-dashpi/logs/dashpi.log"
NOW=$(date '+%Y-%m-%d %H:%M:%S')

{
    echo "[$NOW] Starting DashPi update..."

    if ! sudo apt-get update; then
        echo "[$NOW] apt-get update failed!"
    fi

    echo "[$NOW] Running Fix-Broken Install..."
    sudo apt-get --fix-broken install -y || echo "[$NOW] Fix-broken failed"

    echo "[$NOW] Running Upgrade..."
    sudo apt-get upgrade -y || echo "[$NOW] Upgrade failed"

    echo "[$NOW] Running AutoRemove..."
    sudo apt-get autoremove -y || echo "[$NOW] Autoremove failed"

    echo "[$NOW] Running Clean..."
    sudo apt-get clean || echo "[$NOW] Clean failed"
    sudo apt-get autoclean || echo "[$NOW] Autoclean failed"

    echo "[$NOW] Update complete!"
} >> "$LOGFILE" 2>&1