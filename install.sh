#!/bin/bash

# Define the directory where the script will be stored
INSTALL_DIR="$HOME/.misericorde"
SCRIPT_URL="https://raw.githubusercontent.com/4p/misericorde/main/misericorde.sh"

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download the main script from the GitHub repository
curl -o "$INSTALL_DIR/misericorde.sh" "$SCRIPT_URL"

# Make the script executable
chmod +x "$INSTALL_DIR/misericorde.sh"

# Setup crontab to run the script every hour
(crontab -l 2>/dev/null; echo "0 * * * * $INSTALL_DIR/misericorde.sh") | crontab -

echo "Miséricorde has been installed and will check for Discord updates every hour."
