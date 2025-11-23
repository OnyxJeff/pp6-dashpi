#!/usr/bin/env bash
# DashPi Setup Script for Raspberry Pi Zero 2W (Chromium kiosk)
set -e

echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils unclutter

echo "[+] Creating directories..."
sudo mkdir -p /usr/local/dashpi/config
mkdir -p ~/pp6-dashpi/logs ~/pp6-dashpi/backup_logs

# Default DakBoard URL
CONFIG_FILE="/usr/local/dashpi/config/dakboard-url.txt"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "https://dakboard.com/screen/your-dakboard-share-url" | sudo tee "$CONFIG_FILE"
fi

# Default WiFi watchdog config
WATCHDOG_CONFIG="/usr/local/dashpi/config/wifi-watchdog.conf"
if [[ ! -f "$WATCHDOG_CONFIG" ]]; then
    sudo tee "$WATCHDOG_CONFIG" > /dev/null <<EOL
INTERFACE="wlan0"
PING_TARGET="8.8.8.8"
EOL
fi

echo "[+] Copying scripts and systemd service files..."
sudo cp -r ~/pp6-dashpi/scripts/* /usr/local/dashpi/scripts/
sudo cp -r ~/pp6-dashpi/systemd/* /etc/systemd/system/

echo "[+] Enabling systemd services..."
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable wifi-watchdog.service

echo "[+] Setup complete. Rebooting..."
sudo reboot