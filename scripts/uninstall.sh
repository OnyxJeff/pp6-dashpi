#!/usr/bin/env bash
# DashPi Uninstall Script
set -euo pipefail

# -------------------------------
# Determine invoking user's home
# -------------------------------
USER_HOME=$(eval echo "~$SUDO_USER")
if [[ -z "$USER_HOME" ]]; then
    USER_HOME="$HOME"
fi

HOME_CONFIG_DIR="$USER_HOME/pp6-dashpi/config"
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
SCRIPT_DIR="/usr/local/dashpi/scripts"

# -------------------------------
# Confirm uninstall
# -------------------------------
read -r -p "Are you sure you want to uninstall DashPi? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[*] Aborted."
    exit 0
fi

echo "[+] Stopping systemd services..."
sudo systemctl stop kiosk.service || true
sudo systemctl stop wifi-watchdog.service || true
sudo systemctl disable kiosk.service || true
sudo systemctl disable wifi-watchdog.service || true

echo "[+] Removing systemd service files..."
sudo rm -f /etc/systemd/system/kiosk.service
sudo rm -f /etc/systemd/system/wifi-watchdog.service
sudo systemctl daemon-reload

echo "[+] Removing scripts and system-wide configs..."
sudo rm -rf "$SCRIPT_DIR" "$SYSTEM_CONFIG_DIR"

echo "[+] Removing user config files..."
rm -rf "$HOME_CONFIG_DIR"

echo "[+] DashPi uninstall complete!"
echo "    - User logs remain in $USER_HOME/pp6-dashpi/logs"
echo "    - Backup logs remain in $USER_HOME/pp6-dashpi/backup_logs"