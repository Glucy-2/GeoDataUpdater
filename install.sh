#!/usr/bin/bash

wget -P /tmp "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/xray-dat-update.service"
wget -P /tmp "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/xray-dat-update.timer"
wget -P /tmp "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/updategeodat.sh"

mv /tmp/updategeodate.sh /usr/local/bin/updategeodat.sh
mv /tmp/xray-dat-update.service /etc/systemd/system/xray-dat-update.service
mv /tmp/xray-dat-update.timer /etc/systemd/system/xray-dat-update.timer

echo -e "Install complete, but you may need enable and start service and timer by your self.\nsystemctl enable xray-dat-update.service\nsystemctl enable xray-dat-update.timer\nsystemctl start xray-dat-update.service\nsystemctl start xray-dat-update.timer"
