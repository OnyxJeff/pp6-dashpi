#!/usr/bin/env bash
# DashPi Desktop Setup Script – Pi 4B 4GB, Chromium Kiosk, WiFi Watchdog, Auto-Update
# Works with existing scripts and config folder in repo
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
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter

# -------------------------------
# 2️⃣ Sync config files if missing
# -------------------------------
declare -A CONFIG_FILES=(
    ["dakboard-url.txt"]="https://dakboard.com/screen/your-dakboard-share-url"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_TARGET=\"8.8.8.8\""
    ["refresh-interval"]="15"
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
# 3️⃣ Fix permissions for logs
# -------------------------------
sudo chown -R "$USER_NAME":"$USER_NAME" "$LOG_DIR" "$BACKUP_LOG_DIR"

# -------------------------------
# 4️⃣ Install scripts and systemd services
# -------------------------------
sudo mkdir -p /usr/local/dashpi/scripts /etc/systemd/system
sudo cp -r "$REPO_DIR/scripts/"* /usr/local/dashpi/scripts/
sudo cp -r "$REPO_DIR/systemd/"* /etc/systemd/system/
sudo chown -R "$USER_NAME":"$USER_NAME" /usr/local/dashpi

# -------------------------------
# 5️⃣ Enable systemd services
# -------------------------------
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable wifi-watchdog.service
sudo systemctl start kiosk.service
sudo systemctl start wifi-watchdog.service

# -------------------------------
# 6️⃣ Set up autostart for kiosk in Desktop OS
# -------------------------------
AUTOSTART_DIR="$USER_HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
KIOSK_DESKTOP="$AUTOSTART_DIR/dashpi-kiosk.desktop"

cat > "$KIOSK_DESKTOP" <<EOL
[Desktop Entry]
Type=Application
Name=DashPi Kiosk
Exec=$REPO_DIR/scripts/kiosk.sh
StartupNotify=false
Terminal=false
X-GNOME-Autostart-enabled=true
EOL

echo "[+] Created autostart entry for kiosk: $KIOSK_DESKTOP"

# -------------------------------
# 7️⃣ Reset GNOME keyring to blank
# -------------------------------
KEYRING_DIR="$USER_HOME/.local/share/keyrings"
LOGIN_KEYRING="$KEYRING_DIR/login.keyring"

mkdir -p "$KEYRING_DIR"
if [[ -f "$LOGIN_KEYRING" ]]; then
    cp "$LOGIN_KEYRING" "$LOGIN_KEYRING.bak_$(date +%F_%T)"
    echo "[*] Backup of old keyring saved as $LOGIN_KEYRING.bak_$(date +%F_%T)"
    rm -f "$LOGIN_KEYRING"
fi

touch "$LOGIN_KEYRING"
chmod 600 "$LOGIN_KEYRING"
echo "[+] Default keyring reset to blank — no password prompt at login."

# -------------------------------
# 8️⃣ Set default HDMI resolution to 1920x1080
# -------------------------------
CONFIG_TXT="/boot/config.txt"
if ! grep -q "hdmi_group=1" "$CONFIG_TXT"; then
    echo "[+] Setting default HDMI resolution to 1920x1080..."
    echo "" | sudo tee -a "$CONFIG_TXT" >/dev/null
    echo "# DashPi default 1080p HDMI" | sudo tee -a "$CONFIG_TXT" >/dev/null
    echo "hdmi_group=1" | sudo tee -a "$CONFIG_TXT" >/dev/null
    echo "hdmi_mode=16" | sudo tee -a "$CONFIG_TXT" >/dev/null
else
    echo "[*] HDMI resolution settings already present — skipping."
fi

# -------------------------------
# 9️⃣ Final message
# -------------------------------
echo "[+] Setup complete!"
echo "    - Chromium kiosk will launch at boot using URL from:"
echo "      $CONFIG_DIR/dakboard-url.txt"
echo "    - WiFi watchdog service running by systemd."
echo "    - Logs are stored in $LOG_DIR"
echo "    - Autostart configured for Desktop session."
