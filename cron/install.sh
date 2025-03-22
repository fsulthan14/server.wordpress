#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0} is not running as root. please run as root."
    exit 1
fi

if [ "$#" -lt 2 ]; then
   echo "[ERROR] Wrong number of arguments"
   echo "Syntax is:"
   echo "   ${0} <parent-dir> <username>"
   exit 1
fi

echo
echo "[INFO] Exec ${0} ${1} ${2}"
echo

dirName=$(dirName "${0}")
PARENTDIR=${1}
USERNAME=${2}
BASE_TIME=$(hostname -I | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d'.' -f4)
BACKUP_MINUTE=$(( BASE_TIME % 40 ))
CLEAN_OLD=$(( 20 + BACKUP_MINUTE ))

echo "[INFO] Installing Crontab for ${USERNAME}"

crontab -l -u ${USERNAME} &>/dev/null && crontab -r -u ${USERNAME}

sed -e "s@%BACKUP_MINUTE%@${BACKUP_MINUTE}@g" \
    -e "s@%PARENTDIR%@${PARENTDIR}/${USERNAME}@g" \
    -e "s@%CLEAN_OLD%@${CLEAN_OLD}@g" \
    "${dirName}/cron.template" | crontab -u ${USERNAME}

echo "[INFO] Done"
