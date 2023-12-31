# GeoDataUpdater

Bash script for installing GeoDataUpdater in operating systems such as Arch / CentOS / Debian / OpenSUSE that support systemd.

[Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard) 

Upstream URL: [v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat), [sing-geosite](https://github.com/SagerNet/sing-geosite), [sing-geoip](https://github.com/SagerNet/sing-ip)

```yml
installed: /etc/systemd/system/geodataupdater.service
installed: /etc/systemd/system/geodataupdater.timer

installed: /usr/local/bin/updategeodata.sh

installed: /opt/nekoray/geoip.dat
installed: /opt/nekoray/geoip.db
installed: /opt/nekoray/geosite.dat
installed: /opt/nekoray/geosite.db
```

## Prerequest
```
bash
curl
```

## Usage

*Use `sudo` if you are not root.*

**Install / Update GeoDataUpdater for NekoRay**

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
