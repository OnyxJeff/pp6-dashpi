#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi Setup Script (v0.0.0)
# Fully prepares Pi Zero 2W for DakBoard kiosk + WiFi watchdog
# -------------------------------------------------------------------

set -e

echo "[+] Updating OS packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required dependencies..."
sudo apt install -y xorg xinit matchbox-window-manager xdotool curl git wget

# ------------------ Install kweb ------------------
KWEB_VERSION="1.7.9.8"
KWEB_URL="http://steinerdatenbank.de/software/kweb-${KWEB_VERSION}.tar.gz"

echo "[+] Downloading kweb v$KWEB_VERSION..."
wget -O kweb-${KWEB_VERSION}.tar.gz "$KWEB_URL"

if [ ! -f kweb-${KWEB_VERSION}.tar.gz ]; then
    echo "[ERROR] kweb download failed. Check your network or URL."
    exit 1
fi

echo "[+] Extracting and installing kweb..."
tar -xzf kweb-${KWEB_VERSION}.tar.gz
cd kweb-${KWEB_VERSION} || { echo "[ERROR] Extraction failed"; exit 1; }
sudo ./install.sh
cd ..
rm -rf kweb-${KWEB_VERSION} kweb-${KWEB_VERSION}.tar.gz

# ------------------ Setup folders ------------------
echo "[+] Creating folders in /usr/local/dashpi..."
sudo mkdir -p /usr/local/dashpi/scripts
sudo mkdir -p /usr/local/dashpi/config
sudo mkdir -p /usr/local/dashpi/logs

# ------------------ Copy scripts and configs ------------------
echo "[+] Copying scripts and config templates..."
sudo cp scripts/*.sh /usr/local/dashpi/scripts/
sudo cp config/* /usr/local/dashpi/config/
sudo chmod +x /usr/local/dashpi/scripts/*.sh

# ------------------ Setup systemd services ------------------
echo "[+] Installing systemd services..."
sudo cp systemd/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable wifi-watchdog.service

# ------------------ Optional log setup ------------------
mkdir -p ~/pp0-dashpi/logs ~/pp6-dashpi/backup_logs

echo "[+] Setup complete!"
echo "Rebooting the Pi to start kiosk and watchdog services..."
sudo reboot