#!/bin/bash

file1_name="geoip.dat"  # Replace with the first file name to download
file2_name="geosite.dat"  # Replace with the second file name to download
hash1_file_name="geoip.dat.sha256sum"  # Replace with the hash file name for the first file
hash2_file_name="geosite.dat.sha256sum"  # Replace with the hash file name for the second file
download_dir="/usr/local/share/xray/"  # Replace with the destination folder path

# Download file 1 and its corresponding hash file to the temporary folder
curl -L -o "/tmp/$file1_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/$file1_name"
curl -L -o "/tmp/$hash1_file_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/$hash1_file_name"

# Download file 2 and its corresponding hash file to the temporary folder
curl -L -o "/tmp/$file2_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/$file2_name"
curl -L -o "/tmp/$hash2_file_name" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/$hash2_file_name"

# Verify the hash values
actual_hash1=$(sha256sum "/tmp/$file1_name" | awk '{print $1}')
expected_hash1=$(cat "/tmp/$hash1_file_name" | awk '{print $1}')

actual_hash2=$(sha256sum "/tmp/$file2_name" | awk '{print $1}')
expected_hash2=$(cat "/tmp/$hash2_file_name" | awk '{print $1}')

if [ "$actual_hash1" != "$expected_hash1" ]; then
  echo "Hash verification failed for geoip.dat, deleting the file"
  rm "/tmp/$file1_name"
  rm "/tmp/$hash1_file_name"
else
  echo "Hash verification passed for geoip.dat, moving the file to the destination folder"
  mv "/tmp/$file1_name" "$download_dir"
  mv "/tmp/$hash1_file_name" "$download_dir"
fi

if [ "$actual_hash2" != "$expected_hash2" ]; then
  echo "Hash verification failed for geosite.dat, deleting the file"
  rm "/tmp/$file2_name"
  rm "/tmp/$hash2_file_name"
else
  echo "Hash verification passed for geosite.dat, moving the file to the destination folder"
  mv "/tmp/$file2_name" "$download_dir"
  mv "/tmp/$hash2_file_name" "$download_dir"
fi

# Check if xray.service is running, and start/restart if necessary
if systemctl is-active --quiet xray.service; then
  echo "xray.service is running, restarting it"
  systemctl restart xray.service
else
  echo "xray.service is not running, starting it"
  systemctl start xray.service
fi
