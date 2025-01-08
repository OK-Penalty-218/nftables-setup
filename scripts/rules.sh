#!/bin/bash

# Define nft command
nft="/usr/sbin/nft"

# Flush any existing nftables rules
$nft flush ruleset

# Create the firewall table
$nft add table inet firewall

# Define chains
$nft add chain inet firewall inbound { type filter hook input priority 0 \; policy drop \; }
$nft add chain inet firewall forward { type filter hook forward priority 0 \; policy drop \; }

# Accept Rules


# Drop Rules


# Prevent Pings - Uncomment the below line if you want to prevent pings.
# $nft add rule inet firewall inbound ip protocol icmp icmp type echo-request drop

# Save the configuration to a file
$nft list ruleset > /etc/nftables.conf

# Apply the ruleset
$nft -f /etc/nftables.conf

echo "Firewall rules successfully applied."
