#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0} is not running as root. please run as root."
    exit 1
fi

if [ "$#" -lt 5 ]; then
   echo "[ERROR] Wrong number of arguments"
   echo "Syntax is:"
   echo "   ${0} <parent-dir> <username> <wp-url> <website-name> <admin-mail> [php-version default:8.2]"
   exit 1
fi

echo
echo "[INFO] Exec ${0} ${1} ${2} ${3} ${4} ${5} ${6}"
echo

# Variables
dirName=$(dirname "${0}")
PARENTDIR="${1}"
USERNAME="${2}"
WP_URL="${3}"
SITE_NAME="${4}"
ADMIN_MAIL="${5}"
ADMIN_PASS="$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)"
DB_NAME="wp${USERNAME}"
DB_USERNAME="wpdb${USERNAME}"
PHP_VERSION="${6:-8.2}"

echo "[INFO] Installing Dependencies.."
apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common apt-transport-https curl nginx iputils-ping unzip
echo "[INFO] Installing PHP ${PHP_VERSION} and required extensions..."
add-apt-repository ppa:ondrej/php -y
apt update
DEBIAN_FRONTEND=noninteractive apt install -y \
    php${PHP_VERSION} php${PHP_VERSION}-mysql php${PHP_VERSION}-imagick php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring php${PHP_VERSION}-soap php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip php${PHP_VERSION}-bcmath
echo "[INFO] Setup Default PHP"
update-alternatives --set php /usr/bin/php${PHP_VERSION}
php -v
systemctl restart php${PHP_VERSION}-fpm 
systemctl restart nginx
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

echo "[INFO] Installing wp-cli"
cd /tmp 
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp cli update
echo "[INFO] Done"

echo "[INFO] Installing Wordpress.."
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

chmod 640 ${PARENTDIR}/${USERNAME}/wp-config.php
chown -R ${USERNAME}:www-data ${PARENTDIR}/${USERNAME} /var/www/html/wp
wp core install --url=${WP_URL} --title="${SITE_NAME}" --admin_user=${USERNAME} --admin_password=${ADMIN_PASS} --admin_email=${ADMIN_MAIL} --path=${PARENTDIR}/${USERNAME} --allow-root
echo "wp username: ${USERNAME} pass: ${ADMIN_PASS}" > /var/local/admin.txt

# Increasing File Size Upload
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php/${PHP_VERSION}/fpm/php.ini
systemctl restart php${PHP_VERSION}-fpm
echo "[INFO] Done"

echo "[INFO] Set Up Nginx Configuration..."
rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
sed -i "s/%ADDRESS%/${WP_URL}/g" /tmp/server.wordpress/wordpress/nginx.conf.template
cp /tmp/server.wordpress/wordpress/nginx.conf.template /etc/nginx/sites-enabled/wordpress.conf
systemctl reload nginx
echo "[INFO] Done"
