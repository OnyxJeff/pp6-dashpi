#!/usr/bin/env bash
# DashPi Setup Script – Pi 4B 4GB, Chromium Kiosk, WiFi Watchdog, Auto-Update
set -e

echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter

# -------------------------------
# Config paths
# -------------------------------
HOME_CONFIG_DIR="$HOME/pp6-dashpi/config"
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
mkdir -p "$HOME_CONFIG_DIR" "$HOME/pp6-dashpi/logs" "$HOME/pp6-dashpi/backup_logs"
sudo mkdir -p "$SYSTEM_CONFIG_DIR"

declare -A CONFIG_FILES=(
    ["dakboard-url.txt"]="https://dakboard.com/screen/your-dakboard-share-url"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_TARGET=\"8.8.8.8\""
    ["refresh-interval"]="15"
)

# -------------------------------
# 1️⃣ Sync configs safely
# -------------------------------
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
# 2️⃣ Copy scripts and systemd services
# -------------------------------
REPO_DIR="$HOME/pp6-dashpi"

sudo mkdir -p /usr/local/dashpi/scripts /etc/systemd/system
sudo cp -r "$REPO_DIR/scripts/"* /usr/local/dashpi/scripts/
sudo cp -r "$REPO_DIR/systemd/"* /etc/systemd/system/

sudo chown -R "$USER":"$USER" /usr/local/dashpi
sudo chown -R "$USER":"$USER" "$HOME/pp6-dashpi/logs" "$HOME/pp6-dashpi/backup_logs"

# -------------------------------
# WiFi Watchdog Installation
# -------------------------------
echo "[+] Installing WiFi watchdog..."

# Install script
sudo install -m 755 "$REPO_DIR/scripts/wifi-check.sh" /usr/local/bin/wifi-check.sh

# Create systemd service
sudo tee /etc/systemd/system/wifi-check.service >/dev/null <<'EOF'
[Unit]
Description=WiFi Auto-Recovery Script

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wifi-check.sh
EOF

# Create systemd timer – runs every 5 minutes
sudo tee /etc/systemd/system/wifi-check.timer >/dev/null <<'EOF'
[Unit]
Description=Run WiFi Check Every 5 Minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=wifi-check.service

[Install]
WantedBy=timers.target
EOF

# -------------------------------
# 3️⃣ Enable systemd services
# -------------------------------
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable --now wifi-check.timer
sudo systemctl start kiosk.service

# -------------------------------
# 4️⃣ Final message
# -------------------------------
echo "[+] Setup complete!"
echo "    - Chromium kiosk will launch at boot using:"
echo "      $SYSTEM_CONFIG_DIR/dakboard-url.txt"
echo "    - WiFi watchdog service running every ${CONFIG_FILES["refresh-interval"]} minutes."
echo "    - Logs are stored in $HOME/pp6-dashpi/logs"