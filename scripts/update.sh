#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$(dirname "$SCRIPT_DIR")/logs/update.log"
NOW=$(date "+%Y-%m-%d %H:%M:%S")

# Detect if running in a terminal (not cron)
if [ -t 1 ]; then
    # Running interactively → log AND print
    exec > >(tee -a "$LOG_FILE") 2>&1
else
    # Running via cron → log only
    exec >> "$LOG_FILE" 2>&1
fi

echo
date
echo "############################"
echo "[$NOW] Starting apt-get autoupdate..."

# Step 1: apt-get update
echo "[$NOW] Running apt-get update..."
sudo apt-get update
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] apt-get update failed."
    exit 1
fi

# Step 2: upgrade packages
echo "[$NOW] Running apt-get upgrade..."
sudo apt-get upgrade -y
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] apt-get upgrade failed."
    exit 1
fi

# Step 3: autoremove
echo "[$NOW] Running apt-get autoremove..."
sudo apt-get autoremove -y

# Step 4: clean
echo "[$NOW] Running apt-get clean..."
sudo apt-get clean

# Step 5: autoclean
echo "[$NOW] Running apt-get autoclean..."
sudo apt-get autoclean

echo "[$NOW] apt-get autoupdate completed successfully."
exit 0