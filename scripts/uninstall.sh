#!/usr/bin/env bash
# DashPi Uninstall Script – removes kiosk and watchdog
set -euo pipefail


USER_HOME=$(eval echo "~$SUDO_USER")
# shellcheck disable=SC2034
USER_NAME=${SUDO_USER:-$USER}

read -r -p "Are you sure you want to uninstall DashPi? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[*] Aborted."
    exit 0
fi

echo "[+] Stopping services..."
sudo systemctl stop kiosk.service || true
sudo systemctl stop wifi-watchdog.service || true

echo "[+] Disabling services..."
sudo systemctl disable kiosk.service || true
sudo systemctl disable wifi-watchdog.service || true

echo "[+] Removing systemd units..."
sudo rm -f /etc/systemd/system/kiosk.service
sudo rm -f /etc/systemd/system/wifi-watchdog.service
sudo systemctl daemon-reload

echo "[+] Removing system-wide files..."
sudo rm -rf /usr/local/dashpi

echo "[+] Removing user config files..."
rm -rf "$USER_HOME/pp6-dashpi"

echo "[+] DashPi uninstalled."
