 #!/usr/bin/bash

# Function for installation
install() {
  local type_value
  local proxy_value

  # Check if --type is specified
  if [[ "$type" ]]; then
    type_value="$type"
  else
    type_value="default"
  fi

  # Check if --proxy is specified
  if [[ "$proxy" ]]; then
    proxy_value="$proxy"
  else
    proxy_value="default"
  fi

  # Download files
  if [[ "$type_value" == "default" ]]; then
    if [[ "$proxy_value" == "default" ]]; then
      curl -L -o /usr/local/bin/updategeodata.sh "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/updategeodata.sh"
    else
      curl -L -o /usr/local/bin/updategeodata.sh --proxy "$proxy_value" "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/updategeodata.sh"
    fi
  elif [[ "$type_value" == "v2ray" ]]; then
    if [[ "$proxy_value" == "default" ]]; then
      curl -L -o /usr/local/bin/updategeodata.sh "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/forV2ray.sh"
    else
      curl -L -o /usr/local/bin/updategeodata.sh --proxy "$proxy_value" "https://github.com/KoinuDayo/Xray-geodat-update/raw/main/forV2ray.sh"
    fi
  fi
  chmod +x /usr/local/bin/updategeodat.sh
  # Create geodataupdater.service
  cat <<EOF > /etc/systemd/system/geodataupdater.service
[Unit]
Description=Service for updating geodata files

[Service]
Type=oneshot
ExecStart=/usr/local/bin/updategeodat.sh
StandardOutput=syslog
StandardError=syslog
Environment="http_proxy=$proxy_value"

[Install]
WantedBy=multi-user.target
EOF

  # Create geodataupdater.timer
  cat <<EOF > /etc/systemd/system/geodataupdater.timer
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

  if systemctl start geodataupdater.service; then
    echo "geodataupdater.service start succeeded"
  else
    echo "geodataupdater.service start failed, please check logs"
  fi

  echo "Installation complete."
}

# Function for uninstallation
uninstall() {
  # Stop and disable the service and timer
  if systemctl stop geodataupdater.service; then
    echo "Stopping geodataupdater.service"
  fi

  if systemctl stop geodataupdater.timer; then
    echo "Stopping geodataupdater.timer"
  fi

  if systemctl disable geodataupdater.timer; then
    echo "Disabling geodataupdater.timer"
  fi

  # Move files to temporary directory
  mv /usr/local/bin/updategeodat.sh /tmp/updategeodate.sh
  mv /etc/systemd/system/geodataupdater.service /tmp/geodataupdater.service
  mv /etc/systemd/system/geodataupdater.timer /tmp/geodataupdater.timer

  echo -e "Uninstallation complete.\nYou can find deleted files in /tmp.\nThis script won't delete your geoip.dat and geosite.dat."
}

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --type=*)
      type="${arg#*=}"
      ;;
    --proxy=*)
      proxy="${arg#*=}"
      ;;
    --remove)
      uninstall
      exit
      ;;
    *)
      # Ignore any other arguments
      ;;
  esac
done

install
