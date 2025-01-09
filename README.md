# Simplified nftables Setup
a set of bash scripts to simplify the use of the nftables firewall.

## Installation
Install globally using npm:<br>
```bash 
npm install -g @ok-penalty-218/nftables-setup@1.0.0
```
or<br>
```bash
npm install -g https://github.com/OK-Penalty-218/nftables-setup.git
```

## Initial Setup
Default File Location: 
```bash
\etc\nftables\
```
Scripts and their accompanying commands:<br>
```\etc\nftables\rules.sh``` = ```setup-fw```
```\etc\nftables\reset-rules.sh``` = ```reset-fw```
```\etc\nftables\secure-rules.sh``` = ```secure-fw```

Prior to running any commands ensure you edit the ```rules.sh``` file to create your preferred firewall rules.

## Post-Insallation and Configuration
Run command:
```bash
sudo reset-fw
```
In order to fully reset your iptables firewall, verify nftables installation, and fully reset any nftables rules.<br>

After running ```reset-fw``` you can now setup your firewall. The default policies will be set to ACCEPT for inbound/outbound/fowarded traffic. So ensure you configure the setup file located in the default file location.<br>
Run command:
```bash
sudo setup-fw
```
In order to setup your nftables firewall with your rules established in the ```\etc\nftables\rules.sh``` file.<br>
If everything looks correct then you should see the following prompts:<br>
```
user@machine:$sudo setup-fw
[sudo] password for administrator:
Running 'rules.sh' to setup preset nftables firewall rules...
Firewall rules successfully applied.
user@machine:$
```
Run command:
```bash
sudo nft list ruleset
```
To view your configured nftables rules.

## Other Functionality
This package includes a command to completly secure your system. It sets all policies to drop, prevents pings, and completely locks down your system.<br>
To secure your system ensure you run the following command locally from your machine:<br>
```bash
sudo secure-fw
```
Note: If you run this command from a remote session you will lose access.

### Notes
It is recommended that you run all commands with ```sudo``` to avoid running into permission issues.
