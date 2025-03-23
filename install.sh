#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0} is not running as root. please run as root."
    exit 1
fi

if [ "$#" -lt 7 ]; then
   echo "[ERROR] Wrong number of arguments"
   echo "Syntax is:"
   echo "   ${0} <parent-dir> <username> <wp-url> <website-name> <cloud-backup-folder> <cloud-email> <cloud-pass> [php-version default:8.2]"
   exit 1
fi

echo
echo "[INFO] Exec ${0} ${1} ${2} ${3} ${4} ${5} ${6}"
echo

# Global Variables
dirName=$(dirname "${0}")
PARENTDIR="${1}"
USERNAME="${2}"
WP_URL="${3}"
SITE_NAME="${4}"
CLOUD_FOLDER="${5}"
CLOUD_MAIL="${6}"
CLOUD_PASS="${7}"
PHP_VERSION="${8:-8.2}"

# Execution Install

${dirName}/mariadb/install.sh

${dirName}/mariadb-conf/install.sh

${dirName}/wordpress/install.sh ${PARENTDIR} ${USERNAME} ${WP_URL} ${SITE_NAME} ${CLOUD_MAIL} ${PHP_VERSION}

${dirName}/script/install.sh ${PARENTDIR} ${USERNAME} ${CLOUD_FOLDER} ${CLOUD_MAIL} ${CLOUD_PASS}

${dirName}/cron/install.sh ${PARENTDIR} ${USERNAME}
