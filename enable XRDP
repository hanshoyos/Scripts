#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Update and Upgrade Ubuntu System
echo "Updating and upgrading your system..."
apt update && apt upgrade -y

# Add xRDP user to the ssl-cert group
usermod -aG ssl-cert xrdp

# Enable and start xRDP service
systemctl enable xrdp
systemctl restart xrdp

# Configure Firewall to allow RDP
echo "Configuring UFW to allow RDP traffic..."
ufw allow from any to any port 3389 proto tcp

# Optional: Configure GNOME session for xRDP
# This is for Ubuntu 22.04 which uses GNOME by default
echo "Configuring GNOME sessions for xRDP..."
echo "export GNOME_SHELL_SESSION_MODE=ubuntu" > /etc/xrdp/startwm.sh
echo "export XDG_CURRENT_DESKTOP=ubuntu:GNOME" >> /etc/xrdp/startwm.sh
echo "exec /etc/xrdp/startwm-bash.sh" >> /etc/xrdp/startwm.sh

# Restart xRDP to apply changes
systemctl restart xrdp
