#!/bin/bash

# Enable verbose output
set -x

# Create the update and upgrade script
cat << 'EOF' > update_upgrade.sh
#!/bin/bash

set -x
LOG_FILE="/var/log/install_code_server.log"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

log_message "Updating package lists..."
if sudo apt update; then
    log_message "Package lists updated successfully."
else
    log_message "Failed to update package lists."
    exit 1
fi

log_message "Upgrading packages..."
if sudo apt upgrade -y; then
    log_message "Packages upgraded successfully."
else
    log_message "Failed to upgrade packages."
    exit 1
fi
EOF

# Create the install curl script
cat << 'EOF' > install_curl.sh
#!/bin/bash

set -x
LOG_FILE="/var/log/install_code_server.log"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

log_message "Installing curl..."
if sudo apt install -y curl; then
    log_message "Curl installed successfully."
else
    log_message "Failed to install curl."
    exit 1
fi
EOF

# Create the install code-server script
cat << 'EOF' > install_code_server.sh
#!/bin/bash

set -x
LOG_FILE="/var/log/install_code_server.log"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

log_message "Changing to home directory..."
if cd ~; then
    log_message "Changed to home directory."
else
    log_message "Failed to change to home directory."
    exit 1
fi

log_message "Downloading and running the code-server install script..."
if curl -fsSL https://code-server.dev/install.sh | sh; then
    log_message "code-server installed successfully."
else
    log_message "Failed to install code-server."
    exit 1
fi
EOF

# Create the configure code-server script
cat << 'EOF' > configure_code_server.sh
#!/bin/bash

set -x
LOG_FILE="/var/log/install_code_server.log"
CONFIG_FILE="$HOME/.config/code-server/config.yaml"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

log_message "Modifying the code-server configuration file..."
if [ -f "$CONFIG_FILE" ]; then
    {
        echo "bind-addr: 127.0.0.1:8080"
        echo "auth: password"
        echo "password: P@ssw0rd"
        echo "cert: false"
    } | tee "$CONFIG_FILE" && log_message "Configuration file modified successfully."
else
    log_message "Configuration file not found. Creating a new one."
    mkdir -p "$(dirname "$CONFIG_FILE")" && {
        echo "bind-addr: 127.0.0.1:8080"
        echo "auth: password"
        echo "password: P@ssw0rd"
        echo "cert: false"
    } | tee "$CONFIG_FILE" && log_message "Configuration file created and modified successfully."
fi
EOF

# Create the create systemd service script
cat << 'EOF' > create_systemd_service.sh
#!/bin/bash

set -x
LOG_FILE="/var/log/install_code_server.log"
SERVICE_FILE="/etc/systemd/system/code-server.service"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

log_message "Creating systemd service file for code-server..."
{
    echo "[Unit]"
    echo "Description=VS Code Server"
    echo "After=network.target"
    echo ""
    echo "[Service]"
    echo "Type=simple"
    echo "User=root"
    echo "ExecStart=/usr/bin/code-server --host 0.0.0.0 --port 8080"
    echo "Restart=always"
    echo ""
    echo "[Install]"
    echo "WantedBy=multi-user.target"
} | sudo tee "$SERVICE_FILE" && log_message "Systemd service file created successfully."

log_message "Reloading systemd daemon..."
if sudo systemctl daemon-reload; then
    log_message "Systemd daemon reloaded successfully."
else
    log_message "Failed to reload systemd daemon."
    exit 1
fi

log_message "Enabling code-server service..."
if sudo systemctl enable code-server.service; then
    log_message "code-server service enabled successfully."
else
    log_message "Failed to enable code-server service."
    exit 1
fi

log_message "Starting code-server service..."
if sudo systemctl start code-server.service; then
    log_message "code-server service started successfully."
else
    log_message "Failed to start code-server service."
    exit 1
fi
EOF

# Create the configure SSH script
cat << 'EOF' > configure_ssh.sh
#!/bin/bash

set -x
LOG_FILE="/var/log/install_code_server.log"
SSHD_CONFIG="/etc/ssh/sshd_config"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

log_message "Modifying SSH configuration to enable port forwarding..."
if grep -q "^#AllowTcpForwarding" $SSHD_CONFIG; then
    sudo sed -i 's/#AllowTcpForwarding.*/AllowTcpForwarding yes/' $SSHD_CONFIG
elif grep -q "^AllowTcpForwarding" $SSHD_CONFIG; then
    sudo sed -i 's/AllowTcpForwarding.*/AllowTcpForwarding yes/' $SSHD_CONFIG
else
    echo "AllowTcpForwarding yes" | sudo tee -a $SSHD_CONFIG
fi

if grep -q "^#GatewayPorts" $SSHD_CONFIG; then
    sudo sed -i 's/#GatewayPorts.*/GatewayPorts yes/' $SSHD_CONFIG
elif grep -q "^GatewayPorts" $SSHD_CONFIG; then
    sudo sed -i 's/GatewayPorts.*/GatewayPorts yes/' $SSHD_CONFIG
else
    echo "GatewayPorts yes" | sudo tee -a $SSHD_CONFIG
fi

log_message "Restarting SSH service to apply changes..."
if sudo systemctl restart ssh; then
    log_message "SSH service restarted successfully."
else
    log_message "Failed to restart SSH service."
    exit 1
fi
EOF

# Make the scripts executable
chmod +x update_upgrade.sh install_curl.sh install_code_server.sh configure_code_server.sh create_systemd_service.sh configure_ssh.sh

echo "All scripts have been created and made executable."

# run this after: chmod +x update_upgrade.sh install_curl.sh install_code_server.sh configure_code_server.sh create_systemd_service.sh configure_ssh.sh
