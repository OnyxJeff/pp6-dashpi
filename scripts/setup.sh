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
sudo systemctl enable wifi-watchdog.service
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

# ---------------------------------------------------------
# 🗝️ Reset GNOME Keyring properly (make login keyring blank)
# ---------------------------------------------------------
echo "[*] Resetting GNOME Keyring to a passwordless login keyring..."

KEYRING_DIR="$USER_HOME/.local/share/keyrings"
mkdir -p "$KEYRING_DIR"

# Kill any existing keyring daemons so they don’t fight us
pkill -9 gnome-keyring-daemon 2>/dev/null || true

# Remove old keyring databases that trigger prompts
rm -f "$KEYRING_DIR"/*.keyring
rm -f "$KEYRING_DIR"/*.kdbx

# Create a new empty passwordless keyring named "login"
printf "" | sudo -u "$USER_NAME" secret-tool store --label="login" type login 2>/dev/null || true

# Make "login" the default keyring
cat > "$KEYRING_DIR/default" <<EOF
[Default]
Default=login
EOF

chmod 600 "$KEYRING_DIR/default"

echo "[+] GNOME keyring successfully reset to blank. No more password prompts."

# -------------------------------
# 7️⃣ Final message
# -------------------------------
echo "[+] Setup complete!"
echo "    - Chromium kiosk will launch at boot using URL from:"
echo "      $CONFIG_DIR/dakboard-url.txt"
echo "    - WiFi watchdog service running by systemd."
echo "    - Logs are stored in $LOG_DIR"
echo "    - Autostart configured for Desktop session."
echo "    - rebooting device to autostart kiosk-mode."
sudo shutdown -r now
