#!/usr/bin/env bash
# DashPi Uninstall Script – Desktop OS
set -euo pipefail

echo "[!] This will remove DashPi scripts, configs, autostart, and cronjobs."
read -r -p "Are you sure you want to uninstall DashPi? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[*] Uninstall canceled."
    exit 0
fi

# -------------------------------
# Remove scripts
# -------------------------------
HOME_DIR="$HOME/pp6-dashpi"
if [[ -d "$HOME_DIR/scripts" ]]; then
    rm -rf "$HOME_DIR/scripts"
    echo "[+] Removed scripts folder."
fi

# -------------------------------
# Remove configs
# -------------------------------
if [[ -d "$HOME_DIR/config" ]]; then
    rm -rf "$HOME_DIR/config"
    echo "[+] Removed config folder."
fi

# -------------------------------
# Remove logs
# -------------------------------
if [[ -d "$HOME_DIR/logs" ]]; then
    rm -rf "$HOME_DIR/logs"
    echo "[+] Removed logs folder."
fi

if [[ -d "$HOME_DIR/backup_logs" ]]; then
    rm -rf "$HOME_DIR/backup_logs"
    echo "[+] Removed backup_logs folder."
fi

# -------------------------------
# Remove autostart
# -------------------------------
AUTOSTART_DIR="$HOME/.config/autostart"
KIOSK_DESKTOP_FILE="$AUTOSTART_DIR/pp6-dashpi-kiosk.desktop"
if [[ -f "$KIOSK_DESKTOP_FILE" ]]; then
    rm -f "$KIOSK_DESKTOP_FILE"
    echo "[+] Removed autostart entry."
fi

# -------------------------------
# Remove cronjob for WiFi watchdog
# -------------------------------
(crontab -l 2>/dev/null || true) | grep -v 'wifi-check.sh' | crontab -
echo "[+] Removed WiFi watchdog cronjob."

echo "[+] DashPi has been uninstalled from Desktop OS."
