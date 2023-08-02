# GeoDataUpdater

Bash script for installing GeoDataUpdater in operating systems such as Arch / CentOS / Debian / OpenSUSE that support systemd.

[Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard) 

Upstream URL: [v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat), [sing-geosite](https://github.com/SagerNet/sing-geosite), [sing-geoip](https://github.com/SagerNet/sing-ip)

```
installed: /etc/systemd/system/geodataupdater.service
installed: /etc/systemd/system/geodataupdater.timer

installed: /usr/local/bin/updategeodata.sh

installed: /opt/nekoray/geoip.dat
installed: /opt/nekoray/geoip.db
installed: /opt/nekoray/geosite.dat
installed: /opt/nekoray/geosite.db
```

## Usage

**Install GeoDataUpdater for nekoray**

```shell
 bash -c "$(curl -L https://github.com/Glucy-2/GeoDataUpdater/raw/main/install.sh)" -- install [--proxy=$http_proxy]
```

**Run GeoDataUpdater**

```shell
updategeodata.sh [--proxy=$http_proxy]
```

**Remove GeoDataUpdater**

```shell
 bash -c "$(curl -L https://github.com/Glucy-2/GeoDataUpdater/raw/main/install.sh)" -- remove
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Glucy-2/Xray-geodat-update&type=Timeline)](https://star-history.com/#Glucy-2/Xray-geodat-update&Timeline)
