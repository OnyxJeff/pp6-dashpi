#!/usr/bin/env bash
# DashPi OS Updater – Desktop OS
set -euo pipefail

LOGFILE="$HOME/pp6-dashpi/logs/dashpi-update.log"
mkdir -p "$(dirname "$LOGFILE")"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$NOW] Starting update..." >> "$LOGFILE"

{
    echo "[$NOW] Running apt update..."
    sudo apt-get update
    echo "[$NOW] Running apt upgrade..."
    sudo apt-get upgrade -y
    echo "[$NOW] Running autoremove..."
    sudo apt-get autoremove -y
    echo "[$NOW] Running autoclean..."
    sudo apt-get autoclean -y
    echo "[$NOW] Update complete."
} >> "$LOGFILE" 2>&1
