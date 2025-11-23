# pp6-dashpi

![Build Status](https://github.com/OnyxJeff/pp0-dashpi/actions/workflows/build.yml/badge.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2025.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![GitHub release](https://img.shields.io/github/v/release/OnyxJeff/pp6-dashpi)
![Issues](https://img.shields.io/github/issues/OnyxJeff/pp6-dashpi)

**DashPi** turns a Raspberry Pi Zero 2W into a tiny, stubbornly reliable fullscreen dashboard device.  
It does exactly one job and refuses to complain about it.

---

## 📁 Repo Structure

```text
pp0-dashpi/
├── .github/workflows/      # CI for YAML validation
├── backup_logs/            # Oldest logs from update script
├── logs/                   # Most recent runtime/update logs
├── scripts/                # Setup, WiFi watchdog, updater
└── README.md               # You're reading it!
```

---

## 🧰 Services Included
- Chromium / kweb fullscreen kiosk mode
  - Boots straight into your DakBoard URL in fullscreen. Auto-restarts if it crashes.
- WiFi Watchdog
  - Checks connectivity and restarts ```wlan0``` when your network flakes out.
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
> This installs kweb, copies scripts/configs, sets up systemd services, and reboots automatically.


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
> Runs the WiFi-check script every 15 minutes, which is a good balance for Pi Zero 2W performance.

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

The kiosk auto-launches at boot.

- If you want to manually restart the kiosk:
```bash
sudo systemctl restart kiosk.service
```

- Restart the WiFi watchdog:
```bash
sudo systemctl restart wifi-watchdog.service
```

---

## 🧹 Uninstalling
```bash
cd ~/pp6-dashpi/scripts
chmod +x uninstall.sh
sudo ./uninstall.sh
```

- This will remove:
  - systemd units
  - installed scripts
  - kiosk auto-start
  - watchdog monitor

---

## 🧪 Optional: Cron-Based Refresh or Logs

(You can add your own cronjobs similar to your Forseti repo.)
See docs/SETUP.md for extended usage.

---

## Acknowledgements

This project uses or is inspired by:
- [kweb](http://www.raspberrypi.org/forums/memberlist.php?mode=viewprofile&u=9343&sid=911aab9d2d1d860bdaf1bc8c30e6e712) – Lightweight webkit browser
- [DAKboard](https://dakboard.com/site) – Dashboard service displayed on the kiosk
- [Community kiosk tips](https://forums.raspberrypi.com/viewtopic.php?t=40860) from Raspberry Pi forums

---

📬 Maintained By
Jeff M. • [@OnyxJeff](https://www.github.com/onyxjeff)