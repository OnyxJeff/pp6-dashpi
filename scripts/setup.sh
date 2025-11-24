#!/usr/bin/env bash
# DashPi Full Setup Script
# Raspberry Pi Zero 2W – Chromium Kiosk, WiFi Watchdog, Auto-Update
set -e

echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing required packages..."
sudo apt install -y \
    chromium \
    xorg xinit \
    x11-xserver-utils \
    xdotool \
    unclutter

# ------------------------------------
# Paths
# ------------------------------------
HOME_USER="${SUDO_USER:-$USER}"
USER_HOME_DIR="$(eval echo "~$HOME_USER")"
REPO_DIR="$USER_HOME_DIR/pp6-dashpi"

HOME_CONFIG_DIR="$REPO_DIR/config"
SYSTEM_CONFIG_DIR="/usr/local/dashpi/config"
SYSTEM_SCRIPTS_DIR="/usr/local/dashpi/scripts"

LOG_DIR="$REPO_DIR/logs"
BACKUP_LOG_DIR="$REPO_DIR/backup_logs"

echo "[+] Creating directories..."

mkdir -p "$HOME_CONFIG_DIR"
mkdir -p "$LOG_DIR" "$BACKUP_LOG_DIR"

sudo mkdir -p "$SYSTEM_CONFIG_DIR"
sudo mkdir -p "$SYSTEM_SCRIPTS_DIR"
sudo mkdir -p /etc/systemd/system

# ------------------------------------
# Config file defaults
# ------------------------------------
declare -A CONFIG_FILES=(
    ["dakboard-url.txt"]="https://dakboard.com/screen/your-dakboard-share-url"
    ["wifi-watchdog.conf"]="INTERFACE=\"wlan0\"\nPING_TARGET=\"1.1.1.1\"\nPING_COUNT=2"
    ["refresh-interval"]="15"
)

echo "[+] Syncing configuration files..."

for file in "${!CONFIG_FILES[@]}"; do
    HOME_FILE="$HOME_CONFIG_DIR/$file"
    SYSTEM_FILE="$SYSTEM_CONFIG_DIR/$file"

    # Create default in $HOME if missing
    if [[ ! -f "$HOME_FILE" ]]; then
        echo -e "${CONFIG_FILES[$file]}" > "$HOME_FILE"
        echo "[+] Created default $file at $HOME_FILE"
    fi

    # Copy into system-wide if missing or older
    if [[ ! -f "$SYSTEM_FILE" ]] || [[ "$HOME_FILE" -nt "$SYSTEM_FILE" ]]; then
        sudo cp "$HOME_FILE" "$SYSTEM_FILE"
        echo "[+] Copied $file → $SYSTEM_FILE"
    else
        echo "[*] Skipped $file — system config is newer or identical"
    fi
done

# ------------------------------------
# Copy scripts + service files
# ------------------------------------
echo "[+] Copying scripts and systemd service files..."

sudo cp "$REPO_DIR/scripts/"*.sh "$SYSTEM_SCRIPTS_DIR/"
sudo cp "$REPO_DIR/systemd/"*.service /etc/systemd/system/

sudo chmod -R 755 "$SYSTEM_SCRIPTS_DIR"

# ------------------------------------
# Permissions (ensure dashpi owns runtime dirs)
# ------------------------------------
if id "dashpi" &>/dev/null; then
    echo "[+] Fixing permissions for user 'dashpi'..."

    sudo chown -R dashpi:dashpi "$LOG_DIR"
    sudo chown -R dashpi:dashpi "$BACKUP_LOG_DIR"
    sudo chown -R dashpi:dashpi "$SYSTEM_CONFIG_DIR"
    sudo chown -R dashpi:dashpi "$SYSTEM_SCRIPTS_DIR"
else
    echo "[*] User 'dashpi' does not exist — skipping ownership adjustments."
fi

# ------------------------------------
# Enable services
# ------------------------------------
echo "[+] Enabling and starting systemd services..."

sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl enable wifi-watchdog.service
sudo systemctl restart kiosk.service
sudo systemctl restart wifi-watchdog.service

# ------------------------------------
# Final
# ------------------------------------
echo ""
echo "-------------------------------------------------------------"
echo "[✓] DashPi Setup Complete!"
echo "  ● System configs:     $SYSTEM_CONFIG_DIR"
echo "  ● Repo logs:          $LOG_DIR"
echo "  ● Repo backup logs:   $BACKUP_LOG_DIR"
echo "  ● Scripts installed:  $SYSTEM_SCRIPTS_DIR"
echo "-------------------------------------------------------------"
echo "Chromium will launch at boot using DakBoard URL:"
echo "  → $SYSTEM_CONFIG_DIR/dakboard-url.txt"
echo "-------------------------------------------------------------"
echo ""