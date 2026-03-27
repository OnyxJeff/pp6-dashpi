#!/usr/bin/env bash
# DashPi Desktop Setup Script – Updated for new kiosk + config system
set -euo pipefail

# -------------------------------
# Determine the actual user
# -------------------------------
USER_NAME=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$USER_NAME")
REPO_DIR="$USER_HOME/pp6-dashpi"
CONFIG_DIR="$REPO_DIR/config"
LOG_DIR="$REPO_DIR/logs"
BACKUP_LOG_DIR="$REPO_DIR/backup_logs"

# -------------------------------
# 0️⃣ Create required folders
# -------------------------------
mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$BACKUP_LOG_DIR"

# -------------------------------
# 1️⃣ Update and install packages
# -------------------------------
echo "[+] Updating system packages..."
sudo apt update

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter

# -------------------------------
# 2️⃣ Sync config files (NEW FORMAT)
# -------------------------------
declare -A CONFIG_FILES=(
    ["url.txt"]="https://example.com"
    ["refresh.txt"]="300"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_TARGET=\"8.8.8.8\""
)

for file in "${!CONFIG_FILES[@]}"; do
    CONFIG_FILE="$CONFIG_DIR/$file"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${CONFIG_FILES[$file]}" > "$CONFIG_FILE"
        echo "[+] Created default $file at $CONFIG_FILE"
    else
        echo "[*] Using existing $file at $CONFIG_FILE"
    fi
done

# -------------------------------
# 3️⃣ Fix permissions
# -------------------------------
sudo chown -R "$USER_NAME":"$USER_NAME" "$LOG_DIR" "$BACKUP_LOG_DIR"
chmod +x "$REPO_DIR/scripts/kiosk.sh"
chmod +x "$REPO_DIR/scripts/uninstall.sh"
chmod +x "$REPO_DIR/scripts/update.sh"
chmod +x "$REPO_DIR/scripts/wifi-check.sh"

# -------------------------------
# 4️⃣ Install scripts and systemd services
# -------------------------------
sudo mkdir -p /usr/local/dashpi/scripts /usr/local/dashpi/config /etc/systemd/system
sudo cp -r "$REPO_DIR/scripts/"* /usr/local/dashpi/scripts/
sudo cp -r "$REPO_DIR/config/"* /usr/local/dashpi/config/
sudo cp -r "$REPO_DIR/systemd/"* /etc/systemd/system/
sudo chown -R "$USER_NAME":"$USER_NAME" /usr/local/dashpi/*

# -------------------------------
# 5️⃣ Enable systemd services
# -------------------------------
sudo systemctl daemon-reload
sudo systemctl enable wifi-watchdog.service
sudo systemctl start wifi-watchdog.service

# -------------------------------
# 6️⃣ Autostart
# -------------------------------
AUTOSTART_DIR="$USER_HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
KIOSK_DESKTOP="$AUTOSTART_DIR/dashpi-kiosk.desktop"

cat > "$KIOSK_DESKTOP" <<EOL
[Desktop Entry]
Type=Application
Name=DashPi Kiosk
Exec=/usr/local/dashpi/scripts/kiosk.sh
StartupNotify=false
Terminal=false
X-GNOME-Autostart-enabled=true
EOL

echo "[+] Created autostart entry for kiosk: $KIOSK_DESKTOP"

# -------------------------------
# 7️⃣ Final message
# -------------------------------
echo "[+] Setup complete!"
echo "    - URL file: $CONFIG_DIR/url.txt"
echo "    - Refresh interval: $CONFIG_DIR/refresh.txt"
echo "    - WiFi watchdog active"
echo "    - Rebooting..."
sleep 5

sudo shutdown -r now