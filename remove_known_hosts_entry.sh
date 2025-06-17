#!/bin/bash

# Script to remove all lines associated with a specified IP address
# from the ~/.ssh/known_hosts file.

KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
BACKUP_DIR="$HOME/.ssh/backups" # Directory for backups

# --- Functions ---

# Function to display usage
usage() {
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Example: $0 192.168.1.100"
    echo "This script will remove all lines containing the specified IP_ADDRESS from $KNOWN_HOSTS_FILE."
    exit 1
}

# Function to create a backup
create_backup() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        if [ $? -ne 0 ]; then
            echo "Error: Could not create backup directory $BACKUP_DIR. Exiting."
            exit 1
        fi
    fi
    BACKUP_FILE="${KNOWN_HOSTS_FILE}.$(date +%Y%m%d%H%M%S).bak"
    cp "$KNOWN_HOSTS_FILE" "$BACKUP_FILE"
    if [ $? -eq 0 ]; then
        echo "Backup created: $BACKUP_FILE"
    else
        echo "Warning: Could not create backup of $KNOWN_HOSTS_FILE."
    fi
}

# --- Main Script ---

# Check if an IP address is provided
if [ -z "$1" ]; then
    usage
fi

IP_TO_REMOVE="$1"

# Check if the known_hosts file exists
if [ ! -f "$KNOWN_HOSTS_FILE" ]; then
    echo "Error: $KNOWN_HOSTS_FILE not found."
    exit 1
fi

echo "Attempting to remove entries for IP: $IP_TO_REMOVE from $KNOWN_HOSTS_FILE"

# Create a backup before modifying the file
create_backup

# Create a temporary file
TEMP_FILE=$(mktemp)
if [ $? -ne 0 ]; then
    echo "Error: Could not create temporary file. Exiting."
    exit 1
fi

# Filter the known_hosts file, removing lines with the IP, and write to temp file
# Using '|' as the delimiter for the sed pattern
sed "\|$IP_TO_REMOVE|d" "$KNOWN_HOSTS_FILE" > "$TEMP_FILE"

# Check if sed command was successful
if [ $? -eq 0 ]; then
    # Move the temporary file back to the original location
    mv "$TEMP_FILE" "$KNOWN_HOSTS_FILE"
    # Ensure correct permissions for the known_hosts file
    chmod 600 "$KNOWN_HOSTS_FILE"
    echo "Successfully removed lines containing $IP_TO_REMOVE from $KNOWN_HOSTS_FILE."
    echo "You might need to restart your SSH agent or terminal for changes to take full effect."
else
    echo "An error occurred while trying to remove lines from $KNOWN_HOSTS_FILE."
    rm -f "$TEMP_FILE" # Clean up temp file on error
fi

# Inform about the backup location
echo "A backup of your known_hosts file can be found in $BACKUP_DIR"

exit 0
