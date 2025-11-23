#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi Update Script
# Updates packages and logs results
# -------------------------------------------------------------------

LOGFILE="$HOME/pp6-dashpi/logs/dashpi.log"
NOW=$(date "+%Y-%m-%d %H:%M:%S")

echo >> "$LOGFILE"
date >> "$LOGFILE"
echo "############################" >> "$LOGFILE"
echo "[$NOW] Starting AutoUpdate..." >> "$LOGFILE"

# Step 1: apt-get update
echo "[$NOW] Running Update..." >> "$LOGFILE"
sudo apt-get update >> "$LOGFILE" 2>&1
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] Update failed." >> "$LOGFILE"
    exit 1
fi

# Step 2: fix broken dependencies
echo "[$NOW] Running Fix-Broken Install..." >> "$LOGFILE"
sudo apt-get --fix-broken install -y >> "$LOGFILE" 2>&1

# Step 3: upgrade packages
echo "[$NOW] Running Upgrade..." >> "$LOGFILE"
sudo apt-get upgrade -y >> "$LOGFILE" 2>&1
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] Upgrade failed." >> "$LOGFILE"
    exit 1
fi

# Step 4: autoremove
echo "[$NOW] Running AutoRemove..." >> "$LOGFILE"
sudo apt-get autoremove -y >> "$LOGFILE" 2>&1

# Step 5: clean
echo "[$NOW] Running Clean..." >> "$LOGFILE"
sudo apt-get clean >> "$LOGFILE" 2>&1

# Step 6: autoclean
echo "[$NOW] Running AutoClean..." >> "$LOGFILE"
sudo apt-get autoclean >> "$LOGFILE" 2>&1

echo "[$NOW] Update completed successfully." >> "$LOGFILE"
exit 0