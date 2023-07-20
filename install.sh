#!/usr/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "You have to use root to run this script"
    exit 1
fi
# Initialize variables
type=
proxy=

# Function for installation
install() {
  local type_value
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
  cat <<EOF > /usr/local/bin/updategeodata.sh
#!/bin/bash

file1_name="geoip.dat"  # Replace with the first file name to download
file2_name="geosite.dat"  # Replace with the second file name to download
hash1_file_name="geoip.dat.sha256sum"  # Replace with the hash file name for the first file
hash2_file_name="geosite.dat.sha256sum"  # Replace with the hash file name for the second file
download_dir="/usr/local/share/$type_value/"  # Replace with the destination folder path

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
  mv "/tmp/\$file1_name" "\$download_dir"
  mv "/tmp/\$hash1_file_name" "\$download_dir"
fi

if [ "\$actual_hash2" != "\$expected_hash2" ]; then
  echo "Hash verification failed for geosite.dat, deleting the file"
  rm "/tmp/\$file2_name"
  rm "/tmp/\$hash2_file_name"
else
  echo "Hash verification passed for geosite.dat, moving the file to the destination folder"
  mv "/tmp/\$file2_name" "\$download_dir"
  mv "/tmp/\$hash2_file_name" "\$download_dir"
fi

# Check if xray.service is running, and start/restart if necessary
if systemctl is-active --quiet xray.service; then
  echo "xray.service is running, restarting it"
  systemctl restart xray.service
else
  echo "xray.service is not running, starting it"
  systemctl start xray.service
fi
EOF
  chmod +x /usr/local/bin/updategeodata.sh
  # Create geodataupdater.service
  cat <<EOF > /etc/systemd/system/geodataupdater.service
[Unit]
Description=Service for updating geodata files
After=$type_value.service

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

  if [[ "$proxy_value" == "default" ]]; then
    bash /usr/local/bin/updategeodata.sh
  else
    http_proxy="$proxy_value" https_proxy="$proxy_value" bash /usr/local/bin/updategeodata.sh
  fi
  
  echo "Installation complete."
  read -p "Do you want to enable the geodataupdater.service? [y/N]: " choice
  case "$choice" in
    y|Y)
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
  local type_value
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

# Enable $type_value.service
  if systemctl enable $type_value.service; then
    echo "Enabling $type_value.service: Success"
  else
    echo "Enabling $type_value.service: Failed"
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

# Function for check service type
checktype() {
  # If type is not pre-specified by the user, prompt for selection
  type_value=$type
  if [ -z "$type" ]; then
          # Check if xray service exists
          if systemctl list-unit-files --full | grep -q 'xray.service'; then
              type_value="xray"
          # Check if v2ray service exists
          elif systemctl list-unit-files --full | grep -q 'v2ray.service'; then
              type_value="v2ray"
          else
              echo -e "\
xray and v2ray services not found. Which one would you like to use?
1. xray
2. v2ray"

              while true; do
                  read -p "Enter the option number (1 or 2): " choice

                  case "$choice" in
                      1)
                          type_value="xray"
                          break
                          ;;
                      2)
                          type_value="v2ray"
                          break
                          ;;
                      *)
                          echo "Invalid choice, please try again."
                          ;;
                  esac
              done
          fi
          # If both services exist, prompt for selection
          if [ "$type_value" = "xray" ] && systemctl list-unit-files --full | grep -q 'v2ray.service'; then
              echo -e "\
Detected both xray and v2ray services. Please select a service type:
1. xray
2. v2ray"

              read -p "Enter the option number (1 or 2): " choice
        while true; do
              case "$choice" in
                  1)
                      type_value="xray"
                      break
                      ;;
                  2)
                      type_value="v2ray"
                      break
                      ;;
                  *)
                      echo "Invalid choice, please try again."
                      ;;
              esac
        done
            fi
  fi
  if [[ "$type_value" == "xray" || "$type_value" == "v2ray" ]]; then
  echo "The final selected service type is: $type_value"
  else
    echo "Invalid type specified. Please use 'xray' or 'v2ray' as the type."
    checktype
  fi
}

# Parse command line arguments
action=
for arg in "$@"; do
  case $arg in
    --type=*)
      type="${arg#*=}"
      ;;
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