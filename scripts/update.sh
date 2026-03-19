#!/bin/bash
#
# run
# crontab -e
# OS-Auto-Updater
    # 00 01 * * 0 bash /home/potentpi6/pp6-dashpi/scripts/apt-get-autoupdater.sh
        # execute automatic update script and log every sunday at 01:00 am
    # 50 00 1 * * /bin/bash -c 'cp /home/potentpi6/pp6-dashpi/logs/apt-get-autoupdater.log /home/potentpi6/pp6-dashpi/backup_logs/apt-get-autoupdater-$(date +\%Y\%m\%d).log'
        # saves monthly version of "apt-get-autoupdater.log" on the 1st of every month at 00:50 am
    # 51 00 1 * * rm -f /home/potentpi6/pp6-dashpi/logs/apt-get-autoupdater.log
        # deletes old weekly log on the 1st of every month at 00:51 am
# apt-get update script for cron automatization
# This script is released under the BSD 3-Clause License.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$(dirname "$SCRIPT_DIR")/logs/apt-get-autoupdater.log"
NOW=$(date "+%Y-%m-%d %H:%M:%S")

echo >> "$LOG_FILE"
date >> "$LOG_FILE"
echo "############################" >> "$LOG_FILE"
echo "[$NOW] Starting apt-get autoupdate..." >> "$LOG_FILE"

# Step 1: apt-get update
echo "[$NOW] Running apt-get update..." >> "$LOG_FILE"
sudo apt-get update >> "$LOG_FILE" 2>&1
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] apt-get update failed." >> "$LOG_FILE"
    exit 1
fi

# Step 2: fix broken dependencies
echo "[$NOW] Running apt-get --fix-broken install..." >> "$LOG_FILE"
sudo apt-get --fix-broken install -y >> "$LOG_FILE" 2>&1

# Step 3: upgrade packages
echo "[$NOW] Running apt-get upgrade..." >> "$LOG_FILE"
sudo apt-get upgrade -y >> "$LOG_FILE" 2>&1
if [[ $? -ne 0 ]]; then
    echo "[$NOW] [ERROR] apt-get upgrade failed." >> "$LOG_FILE"
    exit 1
fi

# Step 4: autoremove
echo "[$NOW] Running apt-get autoremove..." >> "$LOG_FILE"
sudo apt-get autoremove -y >> "$LOG_FILE" 2>&1

# Step 5: clean
echo "[$NOW] Running apt-get clean..." >> "$LOG_FILE"
sudo apt-get clean >> "$LOG_FILE" 2>&1

# Step 6: autoclean
echo "[$NOW] Running apt-get autoclean..." >> "$LOG_FILE"
sudo apt-get autoclean >> "$LOG_FILE" 2>&1

echo "[$NOW] apt-get autoupdate completed successfully." >> "$LOG_FILE"
exit 0