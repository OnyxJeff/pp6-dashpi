#!/usr/bin/env bash
# DashPi Uninstall Script
# Removes installed services, scripts, and system-wide configs
set -e

echo "----------------------------------------"
echo " DashPi Uninstall"
echo "----------------------------------------"
read -p "Are you sure you want to uninstall DashPi? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[-] Uninstall cancelled."
    exit 1
fi

echo "[+] Stopping systemd services..."
sudo systemctl stop kiosk.service 2>/dev/null || true
sudo systemctl stop wifi-watchdog.service 2>/dev/null || true

echo "[+] Disabling systemd services..."
sudo systemctl disable kiosk.service 2>/dev/null || true
sudo systemctl disable wifi-watchdog.service 2>/dev/null || true

echo "[+] Removing systemd service files..."
sudo rm -f /etc/systemd/system/kiosk.service
sudo rm -f /etc/systemd/system/wifi-watchdog.service
sudo systemctl daemon-reload

echo "[+] Removing system-wide DashPi directories..."
sudo rm -rf /usr/local/dashpi/scripts 2>/dev/null || true
sudo rm -rf /usr/local/dashpi/config 2>/dev/null || true
sudo rmdir /usr/local/dashpi 2>/dev/null || true

echo "[+] Leaving your repo folder intact:"
echo "    $HOME/pp6-dashpi/"
echo "    (configs, logs, backup_logs untouched)"

echo "[+] Uninstall complete!"
echo "    - Services removed"
echo "    - System-wide config removed"
echo "    - Kiosk and watchdog no longer run at boot"

echo "You're clean. Like the Pi was never dressed for kiosk duty in the first place."