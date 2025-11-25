#!/usr/bin/env bash
# DashPi Full Setup Script – Pi 4B 4GB, Chromium Kiosk, WiFi Watchdog, Auto-Update
set -euo pipefail

# -------------------------------
# Determine home of invoking user
# -------------------------------
USER_HOME=$(eval echo "~$SUDO_USER")
if [[ -z "$USER_HOME" ]]; then
    USER_HOME="$HOME"
fi

echo "[+] Using user home: $USER_HOME"

# -------------------------------
# Update & install required packages
# -------------------------------
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter

# -------------------------------
# Config paths
# -------------------------------
HOME_CONFIG_DIR="$USER_HOME/pp6-dashpi/config"
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
LOG_DIR="$USER_HOME/pp6-dashpi/logs"
BACKUP_DIR="$USER_HOME/pp6-dashpi/backup_logs"

mkdir -p "$HOME_CONFIG_DIR" "$LOG_DIR" "$BACKUP_DIR"
sudo mkdir -p "$SYSTEM_CONFIG_DIR"

# -------------------------------
# Default config contents
# -------------------------------
declare -A CONFIG_FILES=(
    ["dakboard-url.txt"]="https://dakboard.com/screen/your-dakboard-share-url"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_HOST=\"8.8.8.8\""
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
        echo "[+] Updated system config: $SYSTEM_FILE"
    else
        echo "[*] Skipped $file — system-wide config is newer or identical"
    fi
done

# -------------------------------
# Copy scripts and systemd service files
# -------------------------------
REPO_DIR="$USER_HOME/pp6-dashpi"

sudo mkdir -p /usr/local/dashpi/scripts /etc/systemd/system
sudo cp -r "$REPO_DIR/scripts/"* /usr/local/dashpi/scripts/
sudo cp -r "$REPO_DIR/systemd/"* /etc/systemd/system/

# -------------------------------
# Fix permissions
# -------------------------------
sudo chown -R "$SUDO_USER":"$SUDO_USER" /usr/local/dashpi
sudo chown -R "$SUDO_USER":"$SUDO_USER" "$LOG_DIR" "$BACKUP_DIR"

# -------------------------------
# Enable systemd services
# -------------------------------
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable wifi-watchdog.service
sudo systemctl start kiosk.service
sudo systemctl start wifi-watchdog.service

# -------------------------------
# Final message
# -------------------------------
echo "[+] Setup complete!"
echo "    - Chromium kiosk will launch at boot using:"
echo "      $SYSTEM_CONFIG_DIR/dakboard-url.txt"
echo "    - WiFi watchdog service running every ${CONFIG_FILES["refresh-interval"]} minutes."
echo "    - Logs are stored in $LOG_DIR"
echo "    - Backup logs are stored in $BACKUP_DIR"
