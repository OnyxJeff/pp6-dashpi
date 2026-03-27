#!/usr/bin/env bash
# DashPi Desktop Uninstall Script (Updated)
set -euo pipefail

USER_NAME=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$USER_NAME")
REPO_DIR="$USER_HOME/pp6-dashpi"
AUTOSTART_DIR="$USER_HOME/.config/autostart"

INSTALL_DIR="/usr/local/dashpi"

echo "[!] Stopping running services/scripts..."

# Kill running kiosk + wifi watchdog (both repo + installed paths)
pkill -f "$REPO_DIR/scripts/kiosk.sh" || true
pkill -f "$INSTALL_DIR/scripts/kiosk.sh" || true
pkill -f "wifi-check.sh" || true

# -------------------------------
# Remove autostart entry
# -------------------------------
KIOSK_DESKTOP="$AUTOSTART_DIR/dashpi-kiosk.desktop"

if [[ -f "$KIOSK_DESKTOP" ]]; then
    rm "$KIOSK_DESKTOP"
    echo "[+] Removed autostart entry: $KIOSK_DESKTOP"
else
    echo "[*] Autostart entry not found, skipping"
fi

# -------------------------------
# Stop & disable systemd services
# -------------------------------
echo "[!] Stopping systemd services..."

sudo systemctl stop wifi-watchdog.service 2>/dev/null || true
sudo systemctl disable wifi-watchdog.service 2>/dev/null || true

# (Only remove if you actually installed it via your repo)
if [[ -f /etc/systemd/system/wifi-watchdog.service ]]; then
    sudo rm /etc/systemd/system/wifi-watchdog.service
    echo "[+] Removed wifi-watchdog.service"
fi

sudo systemctl daemon-reload

# -------------------------------
# Remove installed DashPi files
# -------------------------------
if [[ -d "$INSTALL_DIR" ]]; then
    sudo rm -rf "$INSTALL_DIR"
    echo "[+] Removed install directory: $INSTALL_DIR"
fi

# -------------------------------
# Remove logs (repo-based)
# -------------------------------
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

# -------------------------------
# Optional: remove config files?
# -------------------------------
CONFIG_DIR="$REPO_DIR/config"

echo "[*] Config files preserved at: $CONFIG_DIR"
echo "    (Delete manually if you want a full reset)"

# -------------------------------
# Done
# -------------------------------
echo "[+] Uninstall complete!"
echo "    Repo remains at: $REPO_DIR"