# pp6-dashpi

![Build Status](https://github.com/OnyxJeff/pp6-dashpi/actions/workflows/build.yml/badge.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2025.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![GitHub release](https://img.shields.io/github/v/release/OnyxJeff/pp6-dashpi)
![Issues](https://img.shields.io/github/issues/OnyxJeff/pp6-dashpi)

**DashPi** turns a Raspberry Pi Zero 2W into a tiny, stubbornly reliable fullscreen dashboard device.  
It does exactly one job — displaying your dashboard — and refuses to complain about it.

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

- Run setup (installs Chromium-lite, kiosk service, WiFi watchdog)
```bash
cd ~/pp6-dashpi/scripts
chmod +x setup.sh
sudo ./setup.sh
```
> This copies scripts/configs, sets up systemd services for Chromium kiosk and WiFi watchdog, and reboots automatically.


---

## 🚦 Optional: Auto Updates & Log Rotation
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
### ➤ DakBoard URL

- Edit:
```bash
/usr/local/dashpi/config/dakboard-url.txt
```

Paste in your private DakBoard share URL.

### ➤ Refresh Interval

- Edit:
```bash
/usr/local/dashpi/config/refresh-interval
```

Specify minutes (e.g., 15).

### ➤ WiFi Watchdog Settings

- Edit:
```bash
/usr/local/dashpi/config/wifi-watchdog.conf
```

Set interface name and ping target.

---

## 🚀 Running After Installation
The kiosk auto-launches at boot via systemd.

- Manually restart the kiosk:
```bash
sudo systemctl restart kiosk.service
```

- Restart the WiFi watchdog:
```bash
sudo systemctl restart wifi-watchdog.service
```

- Launch kiosk manually for testing:
```bash
bash ~/pp6-dashpi/scripts/kiosk.sh
```

---

## 🧹 Uninstalling
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

---

## Acknowledgements

This project uses or is inspired by:
[Chromium](https://www.raspberrypi.com/software/) – Fullscreen kiosk browser
[DAKboard](https://dakboard.com/site) – Dashboard service displayed on the kiosk
[Raspberry Pi Forums](https://forums.raspberrypi.com/viewtopic.php?t=40860) – Community kiosk tips

---

📬 Maintained By
Jeff M. • [@OnyxJeff](https://www.github.com/onyxjeff)