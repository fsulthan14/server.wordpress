#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root!" >&2
  exit 1
fi

if [ "$#" -lt 5 ]; then
   echo "[ERROR] Wrong number of arguments"
   echo "Syntax is:"
   echo "   ${0} <parent-dir> <username> <cloud-backup-folder> <cloud-email> <cloud-pass>"
   exit 1
fi

echo
echo "[INFO] Exec ${0} ${1} ${2} ${3} ${4} ${5}"
echo

dirName=$(dirname "$0")
PARENTDIR="${1}"
USERNAME="${2}"
CLOUD_FOLDER="${3}"
CLOUD_MAIL="${4}"
CLOUD_PASS="${5}"
DB_NAME=wp${USERNAME}
BACKUP_NAME=${USERNAME}

echo "[INFO] Installing mega-cmd"
wget https://mega.nz/linux/repo/xUbuntu_22.04/amd64/megacmd-xUbuntu_22.04_amd64.deb && apt install "$PWD/megacmd-xUbuntu_22.04_amd64.deb"

echo "[INFO] Installing Script "
mkdir -p ${PARENTDIR}/${USERNAME}/bin

sed -i -e "s@%USERNAME%@${BACKUP_NAME}@g" \
       -e "s@%PARENTDIR%@${PARENTDIR}/${USERNAME}@g" \
       -e "s@%DB_NAME%@${DB_NAME}@g" \
       -e "s@%CLOUD_FOLDER%@${CLOUD_FOLDER}@g" \
       "${dirName}/bin/backupService"

sed -i -e "s|%MEGA_MAIL%|${CLOUD_MAIL}|g" \
       -e "s|%MEGA_PASS%|${CLOUD_PASS}|g" \
       "${dirName}/bin/connect-mega.sh"

cp ${dirName}/bin/* ${PARENTDIR}/${USERNAME}/bin
chown -R ${USERNAME}.${USERNAME} ${PARENTDIR}/${USERNAME}/bin
echo "[INFO] Done"
