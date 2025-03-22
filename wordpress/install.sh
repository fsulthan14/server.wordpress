#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0} is not running as root. please run as root."
    exit 1
fi

if [ "$#" -lt 3 ]; then
   echo "[ERROR] Wrong number of arguments"
   echo "Syntax is:"
   echo "   ${0} <parent-dir> <username> <wp-url>"
   exit 1
fi

echo
echo "[INFO] Exec ${0} ${1} ${2} ${3}"
echo

# Variables
dirName=$(dirname "${0}")
PARENTDIR="${1}"
USERNAME="${2}"
WP_URL="${3}"
DB_NAME="wp${USERNAME}"
DB_USERNAME="wpdb${USERNAME}"

echo "[INFO] Installing Dependencies.."
apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common
apt update
DEBIAN_FRONTEND=noninteractive apt install -y php8.1-mysql php8.1-imagick php8.1-fpm php8.1-curl php8.1-gd php8.1-intl \
            php8.1-mbstring php8.1-soap php8.1-xml php8.1-zip php8.1-bcmath \
            apt-transport-https curl nginx iputils-ping unzip
echo "[INFO] Setup Default PHP"
update-alternatives --set php /usr/bin/php8.1
php -v
systemctl restart php8.1-fpm nginx
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
sed -i -e "s/database_name_here/${DB_NAME}/g" \
       -e "s/username_here/${DB_USERNAME}/g" \
       -e "s/password_here/${DB_PASSWORD}/g" \
       "${PARENTDIR}/${USERNAME}/wp-config.php"

# Generate Salt
sed -i '/AUTH_KEY/d; /SECURE_AUTH_KEY/d; /LOGGED_IN_KEY/d; /NONCE_KEY/d; /AUTH_SALT/d; /SECURE_AUTH_SALT/d; /LOGGED_IN_SALT/d; /NONCE_SALT/d' ${PARENTDIR}/${USERNAME}/wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> ${PARENTDIR}/${USERNAME}/wp-config.php

chmod 640 ${PARENTDIR}/${USERNAME}/wp-config.php
chown -R ${USERNAME}:www-data ${PARENTDIR}/${USERNAME} /var/www/html/wp

# Increasing File Size Upload
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.1/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 200M/g' /etc/php/8.1/fpm/php.ini
systemctl restart php8.1-fpm
echo "[INFO] Done"

echo "[INFO] Set Up Nginx Configuration..."
rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
sed -i "s/%ADDRESS%/${WP_URL}/g" ${dirName}/nginx.conf.template
cp ${dirName}/nginx.conf.template /etc/nginx/sites-enabled/wordpress.conf
systemctl reload nginx
echo "[INFO] Done"
