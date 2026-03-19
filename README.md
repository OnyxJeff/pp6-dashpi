# pp6-dashpi

![Build Status](https://github.com/OnyxJeff/pp6-dashpi/actions/workflows/build.yml/badge.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2026.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![GitHub release](https://img.shields.io/github/v/release/OnyxJeff/pp6-dashpi)
![Issues](https://img.shields.io/github/issues/OnyxJeff/pp6-dashpi)

**DashPi** turns a Raspberry Pi 4b - 4GB into a tiny, stubbornly reliable fullscreen dashboard device. It does exactly one job — displaying your dashboard — and refuses to complain about it.

---

## 📁 Repo Structure

```text
pp6-dashpi/
├── .github/workflows/      # CI for YAML validation
├── backup_logs/            # Archived logs from update scripts
├── config/                 # Configuration files (DakBoard URL, refresh interval, WiFi watchdog)
├── logs/                   # Most recent runtime/update logs
├── scripts/                # Setup, kiosk launcher, WiFi watchdog, updater
├── systemd/                # Systemd service files for kiosk and WiFi watchdog
└── README.md               # You're reading it!
```

---

## 🧰 Services Included
- Chromium Fullscreen Kiosk
  - Boots straight into your DakBoard URL (or any dashboard) in fullscreen.
  - Auto-restarts via systemd if it crashes.
- WiFi Watchdog
  - Checks connectivity and restarts ```wlan0``` if your network becomes unreachable.
- Auto-Updater Script (optional)
  - Updates OS packages and logs results weekly/monthly.

---

## 🖥️ Installation
- Install Git
```bash
sudo apt install git -y
```

- Download repo
```bash
cd
git clone https://github.com/OnyxJeff/pp6-dashpi.git
```

---

## ⚠️ Updating the OS

- Update and Upgrade the System via script:
```bash
cd ~/pp2-mimir/scripts
chmod +x apt-get-autoupdater.sh
sudo ./apt-get-autoupdater.sh
```
It's going to look like this froze, but just let it go.

- Start CronJob (optional but recommended if doing headless/always on installation)
```bash
sudo crontab -e
```

  - add the following to the bottom of the document:
  ```bash
  # OS-Auto-Updater
    00 01 * * 0 bash $HOME/pp2-mimir/scripts/apt-get-autoupdater.sh
      # execute automatic update script and log every sunday at 01:00 am
    50 00 1 * * /bin/bash -c 'cp $HOME/pp2-mimir/logs/apt-get-autoupdater.log $HOME/pp2-mimir/backup_logs/apt-get-autoupdater-$(date +\%Y\%m\%d).log'
      # saves monthly version of "apt-get-autoupdater.log" on the 1st of every month at 00:50 am
    51 00 1 * * rm -f $HOME/pp2-mimir/logs/apt-get-autoupdater.log
      # deletes old weekly log on the 1st of every month at 00:51 am
  ```

### 🚦 Optional: Auto Updates & Log Rotation
- Enable update script via cron
```bash
sudo crontab -e
```

- Add:
```bash
# OS-Auto-Updater
  00 01 * * 0 bash $HOME/pp6-dashpi/scripts/update.sh
    # Runs update script at 1am every Sunday
  50 00 1 * * cp $HOME/pp6-dashpi/logs/dashpi.log $HOME/pp6-dashpi/backup_logs/dashpi-$(date +\%Y\%m\%d).log
    # Moves weekly update log to "backup_logs" folder on the 1st of the Month at 12:50am
  51 00 1 * * rm -f $HOME/pp6-dashpi/logs/dashpi.log
    # Deletes weekly log from "logs" folder after moving it to "backup_logs" on the 1st of the Month at 12:51am
```

- Enable WiFi watchdog
```bash
# WiFi-Check (every 15 minutes)
  */15 * * * * bash $HOME/pp6-dashpi/scripts/wifi-check.sh
```
> Running every 15 minutes balances reliability and Pi Zero 2W performance.

---

## 🛠️ Configuration
### ➤ Installation

- On the desktop (using RPi connect or VNC) manually change the resolution to 1080p (or your displays native resolution)

- Run setup (installs Chromium, kiosk desktop service, WiFi watchdog)
```bash
cd ~/pp6-dashpi/scripts
chmod +x setup.sh
sudo ./setup.sh
```
> This runs scripts/configs, sets up systemd services for WiFi watchdog, reboots the device, and starts the kiosk automatically.

### 🧹 Uninstalling
```bash
cd ~/pp6-dashpi/scripts
chmod +x uninstall.sh
sudo ./uninstall.sh
```

- This will remove:
  - systemd services
  - installed scripts and configs
  - kiosk auto-start
  - WiFi watchdog monitor

### ➤ DakBoard URL

- Edit:
```bash
nano $HOME/pp6-dashpi/config/dakboard-url.txt.example
```

Paste in your private DakBoard share URL and save as ```dakboard-url.txt```

### ➤ Refresh Interval

- Edit:
```bash
nano $HOME/pp6-dashpi/config/refresh-interval
```

Specify minutes (e.g., 15).

### ➤ WiFi Watchdog Settings

- Edit:
```bash
nano $HOME/pp6-dashpi/config/wifi-watchdog.conf
```

Set interface name and ping target.

---

## Acknowledgements

This project uses or is inspired by:
- [Chromium](https://www.raspberrypi.com/software/) – Fullscreen kiosk browser
- [DAKboard](https://dakboard.com/site) – Dashboard service displayed on the kiosk
- [Raspberry Pi Forums](https://forums.raspberrypi.com/viewtopic.php?t=40860) – Community kiosk tips

---

📬 Maintained By
Jeff M. • [@OnyxJeff](https://www.github.com/onyxjeff)