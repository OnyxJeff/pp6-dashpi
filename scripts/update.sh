#!/usr/bin/env bash
# DashPi OS Updater – Pi 4B 4GB
set -e

LOGFILE="$HOME/pp6-dashpi/logs/dashpi-update.log"
mkdir -p "$(dirname "$LOGFILE")"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$NOW] Starting update..." >> "$LOGFILE"

echo "[$NOW] Running apt update..." >> "$LOGFILE"
sudo apt-get update | tee -a "$LOGFILE"

echo "[$NOW] Running apt upgrade..." >> "$LOGFILE"
sudo apt-get upgrade -y | tee -a "$LOGFILE"

echo "[$NOW] Running autoremove..." >> "$LOGFILE"
sudo apt-get autoremove -y | tee -a "$LOGFILE"

echo "[$NOW] Running autoclean..." >> "$LOGFILE"
sudo apt-get autoclean -y | tee -a "$LOGFILE"

echo "[$NOW] Update complete." >> "$LOGFILE"