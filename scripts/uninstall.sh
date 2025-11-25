#!/usr/bin/env bash
# DashPi Desktop Uninstall Script
set -euo pipefail

USER_NAME=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$USER_NAME")
REPO_DIR="$USER_HOME/pp6-dashpi"
AUTOSTART_DIR="$USER_HOME/.config/autostart"

echo "[!] Stopping running services/scripts..."
# Kill any running kiosk or wifi-check processes
pkill -f "$REPO_DIR/scripts/kiosk.sh" || true
pkill -f "$REPO_DIR/scripts/wifi-check.sh" || true

# Remove autostart entry
KIOSK_DESKTOP="$AUTOSTART_DIR/dashpi-kiosk.desktop"
if [[ -f "$KIOSK_DESKTOP" ]]; then
    rm "$KIOSK_DESKTOP"
    echo "[+] Removed autostart entry: $KIOSK_DESKTOP"
else
    echo "[*] Autostart entry not found, skipping"
fi

# Optionally remove logs
LOGS_DIR="$REPO_DIR/logs"
BACKUP_DIR="$REPO_DIR/backup_logs"

if [[ -d "$LOGS_DIR" ]]; then
    rm -rf "$LOGS_DIR"
    echo "[+] Removed logs directory: $LOGS_DIR"
fi

if [[ -d "$BACKUP_DIR" ]]; then
    rm -rf "$BACKUP_DIR"
    echo "[+] Removed backup logs directory: $BACKUP_DIR"
fi

echo "[+] Uninstall complete!"
echo "    Repository files in $REPO_DIR remain intact."
