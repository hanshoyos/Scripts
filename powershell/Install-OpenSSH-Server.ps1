# PowerShell Script to Install and Configure OpenSSH Server on Windows

# Introduction and Explanation
# This script installs and configures the OpenSSH Server on Windows.
# Each command is broken down for individual execution if desired.

# 1. Install OpenSSH Server
# This command installs the OpenSSH server capability on your Windows machine.
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 2. Verify the Installation
# This command checks that OpenSSH Server is installed and provides its installation status.
Get-WindowsCapability -Online | Where-Object Name -like 'sshd*'

# 3. Start the OpenSSH Server Service
# This command starts the OpenSSH server service, allowing it to begin accepting SSH connections.
Start-Service sshd

# 4. Enable the OpenSSH Server Service to Start Automatically
# This command configures the SSH server service to start automatically when Windows boots up.
Set-Service -Name sshd -StartupType 'Automatic'

# 5. Verify the SSH Server is Running
# This command checks the status of the SSH server service to ensure it is running.
Get-Service sshd

# Script Execution
# You can run this entire script at once or execute each command individually as needed.
