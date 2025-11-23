#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi Uninstall Script
# Removes DashPi kiosk, WiFi watchdog, scripts, configs, and logs
# -------------------------------------------------------------------

set -e

echo "[+] Stopping DashPi services..."
sudo systemctl stop kiosk.service || true
sudo systemctl stop wifi-watchdog.service || true

echo "[+] Disabling DashPi services..."
sudo systemctl disable kiosk.service || true
sudo systemctl disable wifi-watchdog.service || true

echo "[+] Removing systemd service files..."
sudo rm -f /etc/systemd/system/kiosk.service
sudo rm -f /etc/systemd/system/wifi-watchdog.service
sudo systemctl daemon-reload

echo "[+] Removing DashPi scripts, configs, and logs..."
sudo rm -rf /usr/local/dashpi
rm -rf ~/pp6-dashpi/logs ~/pp6-dashpi/backup_logs

echo "[+] DashPi has been completely removed."