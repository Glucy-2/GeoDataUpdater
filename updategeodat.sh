#!/usr/bin/bash

wget -P /tmp "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
wget -P /tmp "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

mv /tmp/geoip.dat /usr/local/share/xray/
mv /tmp/geosite.dat /usr/local/share/xray/

systemctl restart xray
