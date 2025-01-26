# 🚀 Miséricorde - Discord Auto-Updater for Debian-Based Systems 🚀

**Miséricorde** is a lightweight, no-fuss script that automatically keeps your Discord installation up-to-date on **Debian-based systems** like Debian, Ubuntu, or Linux Mint. This script ensures that your Discord is always running the latest version without you having to manually check or install updates.

## Features

- Automatically checks if you’re running the latest version of Discord.
- Gracefully stops Discord if it’s running to install updates.
- Downloads and installs the latest version if needed.
- Uses a **user-level systemd timer** to check for updates every 5 hours (customizable).
- Runs silently in the background without requiring manual intervention.
- No root (`sudo`) privileges required for installation or setup.

## 🔧 How It Works

Miséricorde takes care of the tedious update process:
1. **Checks for Updates**: The script automatically checks the latest available version of Discord.
2. **Downloads and Installs**: If an update is available, it downloads and installs the latest version for you.
3. **Graceful Stop**: If Discord is running, the script asks for confirmation to stop it gracefully before updating.
4. **Systemd Timer**: Miséricorde uses a **user-level systemd timer** instead of cron to run the updater at regular intervals (default: every 5 hours).

## 📥 Installation

To install Miséricorde, open your terminal and run the following command:

```bash
curl -s https://4p.github.io/misericorde/install.sh | bash
```

### 🛠️ What Happens After Installation?

- The script is downloaded and installed in the `~/.misericorde/` directory.
- A **user-level systemd timer** is created to automatically run the updater every 5 hours (default setting).
- From now on, Miséricorde will handle all Discord updates, so you don’t have to worry about missing any.

### No `sudo` Required! 🎉

The entire installation process happens within your home directory. Systemd timers and services are set up in `~/.config/systemd/user`, so no `sudo` privileges are needed.

## 🖥️ Supported Systems

Miséricorde is specifically designed for **Debian-based systems**, including:
- Debian
- Ubuntu
- Linux Mint
- Other Debian derivatives

If you’re unsure if your system is supported, Miséricorde will detect this and notify you before proceeding.

## Customizing the Update Interval

By default, Miséricorde runs every **5 hours**. To change this interval:
1. Edit the systemd timer file:
   ```bash
   nano ~/.config/systemd/user/misericorde.timer
   ```
2. Modify the `OnCalendar` value to your desired schedule. For example:
   - Run every minute (for testing): `OnCalendar=*-*-* *:*`
   - Run every hour: `OnCalendar=hourly`
   - Run every day at midnight: `OnCalendar=*-*-* 00:00:00`
   - For detailed scheduling options, refer to the [systemd.timer documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html).
3. Reload systemd and restart the timer:
   ```bash
   systemctl --user daemon-reload
   systemctl --user restart misericorde.timer
   ```

## Uninstalling Miséricorde

If you ever need to uninstall Miséricorde, follow these steps:
1. Stop and disable the systemd timer:
   ```bash
   systemctl --user stop misericorde.timer
   systemctl --user disable misericorde.timer
   ```
2. Remove the service and timer files:
   ```bash
   rm ~/.config/systemd/user/misericorde.service
   rm ~/.config/systemd/user/misericorde.timer
   ```
3. Reload systemd to apply the changes:
   ```bash
   systemctl --user daemon-reload
   ```
4. Optionally, delete the installation directory:
   ```bash
   rm -rf ~/.misericorde
   ```

## ❓ Need Help?

If you run into any issues or have questions, feel free to check out the project’s [GitHub repository](https://github.com/4p/misericorde). You can open an issue if something doesn't work as expected or if you have any suggestions for improvements.
