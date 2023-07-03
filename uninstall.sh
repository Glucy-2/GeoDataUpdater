#!/usr/bin/bash

# Move files to temporary directory
mv /usr/local/bin/updategeodat.sh /tmp/updategeodate.sh
mv /etc/systemd/system/xray-dat-update.service /tmp/xray-dat-update.service
mv /etc/systemd/system/xray-dat-update.timer /tmp/xray-dat-update.timer

echo -e "Uninstall complete.\nYou can find deleted files in /tmp.\nThis script won't delete your geoip.dat and geosite.dat."
