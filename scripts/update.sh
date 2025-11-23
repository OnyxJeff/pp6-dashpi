#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi Update Script
# Updates packages and logs results
# -------------------------------------------------------------------

LOGFILE="$HOME/pp6-dashpi/logs/dashpi.log"
NOW=$(date "+%Y-%m-%d %H:%M:%S")

echo >> "$LOG_FILE"
date >> "$LOG_FILE"
echo "############################" >> "$LOG_FILE"
echo "[$NOW] Starting AutoUpdate..." >> "$LOG_FILE"

# Step 1: apt-get update
echo "[$NOW] Running Update..." >> "$LOG_FILE"
sudo apt-get update >> "$LOG_FILE" 2>&1
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] Update failed." >> "$LOG_FILE"
    exit 1
fi

# Step 2: fix broken dependencies
echo "[$NOW] Running Fix-Broken Install..." >> "$LOG_FILE"
sudo apt-get --fix-broken install -y >> "$LOG_FILE" 2>&1

# Step 3: upgrade packages
echo "[$NOW] Running Upgrade..." >> "$LOG_FILE"
sudo apt-get upgrade -y >> "$LOG_FILE" 2>&1
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] Upgrade failed." >> "$LOG_FILE"
    exit 1
fi

# Step 4: autoremove
echo "[$NOW] Running AutoRemove..." >> "$LOG_FILE"
sudo apt-get autoremove -y >> "$LOG_FILE" 2>&1

# Step 5: clean
echo "[$NOW] Running Clean..." >> "$LOG_FILE"
sudo apt-get clean >> "$LOG_FILE" 2>&1

# Step 6: autoclean
echo "[$NOW] Running AutoClean..." >> "$LOG_FILE"
sudo apt-get autoclean >> "$LOG_FILE" 2>&1

echo "[$NOW] Update completed successfully." >> "$LOG_FILE"
exit 0