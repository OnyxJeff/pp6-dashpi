#!/usr/bin/env bash
# DashPi Uninstall Script
set -e

# Determine real non-root user + home
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

DASHSYS_DIR="/usr/local/dashpi"
SYSTEMD_DIR="/etc/systemd/system"

echo "[!] This will remove DashPi system files and services."
echo "    Your repo at $REAL_HOME/pp6-dashpi will NOT be touched."
read -r -p "Are you sure you want to uninstall DashPi? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[*] Uninstall cancelled."
    exit 0
fi

echo "[+] Stopping services..."
sudo systemctl stop kiosk.service 2>/dev/null || true
sudo systemctl stop wifi-watchdog.service 2>/dev/null || true

echo "[+] Disabling services..."
sudo systemctl disable kiosk.service 2>/dev/null || true
sudo systemctl disable wifi-watchdog.service 2>/dev/null || true

echo "[+] Removing systemd service files..."
sudo rm -f "$SYSTEMD_DIR/kiosk.service"
sudo rm -f "$SYSTEMD_DIR/wifi-watchdog.service"

echo "[+] Removing DashPi system directory: $DASHSYS_DIR"
sudo rm -rf "$DASHSYS_DIR"

echo "[+] Reloading systemd..."
sudo systemctl daemon-reload

echo "[+] DashPi uninstalled."
echo "    Your repository and logs in $REAL_HOME/pp6-dashpi remain untouched."