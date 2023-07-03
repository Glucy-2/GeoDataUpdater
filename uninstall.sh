#!/usr/bin/bash

# Stop and disable xray-dat-update.timer
if systemctl is-active --quiet xray-dat-update.timer; then
  echo "Stopping xray-dat-update.timer"
  systemctl stop xray-dat-update.timer
fi

if systemctl is-enabled --quiet xray-dat-update.timer; then
  echo "Disabling xray-dat-update.timer"
  systemctl disable xray-dat-update.timer
fi

# Stop and disable xray-dat-update.service
if systemctl is-active --quiet xray-dat-update.service; then
  echo "Stopping xray-dat-update.service"
  systemctl stop xray-dat-update.service
fi

if systemctl is-enabled --quiet xray-dat-update.service; then
  echo "Disabling xray-dat-update.service"
  systemctl disable xray-dat-update.service
fi

# Move files to temporary directory
mv /usr/local/bin/updategeodat.sh /tmp/updategeodate.sh
mv /etc/systemd/system/xray-dat-update.service /tmp/xray-dat-update.service
mv /etc/systemd/system/xray-dat-update.timer /tmp/xray-dat-update.timer

echo -e "Uninstall complete.\nYou can find deleted files in /tmp.\nThis script won't delete your geoip.dat and geosite.dat."
