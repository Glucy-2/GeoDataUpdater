#!/usr/bin/bash

mv /usr/local/bin/updategeodat.sh /tmp/updategeodate.sh
mv /etc/systemd/system/xray-dat-update.service /tmp/xray-dat-update.service
mv /etc/systemd/system/xray-dat-update.timer /tmp/xray-dat-update.timer

echo -e "Uninstall complete.\nYou can fine deleted file in /tmp.\nThis script won't delete Your geoip.dat and geosite.dat"