#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0} is not running as root. please run as root."
    exit 1
fi

# Variables
dirName=$(dirName "${0}")
PARENTDIR="/opt"
USERNAME="${1}"
DB_NAME="wordpress-${USERNAME}"
DB_USERNAME="wpdb"

echo "[INFO] Installing Dependencies.."
apt update && upgrade -y 
apt install php-imagick php-fpm php-curl php-gd php-intl php-mbstring php-soap php-xml php-zip php-mysqli php-comm php-bcmath apt-transport-https curl -y
echo "[INFO] Done"

echo "[INFO] Create Database & User for Wordpress.."
DB_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 16 | head -n 1)
mysql -e "
  DROP DATABASE IF EXISTS \`${DB_NAME}\`;
  DROP USER IF EXISTS '${DB_USERNAME}'@'localhost';
  CREATE DATABASE \`${DB_NAME}\`;
  GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* to '${DB_USERNAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
  FLUSH PRIVILEGES;
"
echo "[INFO] Done"

echo "[INFO] Create Wordpress User.."
id ${USERNAME} &> /dev/null && userdel -rf ${USERNAME} &>/dev/null
getent group ${USERNAME} &> /dev/null && groupdel ${USERNAME} &>/dev/null

groupadd ${USERNAME}
useradd -m -s /bin/bash -c "" -d ${PARENTDIR}/${USERNAME} -u 1945 -g ${USERNAME} -G www-data ${USERNAME}

if [ -d "${PARENTDIR}/${USERNAME}" ]; then
    cp -r /etc/skel/. ${PARENTDIR}/${USERNAME}/
    chown -R ${USERNAME}:${USERNAME} ${PARENTDIR}/${USERNAME}
fi

echo "[INFO] Done"

echo "[INFO] Installing Wordpress.."
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
mv /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
cp -a /tmp/wordpress/. ${PARENTDIR}/${USERNAME}/
ln -sf ${PARENTDIR}/${USERNAME} /var/www/html/wp 

echo "[INFO] Set up wordpress configuration.."
cd ${PARENTDIR}/${USERNAME}

sed -i -e "s/database_name_here/${DB_NAME}/g" \
       -e "s/username_here/${DB_USERNAME}/g" \
       -e "s/password_here/${DB_PASSWORD}/g" \
       "${PARENTDIR}/${USERNAME}/wp-config.php"

# Generate Salt
sed -i '/AUTH_KEY/d; /SECURE_AUTH_KEY/d; /LOGGED_IN_KEY/d; /NONCE_KEY/d; /AUTH_SALT/d; /SECURE_AUTH_SALT/d; /LOGGED_IN_SALT/d; /NONCE_SALT/d' ${PARENTDIR}/${USERNAME}/wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> ${PARENTDIR}/${USERNAME}/wp-config.php

chmod 640 ${PARENTDIR}/${USERNAME}/wp-config.php
chown -R ${USERNAME}:www-data ${PARENTDIR}/${USERNAME} /var/www/html/wp

echo "[INFO] Done"
