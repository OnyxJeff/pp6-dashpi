#!/usr/bin/env bash
# DashPi Desktop OS Setup – Pi 4B 4GB, Chromium Kiosk, WiFi Watchdog, Auto-Update
set -euo pipefail

echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter

# -------------------------------
# Config paths
# -------------------------------
USER_NAME=${SUDO_USER:-$USER}
HOME_DIR=$(eval echo "~$USER_NAME")
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

    # Create default in home if missing
    if [[ ! -f "$HOME_FILE" ]]; then
        echo -e "${CONFIG_FILES[$file]}" > "$HOME_FILE"
        echo "[+] Created default $file at $HOME_FILE"
    fi

    # Copy to system-wide config if missing or older
    if [[ ! -f "$SYSTEM_FILE" ]] || [[ "$HOME_FILE" -nt "$SYSTEM_FILE" ]]; then
        sudo cp "$HOME_FILE" "$SYSTEM_FILE"
        echo "[+] Updated system config: $SYSTEM_FILE"
    else
        echo "[*] Skipped $file — system-wide config is newer or identical"
    fi
done

# -------------------------------
# Copy scripts
# -------------------------------
REPO_DIR="$HOME_DIR/pp6-dashpi"
sudo mkdir -p /usr/local/dashpi/scripts
sudo cp -r "$REPO_DIR/scripts/"* /usr/local/dashpi/scripts/
sudo chown -R "$USER_NAME":"$USER_NAME" /usr/local/dashpi
sudo chown -R "$USER_NAME":"$USER_NAME" "$HOME_DIR/pp6-dashpi/logs" "$HOME_DIR/pp6-dashpi/backup_logs"

# -------------------------------
# Setup autostart for Chromium kiosk
# -------------------------------
AUTOSTART_DIR="$HOME_DIR/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
DESKTOP_FILE="$AUTOSTART_DIR/pp6-dashpi-kiosk.desktop"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=DashPi Kiosk
Exec=$HOME_DIR/pp6-dashpi/scripts/kiosk.sh
StartupNotify=false
Terminal=false
EOF

chmod +x "$DESKTOP_FILE"
echo "[+] Created autostart entry: $DESKTOP_FILE"

# -------------------------------
# Enable WiFi watchdog via systemd
# -------------------------------
sudo cp "$REPO_DIR/systemd/wifi-watchdog.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable wifi-watchdog.service
sudo systemctl start wifi-watchdog.service

# -------------------------------
# Final message
# -------------------------------
echo "[+] Setup complete!"
echo "    - Chromium kiosk will auto-launch on desktop login."
echo "    - System-wide configs are in $SYSTEM_CONFIG_DIR"
echo "    - Logs are in $HOME_DIR/pp6-dashpi/logs"
echo "    - WiFi watchdog running via systemd service."
