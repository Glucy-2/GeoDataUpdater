# GeoDataUpdater

Bash script for installing GeoDataUpdater in operating systems such as Arch / CentOS / Debian / OpenSUSE that support systemd.

[Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard) 

Upstream URL: 
[v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat) 

```
installed: /etc/systemd/system/geodataupdater.service
installed: /etc/systemd/system/geodataupdater.timer

installed: /usr/local/bin/updategeodata.sh

installed: /usr/local/share/$type/geoip.dat
installed: /usr/local/share/$type/geosite.dat
```

## Usage

**Install GeoDataUpdater for Xray**

```
 bash -c "$(curl -L https://github.com/KoinuDayo/GeoDataUpdater/raw/main/install.sh)" -- install
```

**Install GeoDataUpdater Using Proxy**

```
 bash -c "$(curl -L https://github.com/KoinuDayo/GeoDataUpdater/raw/main/install.sh)" -- install --proxy=$http_proxy
```

**Install GeoDataUpdater for V2ray**

```
 bash -c "$(curl -L https://github.com/KoinuDayo/GeoDataUpdater/raw/main/install.sh)" -- install --type=v2ray
```

**Remove GeoDataUpdater**

```
 bash -c "$(curl -L https://github.com/KoinuDayo/GeoDataUpdater/raw/main/install.sh)" -- remove
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=KoinuDayo/Xray-geodat-update&type=Timeline)](https://star-history.com/#KoinuDayo/Xray-geodat-update&Timeline)
