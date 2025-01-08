#!/bin/bash

# Function to ask for confirmation before running the script
confirm_run() {
    read -p "!WARNING! Do you want to run this script? This action will DROP ALL inbound/outboung/fowarded traffic. (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Exiting without running the script."
        exit 0
    fi
}

# Call the confirmation function
confirm_run

# Your script logic starts here
echo "Locking down the system."

# Define paths for commands
SYSCTL="/sbin/sysctl -w"
NFT="/usr/sbin/nft"
IPT="/sbin/iptables"

# Check if nft is installed
if ! command -v $NFT &>/dev/null; then
    echo "nftables is not installed. Installing..."
    sudo apt-get install nftables
fi

# Define network interfaces and addresses
INET_IFACE="eth0"
LOCAL_IFACE="enp3s0"
LOCAL_IP="192.168.0.28"
LOCAL_NET="192.168.0.0/64"
LOCAL_BCAST="192.168.0.255"
LO_IFACE="lo"
LO_IP="127.0.0.1"
SERVER="192.168.0.28"

# Flush IPTables
echo "Flushing IPTables..."

# Reset Default Policies
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -P POSTROUTING ACCEPT
$IPT -t nat -P OUTPUT ACCEPT
$IPT -t mangle -P PREROUTING ACCEPT
$IPT -t mangle -P OUTPUT ACCEPT

# Flush all rules
$IPT -F
$IPT -t nat -F
$IPT -t mangle -F

# Erase all non-default chains
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

# Check and remove iptables modules if loaded
if lsmod | grep -q iptable_mangle; then
    echo "Removing iptables kernel modules..."
    rmmod iptable_mangle || echo "iptable_mangle not loaded"
    rmmod iptable_nat || echo "iptable_nat not loaded"
    rmmod ipt_MASQUERADE || echo "ipt_MASQUERADE not loaded"
fi

# Load required kernel modules (if they exist)
echo "Loading kernel modules..."
/sbin/modprobe nf_nat || echo "nf_nat module not found"
/sbin/modprobe nf_nat_ipv4 || echo "nf_nat_ipv4 module not found"
/sbin/modprobe nf_conntrack || echo "nf_conntrack module not found"
/sbin/modprobe nf_conntrack_ipv4 || echo "nf_conntrack_ipv4 module not found"
/sbin/modprobe nf_conntrack_irc || echo "nf_conntrack_irc module not found"
/sbin/modprobe nf_nat_ftp || echo "nf_nat_ftp module not found"
/sbin/modprobe nf_conntrack_ftp || echo "nf_conntrack_ftp module not found"

# Configure Kernel Parameters
echo "Configuring kernel parameters..."
$SYSCTL net.ipv4.ip_forward="1"
$SYSCTL net.ipv4.tcp_syncookies="1"
$SYSCTL net.ipv4.conf.all.rp_filter="1"
$SYSCTL net.ipv4.icmp_echo_ignore_broadcasts="1"
$SYSCTL net.ipv4.conf.all.accept_source_route="0"
$SYSCTL net.ipv4.conf.all.secure_redirects="1"
$SYSCTL net.ipv4.conf.all.log_martians="1"

# Remove unsupported setting
if [ -e /proc/sys/net/netfilter/nf_conntrack_helper ]; then
    $SYSCTL net.netfilter.nf_conntrack_helper="1"
else
    echo "Skipping nf_conntrack_helper configuration (not supported on this system)"
fi

# Flush nftables ruleset
if [ -x "$NFT" ]; then
    $NFT flush ruleset
else
    echo "nftables not available or not executable"
fi

# Handle stop command (flush firewall entirely)
if [ "$1" = "stop" ]; then
    echo "Firewall completely flushed! Now running with no firewall."
    exit 0
fi

echo "Firewall reset and configuration complete."

#!/bin/bash

# Define nft command
nft="/usr/sbin/nft"

# Flush any existing nftables rules
$nft flush ruleset

# Create the firewall table
$nft add table inet firewall

# Define chains
$nft add chain inet firewall inbound { type filter hook input priority 0 \; policy drop \; }
$nft add chain inet firewall outbound { type filter hook forward priority 0 \; policy drop \; }
$nft add chain inet firewall forward { type filter hook forward priority 0 \; policy drop \; }

# Prevent Pings
$nft add rule inet firewall inbound ip protocol icmp icmp type echo-request drop

# Save the configuration to a file
$nft list ruleset > /etc/nftables.conf

# Apply the ruleset
$nft -f /etc/nftables.conf

echo "System locked down all inbound/outbound/fowarded traffic is blocked."
