#!/bin/bash

### Work in progress ###
# Make sure curl is isntalled before trying to run script
# sudo apt install -y curl
# curl -sL https://gist.githubusercontent.com/Rockz1152/71d20c66e25979e15dcd608289ecf03f/raw/ubuntu_setup.sh | /bin/bash -s

function checkOS() {
    echo "Checking OS"
    if [[ -e /etc/debian_version ]]; then
        source /etc/os-release
        if [[ ${ID} == "debian" || ${ID} == "raspbian" ]]; then
            if [[ ${VERSION_ID} -lt 9 ]]; then
                echo "Your version of Debian (${VERSION_ID}) is not supported. Please use Debian 9 Stretch or later."
                exit 1
            fi
        fi
    else
        echo "Looks like you are running this script on an unsupported system."
        exit 1
    fi
}

function checkRoot() {
    if [ "${EUID}" -ne 0 ]; then
        echo "You need to run this script as root"
        exit 1
    fi
}

checkOS
checkRoot
