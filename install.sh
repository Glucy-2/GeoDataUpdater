#!/usr/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "You have to use root or sudo to run this script"
    exit 1
fi
# Initialize variables
proxy=

# Function for installation
install() {
    local proxy_value

    # Check if --proxy is specified
    if [[ "$proxy" ]]; then
        proxy_value="$proxy"
    else
        proxy_value="default"
    fi

    # Create updategeodata.sh
    cat <<EOF >/usr/local/bin/updategeodata.sh
#!/bin/bash

if [[ \$EUID -ne 0 ]]; then
    echo "You have to use root or sudo to run this script"
    exit 1
fi

owner="1001:colord"

geoip_dat_name="geoip.dat"
geosite_dat_name="geosite.dat"
geoip_dat_hash="geoip.dat.sha256sum"
geosite_dat_hash="geosite.dat.sha256sum"

geoip_db_name="geoip.db"
geosite_db_name="geosite.db"
geoip_db_hash="geoip.db.sha256sum"
geosite_db_hash="geosite.db.sha256sum"

download_dir="/opt/nekoray/"

echo "Downloading geoip.dat"
curl -L -o "/tmp/\$geoip_dat_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$geoip_dat_name"
curl -L -o "/tmp/\$geoip_dat_hash" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$geoip_dat_hash"

echo "Verifying geoip.dat"
actual_hash=\$(sha256sum "/tmp/\$geoip_dat_name" | awk '{print \$1}')
expected_hash=\$(cat "/tmp/\$geoip_dat_hash" | awk '{print \$1}')

if [ "\$actual_hash" != "\$expected_hash" ]; then
  echo "Hash verification failed for geoip.dat, deleting the file"
  rm "/tmp/\$geoip_dat_name"
  rm "/tmp/\$geoip_dat_hash"
else
  echo "Hash verification passed for geoip.dat, moving the file to the destination folder"
  chown "\$owner" "/tmp/\$geoip_dat_name"
  mv "/tmp/\$geoip_dat_name" "\$download_dir"
  rm "/tmp/\$geoip_dat_hash"
fi

echo "Downloading geosite.dat"
curl -L -o "/tmp/\$geosite_dat_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$geosite_dat_name"
curl -L -o "/tmp/\$geosite_dat_hash" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$geosite_dat_hash"

actual_hash2=\$(sha256sum "/tmp/\$geosite_dat_name" | awk '{print \$1}')
expected_hash2=\$(cat "/tmp/\$geosite_dat_hash" | awk '{print \$1}')

if [ "\$actual_hash" != "\$expected_hash" ]; then
  echo "Hash verification failed for geosite.dat, deleting the file"
  rm "/tmp/\$geosite_dat_name"
  rm "/tmp/\$geosite_dat_hash"
else
  echo "Hash verification passed for geosite.dat, moving the file to the destination folder"
  chown "\$owner" "/tmp/\$geosite_dat_name"
  mv "/tmp/\$geosite_dat_name" "\$download_dir"
  rm "/tmp/\$geosite_dat_hash"
fi


echo "Downloading geoip.db"
curl -L -o "/tmp/\$geoip_db_name" "https://github.com/SagerNet/sing-geoip/releases/latest/download/\$geoip_db_name"
curl -L -o "/tmp/\$geoip_db_hash" "https://github.com/SagerNet/sing-geoip/releases/latest/download/\$geoip_db_hash"

echo "Verifying geoip.db"
actual_hash=\$(sha256sum "/tmp/\$geoip_db_name" | awk '{print \$1}')
expected_hash=\$(cat "/tmp/\$geoip_db_hash" | awk '{print \$1}')

if [ "\$actual_hash" != "\$expected_hash" ]; then
  echo "Hash verification failed for geoip.db, deleting the file"
  rm "/tmp/\$geoip_db_name"
  rm "/tmp/\$geoip_db_hash"
else
  echo "Hash verification passed for geoip.db, moving the file to the destination folder"
  chown "\$owner" "/tmp/\$geoip_db_name"
  mv "/tmp/\$geoip_db_name" "\$download_dir"
  rm "/tmp/\$geoip_db_hash"
fi

echo "Downloading geosite.db"
curl -L -o "/tmp/\$geosite_db_name" "https://github.com/SagerNet/sing-geosite/releases/latest/download/\$geosite_db_name"
curl -L -o "/tmp/\$geosite_db_hash" "https://github.com/SagerNet/sing-geosite/releases/latest/download/\$geosite_db_hash"

actual_hash2=\$(sha256sum "/tmp/\$geosite_db_name" | awk '{print \$1}')
expected_hash2=\$(cat "/tmp/\$geosite_db_hash" | awk '{print \$1}')

if [ "\$actual_hash" != "\$expected_hash" ]; then
  echo "Hash verification failed for geosite.db, deleting the file"
  rm "/tmp/\$geosite_db_name"
  rm "/tmp/\$geosite_db_hash"
else
  echo "Hash verification passed for geosite.db, moving the file to the destination folder"
  chown "\$owner" "/tmp/\$geosite_db_name"
  mv "/tmp/\$geosite_db_name" "\$download_dir"
  rm "/tmp/\$geosite_db_hash"
fi
EOF
    chmod +x /usr/local/bin/updategeodata.sh
    # Create geodataupdater.service
    cat <<EOF >/etc/systemd/system/geodataupdater.service
[Unit]
Description=Service for updating geodata files
After=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/updategeodata.sh
StandardOutput=syslog
StandardError=syslog
EOF

    if [[ "$proxy_value" != "default" ]]; then
        echo -e "Environment=http_proxy=$proxy_value\nEnvironment=https_proxy=$proxy_value" >>/etc/systemd/system/geodataupdater.service
    fi

    echo -e "\n[Install]\nWantedBy=multi-user.target" >>/etc/systemd/system/geodataupdater.service

    # Create geodataupdater.timer
    cat <<EOF >/etc/systemd/system/geodataupdater.timer
[Unit]
Description=Timer for updating geodata files

[Timer]
OnCalendar=*-*-* 06:10:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Enable and start the service and timer
    if systemctl enable geodataupdater.timer; then
        echo "geodataupdater.timer enable succeeded"
    else
        echo "geodataupdater.timer enable failed"
    fi

    if systemctl start geodataupdater.timer; then
        echo "geodataupdater.timer start succeeded"
    else
        echo "geodataupdater.timer start failed"
    fi

    if [[ "$proxy_value" == "default" ]]; then
        bash /usr/local/bin/updategeodata.sh
    else
        http_proxy="$proxy_value" https_proxy="$proxy_value" bash /usr/local/bin/updategeodata.sh
    fi

    echo "Installation complete."
    read -p "Do you want to enable the geodataupdater.service? [y/N]: " choice
    case "$choice" in
    y | Y)
        if systemctl enable geodataupdater.service; then
            echo "geodataupdater.service enabled."
        else
            echo "Failed to enable geodataupdater.service."
        fi
        ;;
    *)
        echo "You can manually enable geodataupdater.service."
        ;;
    esac
    echo "Installation completed successfully."
    exit 0
}

# Function for uninstallation
uninstall() {
    # Stop and disable the service and timer
    if systemctl stop geodataupdater.service; then
        echo "Stopping geodataupdater.service: Success"
    else
        echo "Stopping geodataupdater.service: Failed"
    fi

    if systemctl disable geodataupdater.service; then
        echo "Disabling geodataupdater.service: Success"
    else
        echo "Disabling geodataupdater.service: Failed"
    fi

    if systemctl stop geodataupdater.timer; then
        echo "Stopping geodataupdater.timer: Success"
    else
        echo "Stopping geodataupdater.timer: Failed"
    fi

    if systemctl disable geodataupdater.timer; then
        echo "Disabling geodataupdater.timer: Success"
    else
        echo "Disabling geodataupdater.timer: Failed"
    fi

    # Move files to temporary directory
    mv /usr/local/bin/updategeodata.sh /tmp/updategeodata.sh
    mv /etc/systemd/system/geodataupdater.service /tmp/geodataupdater.service
    mv /etc/systemd/system/geodataupdater.timer /tmp/geodataupdater.timer

    echo -e "\
Uninstallation complete.
You can find deleted files in /tmp.
This script won't delete your database files."
    exit 0
}

# Parse command line arguments
action=
for arg in "$@"; do
    case $arg in
    --proxy=*)
        proxy="${arg#*=}"
        ;;
    remove)
        action="remove"
        ;;
    install)
        action="install"
        ;;
    *)
        echo "Invalid argument: $arg"
        exit 1
        ;;
    esac
done

# Perform action based on user input
case "$action" in
remove)
    uninstall
    ;;
install)
    install
    ;;
*)
    echo "No action specified. Exiting..."
    ;;
esac
