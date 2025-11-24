#!/usr/bin/env bash
# DashPi Uninstall Script – Pi 4B 4GB
set -e

read -r -p "Are you sure you want to uninstall DashPi? (y/N): " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "[*] Uninstall cancelled."
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

echo "[+] Uninstall complete! Logs and backups remain in:"
echo "    $HOME/pp6-dashpi/logs"
echo "    $HOME/pp6-dashpi/backup_logs"