#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

SERVICE_FILE="/etc/systemd/system/snaregen.service"
BACKUP_FILE="/etc/systemd/system/snaregen.service.backup"

# Backup the existing service file if it exists
if [ -f "$SERVICE_FILE" ]; then
  echo "Backing up existing snaregen.service to snaregen.service.backup"
  cp "$SERVICE_FILE" "$BACKUP_FILE"
fi

# Create or overwrite the snaregen.service file
cat <<EOF >"$SERVICE_FILE"
[Unit]
Description=Snare Gen Tool for generating log data.
After=network.target

[Service]
User=root
Group=root
ExecStart=/home/snare/snaregenv2 -destination 127.0.0.1 -port 6161 -events 100000000 -eps 300 -type apachelogv2,applebsmv2,aws-cloudtrail,aws-vpcflowlog,aws-waf,azurecloud,cisco,cisco-ftd,debug,iis,exch2008mtlogv2,exch2013mtlogv2,exchmtlogv2,fimlog,fimlogv2,firewall,cef,fortigate,iisweblogv2,iptables,isafwslogv2,isaweblogv2,linux,linuxarray,linuxkauditv2,msproxysvrlogv2,mssql,mssqlv2,mswineventlogv2,ncratm,office365-audit,office365-audit-8.5,panfirewall,pix,rubberducky,rubberduckyv2,smtpsvclogv2,snort,solaris,sonicwall,squidproxylogv2,syslog,trend,vmslogv2,winapplication,winarray,winsecurity,winsystem
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload the systemd manager configuration
echo "Reloading systemd daemon..."
systemctl daemon-reload
