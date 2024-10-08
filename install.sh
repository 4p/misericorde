#!/bin/bash

# Define the directory where the script will be stored
INSTALL_DIR="$HOME/.misericorde"
SCRIPT_URL="https://raw.githubusercontent.com/4p/misericorde/main/misericorde.sh"

# Check if Discord is installed
if ! dpkg-query -W -f='${Status}' discord 2>/dev/null | grep -q "install ok installed"; then
    echo "Discord is not installed. Please install Discord first before using Miséricorde."
    exit 1
fi

# Check if curl is installed
if ! dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -q "install ok installed"; then
    echo "The 'curl' command is required but not installed. Please install it and try again."
    exit 1
fi

# Ensure the user has permission to use crontab
if [ -f /etc/cron.deny ] && grep -qx "$USER" /etc/cron.deny; then
    zenity --error --title="Access Denied" --text="User $USER is denied crontab access in /etc/cron.deny. Please update the configuration." --width=400
    exit 1
elif [ -f /etc/cron.allow ] && ! grep -qx "$USER" /etc/cron.allow; then
    zenity --info --title="Authentication Required" --text="This action requires elevated permissions to add your user to /etc/cron.allow. Please enter your password." --width=400   
    echo "Adding user $USER to /etc/cron.allow." 
    # Use pkexec to elevate privileges for both actions
    pkexec bash -c "echo '$USER' >> /etc/cron.allow && chmod 0644 /etc/cron.allow"
fi

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download the main script from the GitHub repository silently
if curl -s -o "$INSTALL_DIR/misericorde.sh" "$SCRIPT_URL"; then
    # Make the script executable
    chmod +x "$INSTALL_DIR/misericorde.sh"
else
    echo "Failed to download the script. Please check your internet connection or the script URL."
    exit 1
fi

# Make the script executable
chmod +x "$INSTALL_DIR/misericorde.sh"

# Setup crontab to run the script every hour, only if it doesn't exist yet
if ! crontab -l 2>/dev/null | grep -q "0 \* \* \* \* $INSTALL_DIR/misericorde.sh"; then
    (crontab -l 2>/dev/null; echo "0 * * * * $INSTALL_DIR/misericorde.sh") | crontab -
fi

echo "Miséricorde has been installed and will check for Discord updates every hour."