#!/bin/bash

# Enable debug mode if --debug argument is provided
DEBUG=false
if [[ "$1" == "--debug" ]]; then
    DEBUG=true
fi

# Function to check if the OS is Debian-based
check_debian_os() {
    if ! grep -iq "debian" /etc/os-release; then
        zenity --error --title="Incompatible OS" --text="This script is designed to run on Debian-based systems only." --width=300
        exit 1
    fi
}

# Function to check for internet connectivity
check_internet_connection() {
    if ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        zenity --error --title="No Internet Connection" --text="Internet connection is required to check for updates." --width=300
        exit 1
    fi
}

# Check if the system is Debian-based
check_debian_os

# Check for internet connectivity
check_internet_connection

# Base URL for Discord API and download
DISCORD_API_BASE_URL="https://discord.com/api"
DISCORD_DOWNLOAD_URL="${DISCORD_API_BASE_URL}/download?platform=linux&format=deb"
DISCORD_UPDATE_URL="${DISCORD_API_BASE_URL}/updates?platform=linux&format=deb"

# Function to log messages in debug mode
log_debug() {
    if [ "$DEBUG" = true ]; then
        echo "$1"
    fi
}

# Function to update the Zenity progress bar
update_progress() {
    echo "$1"  # Progress percentage (0-100)
    echo "# $2"  # Message to display in progress bar
    sleep 1
}

# Function to get the current installed Discord version
get_installed_version() {
    log_debug "Checking installed Discord version..."
    dpkg-query -W -f='${Version}\n' discord 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'
}

# Function to get the latest version of Discord from the update API
get_latest_version() {
    log_debug "Fetching latest Discord version from API..."
    curl -s "$DISCORD_UPDATE_URL" | grep -oP '"name":\s*"\K[0-9]+\.[0-9]+\.[0-9]+'
}

# Function to send desktop notifications
notify_user() {
    notify-send "Discord Update" "$1"
    log_debug "Notification sent to user: $1"
}

# Function to check if Discord is running
check_discord_running() {
    pgrep Discord > /dev/null
}

# Function to stop Discord gracefully
stop_discord() {
    log_debug "Attempting to stop Discord gracefully..."
    pkill -SIGTERM Discord

    for i in {1..5}; do
        if ! pgrep Discord > /dev/null; then
            log_debug "Discord closed gracefully."
            return 0
        fi
        sleep 1
    done

    log_debug "Discord did not close gracefully. Sending SIGKILL..."
    pkill -SIGKILL Discord

    if pgrep Discord > /dev/null; then
        log_debug "Failed to stop Discord even after SIGKILL. Exiting with error."
        zenity --error --title="Discord Stop Error" --text="Failed to stop Discord process." --width=300
        exit 1
    fi

    log_debug "Discord forcefully terminated."
}

# Function to download and install Discord with progress
update_discord() {
    log_debug "Downloading latest Discord version..."
    update_progress 50 "Downloading Discord..."

    if [ "$DEBUG" = true ]; then
        wget -O /tmp/discord.deb "$DISCORD_DOWNLOAD_URL"
    else
        wget -q -O /tmp/discord.deb "$DISCORD_DOWNLOAD_URL" > /dev/null 2>&1
    fi

    if [ $? -ne 0 ]; then
        zenity --error --title="Discord Update" --text="Failed to download Discord." --width=300
        exit 1
    fi

    if check_discord_running; then
        zenity --question --title="Discord Running" --text="Discord is currently running. Do you want to stop it to proceed with the update?" --width=300
        if [ $? -eq 0 ]; then
            stop_discord
            notify_user "Discord has been stopped."
            log_debug "Discord has been stopped."
        else
            zenity --info --title="Update Canceled" --text="Update canceled because Discord is still running." --width=300
            log_debug "User canceled the update because Discord is running."
            exit 0
        fi
    fi

    log_debug "Installing downloaded Discord package..."
    update_progress 75 "Installing Discord..."

    if [ "$DEBUG" = true ]; then
        pkexec dpkg -i /tmp/discord.deb
    else
        pkexec dpkg -i /tmp/discord.deb > /dev/null 2>&1
    fi

    if [ $? -eq 0 ]; then
        log_debug "Discord successfully updated."
        update_progress 100 "Discord successfully updated!"
        notify_user "Discord has been successfully updated to version $latest_version."
    else
        zenity --error --title="Discord Update" --text="Failed to install Discord." --width=300
        notify_user "Discord update failed."
        exit 1
    fi
}

# Get the installed and latest versions
installed_version=$(get_installed_version)
latest_version=$(get_latest_version)

log_debug "Installed version: $installed_version"
log_debug "Latest version: $latest_version"

if [ "$installed_version" == "$latest_version" ]; then
    exit 0
else
    notify_user "New Discord version available: $latest_version. You are running version $installed_version."

    zenity --question --title="Discord Update Available" --text="Current version: $installed_version\nLatest version: $latest_version\nDo you want to update now?" --width=300
    if [ $? -eq 0 ]; then
        (
            update_progress 25 "Preparing to update Discord..."
            update_discord
        ) | zenity --progress --title="Updating Discord" --width=400 --percentage=0 --auto-close --auto-kill
    else
        zenity --info --title="Discord Update" --text="Update canceled by the user." --width=300
        log_debug "User canceled the update."
        notify_user "Discord update was canceled."
        exit 0
    fi
fi
