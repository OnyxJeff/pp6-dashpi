#!/usr/bin/env bash
# DashPi Setup Script – Pi 4B 4GB, Desktop OS, Chromium Kiosk, WiFi Watchdog
set -euo pipefail

echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter

# -------------------------------
# Config paths
# -------------------------------
DESKTOP_USER=${SUDO_USER:-$USER}
HOME_DIR=$(eval echo "~$DESKTOP_USER")
HOME_CONFIG_DIR="$HOME_DIR/pp6-dashpi/config"
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
mkdir -p "$HOME_CONFIG_DIR" "$HOME_DIR/pp6-dashpi/logs" "$HOME_DIR/pp6-dashpi/backup_logs"
sudo mkdir -p "$SYSTEM_CONFIG_DIR"

declare -A CONFIG_FILES=(
    ["dakboard-url.txt"]="https://dakboard.com/screen/your-dakboard-share-url"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_TARGET=\"8.8.8.8\""
    ["refresh-interval"]="15"
)

echo "[+] Syncing configs..."
for file in "${!CONFIG_FILES[@]}"; do
    HOME_FILE="$HOME_CONFIG_DIR/$file"
    SYSTEM_FILE="$SYSTEM_CONFIG_DIR/$file"

    if [[ ! -f "$HOME_FILE" ]]; then
        echo -e "${CONFIG_FILES[$file]}" > "$HOME_FILE"
        echo "[+] Created default $file at $HOME_FILE"
    fi

    if [[ ! -f "$SYSTEM_FILE" ]] || [[ "$HOME_FILE" -nt "$SYSTEM_FILE" ]]; then
        sudo cp "$HOME_FILE" "$SYSTEM_FILE"
        echo "[+] Copied $file to system-wide config ($SYSTEM_FILE)"
    else
        echo "[*] Skipped $file — system-wide config is newer or identical"
    fi
done

# -------------------------------
# Copy scripts and systemd service files
# -------------------------------
REPO_DIR="$HOME_DIR/pp6-dashpi"
sudo mkdir -p /usr/local/dashpi/scripts /etc/systemd/system
sudo cp -r "$REPO_DIR/scripts/"* /usr/local/dashpi/scripts/
sudo cp -r "$REPO_DIR/systemd/"* /etc/systemd/system/

sudo chown -R "$DESKTOP_USER":"$DESKTOP_USER" /usr/local/dashpi
sudo chown -R "$DESKTOP_USER":"$DESKTOP_USER" "$HOME_DIR/pp6-dashpi/logs" "$HOME_DIR/pp6-dashpi/backup_logs"

# -------------------------------
# Enable systemd services for desktop session
# -------------------------------
echo "[+] Enabling systemd services..."
sudo systemctl daemon-reload
sudo systemctl enable wifi-watchdog.service
sudo systemctl start wifi-watchdog.service

# Kiosk will run via kiosk.service after graphical.target (Desktop)
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

echo "[+] Setup complete!"
echo "    - Chromium kiosk will launch on HDMI after Desktop OS starts"
echo "    - WiFi watchdog running every ${CONFIG_FILES["refresh-interval"]} minutes"
echo "    - Logs stored in $HOME_DIR/pp6-dashpi/logs"
