# Xray-geodat-update

Bash script for installing Xray in operating systems such as Arch / CentOS / Debian / OpenSUSE that support systemd.

[Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard) 

Upstream URL: 
[v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat) 

```
installed: /etc/systemd/system/xray-dat-update.service
installed: /etc/systemd/system/xray-dat-update.timer

installed: /usr/local/bin/updategeodat.sh

installed: /usr/local/share/xray/geoip.dat
installed: /usr/local/share/xray/geosite.dat
```

## Basic Usage

**Install Xray-geodat-update**

```
# bash -c "$(curl -L https://github.com/KoinuDayo/Xray-geodat-update/raw/main/install.sh)"
```

**Remove Xray-geodat-update**

```
# bash -c "$(curl -L https://github.com/KoinuDayo/Xray-geodat-update/raw/main/uninstall.sh)"
```

