#!/usr/bin/env bash
# DashPi OS Updater – Pi OS Desktop
set -euo pipefail

LOGFILE="$HOME/pp6-dashpi/logs/dashpi-update.log"
mkdir -p "$(dirname "$LOGFILE")"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$NOW] Starting update..." >> "$LOGFILE"

sudo apt-get update | tee -a "$LOGFILE"
sudo apt-get upgrade -y | tee -a "$LOGFILE"
sudo apt-get autoremove -y | tee -a "$LOGFILE"
sudo apt-get autoclean -y | tee -a "$LOGFILE"

echo "[$NOW] Update complete." >> "$LOGFILE"
