#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0} is not running as root. please run as root."
    exit 1
fi

dirName=$(dirName "${0}")

