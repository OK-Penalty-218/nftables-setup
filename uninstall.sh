#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./uninstall.sh)"
  exit 1
fi

# Define the target folder and configuration directory
BIN_DIR="/usr/local/bin"
SCRIPT_DIR="/etc/nftables"

# Remove command scripts
echo "Removing backup scripts from $BIN_DIR..."
rm -f "$BIN_DIR/setup-fw" "$BIN_DIR/reset-fw" "$BIN_DIR/secure-fw"

# Remove bash scripts
if [ -d "$SCRIPT_DIR" ]; then
  echo "Removing configuration directory: $CONFIG_DIR"
  rm -f "$SCRIPT_DIR/rules.sh" "$SCRIPT_DIR/reset-rules.sh" "$SCRIPT_DIR/secure-rules.sh"
else
  echo "Script directory not found: $SCRIPT_DIR"
fi

# Removing local files
rm -R /usr/local/lib/node_modules/@ok-penalty-218/nftables-setup

echo "Uninstallation complete."
