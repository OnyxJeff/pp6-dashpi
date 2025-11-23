#!/usr/bin/env bash
# DashPi Auto-Updater
# Updates OS packages and logs results

set -e

# -------------------------------
# Paths
# -------------------------------
LOG_DIR="$HOME/pp6-dashpi/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/dashpi.log"
NOW=$(date '+%Y-%m-%d %H:%M:%S')

# -------------------------------
# Logging function
# -------------------------------
log() {
    echo "[$NOW] $*" | tee -a "$LOG_FILE"
}

log "Starting DashPi update..."

# -------------------------------
# Update system
# -------------------------------
if ! sudo apt-get update | tee -a "$LOG_FILE"; then
    log "WARNING: apt-get update failed"
fi

if ! sudo apt-get --fix-broken install -y | tee -a "$LOG_FILE"; then
    log "WARNING: fix-broken install failed"
fi

if ! sudo apt-get upgrade -y | tee -a "$LOG_FILE"; then
    log "WARNING: apt-get upgrade failed"
fi

log "Running autoremove..."
sudo apt-get autoremove -y | tee -a "$LOG_FILE"

log "Cleaning package cache..."
sudo apt-get clean | tee -a "$LOG_FILE"
sudo apt-get autoclean | tee -a "$LOG_FILE"

log "Update complete."