#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$(dirname "$SCRIPT_DIR")/logs/update.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Detect if running in a terminal (not cron)
if [ -t 1 ]; then
    exec > >(tee -a "$LOG_FILE") 2>&1
else
    exec >> "$LOG_FILE" 2>&1
fi

echo
date
echo "############################"
log "Starting apt-get autoupdate..."

log "Running apt-get update..."
if ! sudo apt-get update; then
    log "[ERROR] apt-get update failed."
    exit 1
fi

log "Running apt-get upgrade..."
if ! sudo apt-get upgrade -y; then
    log "[ERROR] apt-get upgrade failed."
    exit 1
fi

log "Running apt-get autoremove..."
sudo apt-get autoremove -y

log "Running apt-get clean..."
sudo apt-get clean

log "Running apt-get autoclean..."
sudo apt-get autoclean

log "apt-get autoupdate completed successfully."