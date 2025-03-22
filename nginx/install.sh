#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0} is not running as root. please run as root."
    exit 1
fi

# Variables
dirName=$(dirName "${0}")
WP_ADDRESS=${1}

echo "[INFO] Installing Nginx.."
apt update 
apt install nginx -y
echo "[INFO] Done"

echo "[INFO] Set Up Nginx Configuration..."
rm -rf /etc/nginx/sites-available /etc/nginx/sites-enabled
sed -i "s/%ADDRESS%/${WP_ADDRESS}/g" ${dirName}/nginx.conf.template
cp ${dirName}/nginx.conf.template /etc/nginx/sites-enabled/wordpress.conf
systemctl reload nginx
echo "[INFO] Done"
