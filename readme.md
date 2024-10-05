# Miséricorde - Discord Auto-Updater for Debian-Based Systems

**Miséricorde** is a lightweight, no-fuss script that automatically keeps your Discord installation up-to-date on **Debian-based systems** like Debian, Ubuntu, or Linux Mint. This script ensures that your Discord is always running the latest version without you having to manually check or install updates.

## Features

- Automatically checks if you’re running the latest version of Discord.
- Gracefully stops Discord if it’s running to install updates.
- Downloads and installs the latest version if needed.
- Sets up a cron job to check for updates every hour.
- Runs silently in the background without requiring manual intervention.

## How It Works

Miséricorde takes care of the tedious update process:
1. **Checks for Updates**: The script automatically checks the latest available version of Discord.
2. **Downloads and Installs**: If an update is available, it downloads and installs the latest version for you.
3. **Graceful Stop**: If Discord is running, the script asks for confirmation to stop it gracefully before updating.
4. **Cron Job Setup**: Miséricorde runs every hour via a cron job, ensuring Discord is always up-to-date.

## Installation

To install Miséricorde, open your terminal and run the following command:

```bash
curl -s https://4p.github.io/misericorde/install.sh | bash
```

### What Happens After Installation?

- The script is downloaded and installed in the `~/.misericorde/` directory.
- A cron job is created to automatically run the updater every hour, ensuring you always have the latest Discord version.
- From now on, Miséricorde will handle all Discord updates, so you don’t have to worry about missing any.

## Supported Systems

Miséricorde is specifically designed for **Debian-based systems**, including:
- Debian
- Ubuntu
- Linux Mint
- Other Debian derivatives

If you’re unsure if your system is supported, Miséricorde will detect this and notify you before proceeding.

## Need Help?

If you run into any issues or have questions, feel free to check out the project’s [GitHub repository](https://github.com/4p/misericorde). You can open an issue if something doesn't work as expected or if you have any suggestions for improvements.
