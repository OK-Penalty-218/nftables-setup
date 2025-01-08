#!/bin/bash

# Define target folders
BIN_DIR="/usr/local/bin"
SCRIPT_DIR="/etc/nftables"

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./install.sh)"
  exit 1
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p "$SCRIPT_DIR"

# Create commands in /usr/local/bin
echo "Installing commands to $BIN_DIR..."
cp cmds/* "$BIN_DIR"
chmod +x "$BIN_DIR"/*

# Move scripts to /etc/nftables
echo "Installing script files to $SCRIPT_DIR..."
cp scripts/* "$SCRIPT_DIR"

echo "Installation complete."
