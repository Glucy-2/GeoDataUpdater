# Xray-install

Bash script for installing Xray in operating systems such as Arch / CentOS / Debian / OpenSUSE that support systemd.

[Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```
installed: /etc/systemd/system/xray-dat-update.service
installed: /etc/systemd/system/xray-dat-update.timer

installed: /usr/local/bin/updategeodate.sh

installed: /usr/local/share/xray/geoip.dat
installed: /usr/local/share/xray/geosite.dat
```

## Basic Usage

**Install & Upgrade Xray-core and geodata with `User=nobody`, but will NOT overwrite `User` in existing service files**

```
# bash -c "$(curl -L https://github.com/KoinuDayo/Xray-geodat-update/raw/main/install.sh)"
```

**Remove Xray, except json and logs**

```
# bash -c "$(curl -L https://github.com/KoinuDayo/Xray-geodat-update/raw/main/uninstall.sh)"
```

