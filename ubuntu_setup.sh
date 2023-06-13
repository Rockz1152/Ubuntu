#!/bin/bash
## curl -sL https://raw.githubusercontent.com/Rockz1152/Ubuntu/main/ubuntu_setup.sh | /bin/bash -s

function checkOS() {
    echo "Checking OS"
    if [[ -e /etc/lsb_release ]]; then
        source /etc/os-release
        if [[ ${ID} == "ubuntu" ]]; then
            if [[ ${VERSION_ID} -lt 22 ]]; then
                echo "Your version of Ubuntu (${VERSION_ID}) is not supported. Please use Ubuntu 22.04 Jammy Jellyfish or newer."
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
