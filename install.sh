#!/usr/bin/bash

# Download files
cat <<EOF > /etc/systemd/system/xray-dat-update.service
[Unit]
Description=Service for update xray-dat-rules files

[Service]
Type=oneshot
ExecStart=/usr/local/bin/updategeodat.sh
EOF

cat <<EOF > /etc/systemd/system/xray-dat-update.timer
[Unit]
Description=Timer for updating xray-dat-rules files

[Timer]
OnCalendar=*-*-* 06:10:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

curl -L -o /usr/local/bin/updategeodat.sh "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/updategeodat.sh"

# Set permission
chmod +x /usr/local/bin/updategeodat.sh

# Enable xray-dat-update.timer
if systemctl enable xray-dat-update.timer; then
  echo "xray-dat-update.timer enable succeeded"
else
  echo "xray-dat-update.timer enable failed"
fi

# Start xray-dat-update.service
if systemctl start xray-dat-update.service; then
  echo "xray-dat-update.service start succeeded"
else
  echo "xray-dat-update.service start failed, please check logs"
fi

# Start xray-dat-update.timer
if systemctl start xray-dat-update.timer; then
  echo "xray-dat-update.timer start succeeded"
else
  echo "xray-dat-update.timer start failed, please check logs"
fi

