#!/bin/bash

# --- Configuration ---
INSTALL_DIR="$HOME/.misericorde"
SCRIPT_URL="https://raw.githubusercontent.com/4p/misericorde/main/misericorde.sh"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"

# --- Basic checks ---
if ! command -v dpkg-query >/dev/null 2>&1; then
    echo "dpkg-query is not available. This script is meant for Debian-based systems."
    exit 1
fi

# Check if Discord is installed
if ! dpkg-query -W -f='${Status}' discord 2>/dev/null | grep -q "install ok installed"; then
    echo "Discord is not installed. Please install Discord before using Miséricorde."
    exit 1
fi

# Check if curl is installed
if ! dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -q "install ok installed"; then
    echo "The 'curl' command is required but not installed. Please install it and try again."
    exit 1
fi

# Check if systemd is available
if ! pidof systemd >/dev/null; then
    echo "systemd does not seem to be running. This installation requires systemd."
    exit 1
fi

# Detect environment variables (for Zenity, etc.)
DISPLAY_VAR=$(echo "$DISPLAY")
XAUTHORITY_VAR=$(echo "$XAUTHORITY")
DBUS_SESSION_VAR=$(echo "$DBUS_SESSION_BUS_ADDRESS")

if [ -z "$DISPLAY_VAR" ] || [ -z "$XAUTHORITY_VAR" ] || [ -z "$DBUS_SESSION_VAR" ]; then
    echo "Failed to detect DISPLAY, XAUTHORITY, or DBUS_SESSION_BUS_ADDRESS."
    echo "Make sure you're running this script from a GUI session."
    exit 1
fi

# --- Create installation directory and download main script ---
mkdir -p "$INSTALL_DIR"
if curl -s -o "$INSTALL_DIR/misericorde.sh" "$SCRIPT_URL"; then
    chmod +x "$INSTALL_DIR/misericorde.sh"
else
    echo "Failed to download the misericorde.sh script from GitHub."
    exit 1
fi

# --- Create user-level systemd directories if needed ---
mkdir -p "$USER_SYSTEMD_DIR"

# --- Create the service content ---
SERVICE_PATH="$USER_SYSTEMD_DIR/misericorde.service"
TIMER_PATH="$USER_SYSTEMD_DIR/misericorde.timer"

SERVICE_CONTENT="[Unit]
Description=Miséricorde - Discord Auto-Updater (User Session)

[Service]
Type=oneshot
ExecStart=$INSTALL_DIR/misericorde.sh
"

TIMER_CONTENT="[Unit]
Description=Run Miséricorde (Discord Auto-Updater) every 5 hours

[Timer]
OnCalendar=*-*-* 00/5:00:00
Persistent=true

[Install]
WantedBy=timers.target
"

# --- Write service and timer files to ~/.config/systemd/user ---
echo "$SERVICE_CONTENT" > "$SERVICE_PATH"
echo "$TIMER_CONTENT"   > "$TIMER_PATH"

# --- Enable and start the timer in the user session ---
systemctl --user daemon-reload
systemctl --user enable misericorde.timer
systemctl --user start misericorde.timer

# --- Final message ---
echo "Miséricorde has been installed for your user and will check for Discord updates every 5 hours."
echo "Service file: $SERVICE_PATH"
echo "Timer file:   $TIMER_PATH"
echo "Script path:  $INSTALL_DIR/misericorde.sh"
echo
echo "Note: This user-level timer runs only while you are logged in."
echo "If you log out, the service won’t run until you log back in."
