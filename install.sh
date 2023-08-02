#!/usr/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "You have to use root to run this script"
    exit 1
fi
# Initialize variables
proxy=

# Function for installation
install() {
    local proxy_value

    # Check if --type is specified
    checktype

    # Check if --proxy is specified
    if [[ "$proxy" ]]; then
        proxy_value="$proxy"
    else
        proxy_value="default"
    fi

    # Create updategeodata.sh
    cat <<EOF >/usr/local/bin/updategeodata.sh
#!/bin/bash

owner="1001:colord"
file1_name="geoip.dat"  
file2_name="geosite.dat"  
hash1_file_name="geoip.dat.sha256sum"  
hash2_file_name="geosite.dat.sha256sum"  
download_dir="/opt/nekoray/"  

# Download file 1 and its corresponding hash file to the temporary folder
curl -L -o "/tmp/\$file1_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$file1_name"
curl -L -o "/tmp/\$hash1_file_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$hash1_file_name"

# Download file 2 and its corresponding hash file to the temporary folder
curl -L -o "/tmp/\$file2_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$file2_name"
curl -L -o "/tmp/\$hash2_file_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/\$hash2_file_name"

# Verify the hash values
actual_hash1=\$(sha256sum "/tmp/\$file1_name" | awk '{print \$1}')
expected_hash1=\$(cat "/tmp/\$hash1_file_name" | awk '{print \$1}')

actual_hash2=\$(sha256sum "/tmp/\$file2_name" | awk '{print \$1}')
expected_hash2=\$(cat "/tmp/\$hash2_file_name" | awk '{print \$1}')

if [ "\$actual_hash1" != "\$expected_hash1" ]; then
  echo "Hash verification failed for geoip.dat, deleting the file"
  rm "/tmp/\$file1_name"
  rm "/tmp/\$hash1_file_name"
else
  echo "Hash verification passed for geoip.dat, moving the file to the destination folder"
  chown "\$owner" "/tmp/\$file1_name"
  mv "/tmp/\$file1_name" "\$download_dir"
  rm "/tmp/\$hash1_file_name"
fi

if [ "\$actual_hash2" != "\$expected_hash2" ]; then
  echo "Hash verification failed for geosite.dat, deleting the file"
  rm "/tmp/\$file2_name"
  rm "/tmp/\$hash2_file_name"
else
  echo "Hash verification passed for geosite.dat, moving the file to the destination folder"
  chown "\$owner" "/tmp/\$file2_name"
  mv "/tmp/\$file2_name" "\$download_dir"
  rm "/tmp/\$hash2_file_name"
fi
EOF
    chmod +x /usr/local/bin/updategeodata.sh
    # Create geodataupdater.service
    cat <<EOF >/etc/systemd/system/geodataupdater.service
[Unit]
Description=Service for updating geodata files
After=network.target

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
    # Check if --type is specified
    checktype

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
This script won't delete your geoip.dat and geosite.dat."
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
