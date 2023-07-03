#!/usr/bin/bash

# Download files
curl -o /tmp/xray-dat-update.service "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/xray-dat-update.service"
curl -o /tmp/xray-dat-update.timer "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/xray-dat-update.timer"
curl -o /tmp/updategeodat.sh "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/updategeodat.sh"

# Move files to appropriate locations
mv /tmp/updategeodat.sh /usr/local/bin/updategeodat.sh
mv /tmp/xray-dat-update.service /etc/systemd/system/xray-dat-update.service
mv /tmp/xray-dat-update.timer /etc/systemd/system/xray-dat-update.timer

# Set execute permission for updategeodat.sh
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
