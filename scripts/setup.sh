#!/usr/bin/env bash
# DashPi Desktop Setup Script – Pi 4B+, Chromium Kiosk with dynamic URL reload
set -euo pipefail

# -------------------------------
# 1️⃣ Variables
# -------------------------------
USER_NAME=${SUDO_USER:-$USER}            # original user if sudo
USER_HOME=$(eval echo "~$USER_NAME")
REPO_DIR="$USER_HOME/pp6-dashpi"

CONFIG_DIR="$REPO_DIR/config"
LOGS_DIR="$REPO_DIR/logs"
BACKUP_DIR="$REPO_DIR/backup_logs"
AUTOSTART_DIR="$USER_HOME/.config/autostart"

declare -A CONFIG_FILES=(
    ["dakboard-url.txt"]="https://dakboard.com/screen/your-dakboard-share-url"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_TARGET=\"8.8.8.8\""
    ["refresh-interval"]="15"
)

# -------------------------------
# 2️⃣ Ensure directories exist
# -------------------------------
mkdir -p "$CONFIG_DIR" "$LOGS_DIR" "$BACKUP_DIR" "$AUTOSTART_DIR"

# -------------------------------
# 3️⃣ Install packages
# -------------------------------
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter inotify-tools

# -------------------------------
# 4️⃣ Sync config files (only if missing)
# -------------------------------
for file in "${!CONFIG_FILES[@]}"; do
    TARGET="$CONFIG_DIR/$file"
    if [[ ! -f "$TARGET" ]]; then
        echo -e "${CONFIG_FILES[$file]}" > "$TARGET"
        echo "[+] Created default $file at $TARGET"
    else
        echo "[*] $file exists, skipping creation"
    fi
done

# -------------------------------
# 5️⃣ Install scripts
# -------------------------------
for script in kiosk.sh update.sh wifi-check.sh; do
    if [[ -f "$REPO_DIR/scripts/$script" ]]; then
        chmod +x "$REPO_DIR/scripts/$script"
        echo "[+] $script ready in $REPO_DIR/scripts/"
    else
        echo "[!] $script missing in repo scripts/"
    fi
done

# -------------------------------
# 6️⃣ Create .desktop for autostart
# -------------------------------
KIOSK_DESKTOP="$AUTOSTART_DIR/dashpi-kiosk.desktop"
cat > "$KIOSK_DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=DashPi Kiosk
Exec=$REPO_DIR/scripts/kiosk.sh
StartupNotify=false
Terminal=false
EOF

echo "[+] Created autostart entry at $KIOSK_DESKTOP"

# -------------------------------
# 7️⃣ Final message
# -------------------------------
echo "[+] Setup complete!"
echo "    - Chromium kiosk will auto-launch at desktop login using $CONFIG_DIR/dakboard-url.txt"
echo "    - WiFi watchdog and update scripts are ready in $REPO_DIR/scripts/"
echo "    - Logs stored in $LOGS_DIR and $BACKUP_DIR"
