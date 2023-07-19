 #!/usr/bin/bash

# Function for installation
install() {
  local type_value
  local proxy_value

  # Check if --type is specified
  if [[ "$type" ]]; then
    type_value="$type"
  else
    type_value="xray"
  fi

  # Check if --proxy is specified
  if [[ "$proxy" ]]; then
    proxy_value="$proxy"
  else
    proxy_value="default"
  fi

  # Download files
  if [[ "$type_value" == "xray" ]]; then
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
  chmod +x /usr/local/bin/updategeodata.sh
  # Create geodataupdater.service
  cat <<EOF > /etc/systemd/system/geodataupdater.service
[Unit]
Description=Service for updating geodata files

[Service]
Type=oneshot
ExecStart=/usr/local/bin/updategeodata.sh
StandardOutput=syslog
StandardError=syslog
EOF

  if [[ "$proxy_value" != "default" ]]; then
    echo -e "Environment=http_proxy=$proxy_value\nEnvironment=https_proxy=$proxy_value" >> /etc/systemd/system/geodataupdater.service
  fi

  echo -e "\n[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/geodataupdater.service

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

  if bash /usr/local/bin/updategeodata.sh; then
    echo "Successfully updated geodata"
  else
    echo "Failed to update geodata"
  fi
  
  echo "Installation complete."
  read -p "Do you want to disable $type_value.service and enable the geodataupdater.service? [Y/n]: " choice
  case "$choice" in
    y|Y|"")
      if systemctl disable $type_value.service; then
        echo "$type_value.service disabled."
      else
        echo "Failed to disable $type_value.service."
      fi

      if systemctl enable geodataupdater.service; then
        echo "geodataupdater.service enabled."
      else
        echo "Failed to enable geodataupdater.service."
      fi
      ;;
    *)
      echo "You can manually disable xray.service and enable geodataupdater.service."
      ;;
  esac
}

# Function for uninstallation
uninstall() {
  # Check if --type is specified
  if [[ "$type" ]]; then
    type_value="$type"
  else
    type_value="xray"
  fi

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

# Enable $type.service
  if systemctl enable $type_value.service; then
    echo "Enabling $type_value.service: Success"
  else
    echo "Enabling $type_value.service: Failed"
  fi

  # Move files to temporary directory
  mv /usr/local/bin/updategeodata.sh /tmp/updategeodata.sh
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
