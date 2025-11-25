#!/usr/bin/env bash
# DashPi Setup Script – Pi 4B 4GB, Chromium Kiosk, WiFi Watchdog, Auto-Update
set -e

echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y chromium x11-xserver-utils xdotool unclutter

# ------------------------------------
# Determine actual non-root user + home
# ------------------------------------
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

# ------------------------------------
# Path variables
# ------------------------------------
HOME_CONFIG_DIR="$REAL_HOME/pp6-dashpi/config"
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
LOG_DIR="$REAL_HOME/pp6-dashpi/logs"
BACKUP_LOG_DIR="$REAL_HOME/pp6-dashpi/backup_logs"
REPO_DIR="$REAL_HOME/pp6-dashpi"

# Ensure directories exist
mkdir -p "$HOME_CONFIG_DIR" "$LOG_DIR" "$BACKUP_LOG_DIR"
sudo mkdir -p "$SYSTEM_CONFIG_DIR"

# ------------------------------------
# Config files + defaults
# ------------------------------------
declare -A CONFIG_FILES=(
    ["dakboard-url.txt"]="https://dakboard.com/screen/your-dakboard-share-url"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_TARGET=\"8.8.8.8\""
    ["refresh-interval"]="15"
)

echo "[+] Syncing configs..."

for file in "${!CONFIG_FILES[@]}"; do
    HOME_FILE="$HOME_CONFIG_DIR/$file"
    SYSTEM_FILE="$SYSTEM_CONFIG_DIR/$file"

    # Create default config in user home if missing
    if [[ ! -f "$HOME_FILE" ]]; then
        printf "%b\n" "${CONFIG_FILES[$file]}" > "$HOME_FILE"
        echo "[+] Created default $file at $HOME_FILE"
    fi

    # Copy to system-wide if system config missing or older
    if [[ ! -f "$SYSTEM_FILE" ]] || [[ "$HOME_FILE" -nt "$SYSTEM_FILE" ]]; then
        sudo cp "$HOME_FILE" "$SYSTEM_FILE"
        echo "[+] Updated system config: $SYSTEM_FILE"
    else
        echo "[*] Skipped $file — system-wide config is newer or identical"
    fi
done

# ------------------------------------
# Copy scripts + services
# ------------------------------------
echo "[+] Installing scripts and services..."

sudo mkdir -p /usr/local/dashpi/scripts /etc/systemd/system

sudo cp -r "$REPO_DIR/scripts/"* /usr/local/dashpi/scripts/
sudo cp -r "$REPO_DIR/systemd/"* /etc/systemd/system/

# ------------------------------------
# Permissions
# ------------------------------------
echo "[+] Fixing permissions..."
sudo chown -R "$REAL_USER":""$REAL_USER" /usr/local/dashpi
sudo chown -R "$REAL_USER":"$REAL_USER" "$LOG_DIR" "$BACKUP_LOG_DIR"

# ------------------------------------
# Enable services
# ------------------------------------
echo "[+] Enabling systemd services..."
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable wifi-watchdog.service
sudo systemctl start kiosk.service
sudo systemctl start wifi-watchdog.service

# ------------------------------------
# Done
# ------------------------------------
echo "[+] Setup complete!"
echo "    - Chromium kiosk launches at boot using:"
echo "      $SYSTEM_CONFIG_DIR/dakboard-url.txt"
echo "    - WiFi watchdog service active"
echo "    - Logs: $LOG_DIR"
echo "    - Backup logs: $BACKUP_LOG_DIR"