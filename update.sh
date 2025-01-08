#!/bin/bash

# Define target folders
BIN_DIR="/usr/local/bin"
SCRIPT_DIR="/etc/nftables"

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./install.sh)"
  exit 1
fi

# Remove command scripts
echo "Removing backup scripts from $BIN_DIR..."
rm -f "$BIN_DIR/setup-fw" "$BIN_DIR/reset-fw" "$BIN_DIR/secure-fw"

# Remove bash scripts
if [ -d "$SCRIPT_DIR" ]; then
  echo "Removing old scripts."
  rm -f "$SCRIPT_DIR/reset-rules.sh" "$SCRIPT_DIR/secure-rules.sh"
else
  echo "Script directory not found: $SCRIPT_DIR"
fi

# Update command scripts to /usr/local/bin
echo "Updating backup scripts to $TARGET_DIR..."
cp cmds/* "$BIN_DIR"
chmod +x "$BIN_DIR"/*

# Update all other files to /etc/nftables
echo "Updating script files to $SCRIPT_DIR..."
cp scripts/secure-rules.sh "$SCRIPT_DIR"
cp scripts/reset-rules.sh "$SCRIPT_DIR"

echo "Update complete."
