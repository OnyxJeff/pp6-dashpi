#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi Update Script
# Updates packages and logs results
# -------------------------------------------------------------------

LOGFILE="$HOME/pp6-dashpi/logs/dashpi.log"
mkdir -p "$(dirname "$LOGFILE")"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$NOW] Starting DashPi update..." | tee -a "$LOGFILE"

# Update
if ! sudo apt-get update 2>&1 | sudo tee -a "$LOGFILE" >/dev/null; then
    echo "[$NOW] apt-get update failed" | tee -a "$LOGFILE"
fi

# Fix broken packages
{
    echo "[$NOW] Running fix-broken install..."
    sudo apt-get --fix-broken install -y
} 2>&1 | sudo tee -a "$LOGFILE" >/dev/null

# Upgrade packages
{
    echo "[$NOW] Running upgrade..."
    sudo apt-get upgrade -y
} 2>&1 | sudo tee -a "$LOGFILE" >/dev/null

# Cleanup
{
    echo "[$NOW] Running autoremove..."
    sudo apt-get autoremove -y
    echo "[$NOW] Running clean..."
    sudo apt-get clean
    echo "[$NOW] Running autoclean..."
    sudo apt-get autoclean
} 2>&1 | sudo tee -a "$LOGFILE" >/dev/null

echo "[$NOW] DashPi update complete." | tee -a "$LOGFILE"