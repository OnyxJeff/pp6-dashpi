#!/usr/bin/env bash
# -------------------------------------------------------------------
# DashPi Setup Script (Chromium Kiosk)
# -------------------------------------------------------------------

set -e

echo "[+] Updating OS..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils unclutter matchbox-window-manager xdotool curl git wget

# ------------------ Create folders ------------------
echo "[+] Creating folders in /usr/local/dakpi..."
sudo mkdir -p /usr/local/dashpi/scripts
sudo mkdir -p /usr/local/dashpi/config
sudo mkdir -p /usr/local/dashpi/logs

# Copy local scripts/configs
echo "[+] Copying scripts and configs..."
sudo cp scripts/*.sh /usr/local/dashpi/scripts/
sudo cp config/* /usr/local/dashpi/config/
sudo chmod +x /usr/local/dashpi/scripts/*.sh

# ------------------ Setup systemd service for Chromium kiosk ------------------
echo "[+] Setting up Chromium kiosk service..."
cat <<EOF | sudo tee /etc/systemd/system/kiosk.service
[Unit]
Description=Chromium Kiosk
After=network.target

[Service]
User=pi
Environment=XAUTHORITY=/home/dashpi/.Xauthority
Environment=DISPLAY=:0
ExecStart=/usr/bin/chromium --noerrdialogs --kiosk --incognito \$(cat /usr/local/dashpi/config/dakboard-url.txt) --disable-translate --no-first-run
Restart=always

[Install]
WantedBy=graphical.target
EOF

# ------------------ Setup WiFi watchdog service ------------------
echo "[+] Installing WiFi watchdog service..."
sudo cp systemd/wifi-watchdog.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable wifi-watchdog.service

# ------------------ Create log folders in home ------------------
mkdir -p ~/pp6-dashpi/logs ~/pp6-dashpi/backup_logs

echo "[+] Setup complete! Rebooting to start kiosk..."
sudo reboot