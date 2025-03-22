#!/bin/bash

EMAIL="%MEGA_MAIL%"
PASS="%MEGA_PASS%"

echo "[MEGA] Login to MEGA.."
mega-login ${EMAIL} ${PASS}
mega-whoami
echo "[MEGA] DONE"
