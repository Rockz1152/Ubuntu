#!/bin/bash

## Setup Script for Ubuntu 22.04+
## https://github.com/Rockz1152/Ubuntu
## curl -sL https://raw.githubusercontent.com/Rockz1152/Ubuntu/main/ubuntu_setup.sh | sudo /bin/bash

function checkOS() {
    echo "Checking OS"
    if [ "$(lsb_release -is)" == "Ubuntu" ]; then
        version=$(lsb_release -sr)
        if (( $(echo "$version < 22.04" | bc -l) )); then
            echo "-Your version of Ubuntu ($version) is not supported."
            echo "-Please use Ubuntu 22.04 Jammy Jellyfish or newer."
            exit 1
        fi
    else
        echo "-Looks like you're running this script on an unsupported system."
        exit 1
    fi
}

function checkRoot() {
    if [ "${EUID}" -ne 0 ]; then
        echo "You need to run this script as root"
        exit 1
    fi
}

function sshMotd() {
    if [ -f /etc/pam.d/sshd ]; then
        echo 'Turning off SSH motd'
        sed -i 's/session    optional     pam_motd.so/# session    optional     pam_motd.so/g' /etc/pam.d/sshd
        sed -i 's/PrintMotd yes/PrintMotd no/g' /etc/ssh/sshd_config
    else
        echo "Error: /etc/pam.d/sshd not found."
    fi
}

function disablePRO() {
    echo "Disabling Ubuntu Pro"
    if [ -f /etc/apt/apt.conf.d//20apt-esm-hook.conf ]; then
        dpkg-divert --divert /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak --rename --local /etc/apt/apt.conf.d/20apt-esm-hook.conf > /dev/null 2>/dev/null
    fi
}

function removePackages() {
    echo "Removing unwanted packages"
    export DEBIAN_FRONTEND=noninteractive
    apt-get -q -y autoremove --purge cloud-init multipath-tools snapd landscape-common > /dev/null 2>/dev/null
    rm -rf /etc/cloud
}

function installUpdates() {
    echo "Upgrading packages"
    export DEBIAN_FRONTEND=noninteractive
    echo '-Running apt-update'
    apt-get -q update > /dev/null 2>/dev/null
    echo '-Running apt-upgrade'
    apt-get -q -y dist-upgrade > /dev/null 2>/dev/null
    echo '-Running autoremove'
    apt-get -q -y autoremove --purge > /dev/null 2>/dev/null
}

function installPackages() {
    echo 'Installing packages'
    export DEBIAN_FRONTEND=noninteractive
    packages=(
    'ncdu'
    'zip'
    'unzip'
    'p7zip-full'
    'unrar-free'
    'neofetch'
    )

    # Check for VMware
    if [ $(systemd-detect-virt) == "vmware" ]; then
        packages+=("open-vm-tools")
    fi

    # Check for QEMU
    if [[ $(systemd-detect-virt) == "qemu" || $(systemd-detect-virt) == "kvm" ]]; then
        packages+=("qemu-guest-agent")
    fi

    # Install software
    for i in "${packages[@]}"
    do
        echo "-$i"
        if [[ $(dpkg-query -W -f='${Status}' "$i" 2>/dev/null | grep -c "ok installed") == 0 ]]; then
            apt-get -q -y install "$i" > /dev/null 2>/dev/null
            # Verify install
            if [[ $(dpkg-query -W -f='${Status}' "$i" 2>/dev/null | grep -c "ok installed") == 0 ]]; then
                echo "!!! $i failed to install"
            fi
        fi
    done
}

function checkReboot() {
    echo ""
    echo "Done"
    if [ -f /var/run/reboot-required ]; then
        echo "- A reboot is required, please restart the system"
        echo "- Run: sudo reboot"
    fi
}

checkOS
checkRoot
sshMotd
disablePRO
removePackages
installUpdates
installPackages
checkReboot
