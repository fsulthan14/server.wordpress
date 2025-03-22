#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root!" >&2
  exit 1
fi

if [ "$#" -lt 3 ]; then
   echo "[ERROR] Wrong number of arguments"
   echo "Syntax is:"
   echo "   ${0} <nxfilter-username> <nxfilter-dir> <nxfilter-version>"
   exit 1
fi

echo
echo "[INFO] Exec ${0} ${1} ${2} ${3}"
echo

dirName=$(dirname "$0")
PARENTDIR="${1}"
USERNAME="${2}"
DB_NAME=wpdb-${USERNAME}
BACKUP_NAME=${USERNAME}

sed -i -e "s@%USERNAME%@${BACKUP_NAME}@g" \
       -e "s@%PARENTDIR%@${PARENTDIR}/${USERNAME}@g" \
       -e "s@%DB_NAME%@${DB_NAME}@g" \
       "${PARENTDIR}/${USERNAME}/wp-config.php"
