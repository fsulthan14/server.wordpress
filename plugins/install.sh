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

dirName=$(dirname "${0}")
PARENTDIR="${1}"
USERNAME="${2}"
PLUGIN_LIST="${dirName}/plugin.lst"

if [[ ! -f "${PLUGIN_LIST}" ]]; then
    echo "[ERROR] File ${PLUGIN_LIST} tidak ditemukan!"
    exit 1
fi

echo "[INFO] Installing plugins from ${PLUGIN_LIST}..."

for PLUGIN in $(cat "${PLUGIN_LIST}"); do
    echo "[INFO] Installing plugin: ${PLUGIN}"
    wp plugin install "${PLUGIN}" --path=${PARENTDIR}/${USERNAME} --activate --allow-root
done

echo "[INFO] All plugins installed successfully!"
