#!/bin/bash

echo "[INFO] Installing Dependencies.."
apt update && upgrade -y 
apt install unzip php-fpm php-curl php-gd php-intl php-mbstring php-soap php-xml php-zip php-mysqli apt-transport-https curl -y

wget https://wordpress.org/latest.zip
