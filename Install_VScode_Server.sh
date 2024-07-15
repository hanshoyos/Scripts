#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to log informational messages.
log() {
    echo "[INFO] $1"
}

# Function to log error messages and exit the script.
error() {
    echo "[ERROR] $1"
    exit 1
}

log "Updating package lists..."
sudo apt update || error "Failed to update package lists."

log "Upgrading installed packages..."
sudo apt upgrade -y || error "Failed to upgrade packages."

log "Installing curl..."
sudo apt install -y curl || error "Failed to install curl."

log "Installing VS Code Server..."
curl -fsSL https://code-server.dev/install.sh | sh || error "Failed to install VS Code Server."

CONFIG_DIR="$HOME/.config/code-server"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

log "Configuring VS Code Server..."
mkdir -p "$CONFIG_DIR" || error "Failed to create config directory."

cat <<EOF > "$CONFIG_FILE" || error "Failed to write config file."
bind-addr: 127.0.0.1:8080
auth: password
password: P@ssw0rd
cert: false
EOF

log "Starting VS Code Server to ensure it's working..."
code-server || error "Failed to start VS Code Server."

log "Stopping VS Code Server..."
pkill code-server || error "Failed to stop VS Code Server."

log "Creating systemd service file..."
SERVICE_FILE="/etc/systemd/system/code-server.service"
sudo bash -c "cat <<EOF > $SERVICE_FILE
[Unit]
Description=VS Code Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/code-server --host 0.0.0.0 --port 8080
Restart=always

[Install]
WantedBy=multi-user.target
EOF
" || error "Failed to create systemd service file."

log "Reloading systemd daemon..."
sudo systemctl daemon-reload || error "Failed to reload systemd daemon."

log "Enabling VS Code Server service..."
sudo systemctl enable code-server || error "Failed to enable VS Code Server service."

log "Starting VS Code Server service..."
sudo systemctl start code-server || error "Failed to start VS Code Server service."

log "Outputting the status of the VS Code Server service..."
sudo systemctl status code-server || error "Failed to get the status of the VS Code Server service."

log "VS Code Server installation and configuration completed successfully!"
