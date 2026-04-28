#!/bin/bash

## Setup Script for Ubuntu 22.04+
## https://github.com/Rockz1152/Ubuntu
## curl -sL https://raw.githubusercontent.com/Rockz1152/Ubuntu/main/ubuntu_setup.sh | sudo /bin/bash

# Source our OS related variables
if [ -r /etc/os-release ]; then
    source /etc/os-release
    # Convert release to integer
    version_num=${VERSION_ID/./}
else
    echo "Unknown configuration found, exiting..."; exit 1;
fi

function checkOS() {
    echo ""
    echo "Checking OS"
    if [ ${NAME} == "Ubuntu" ]; then
        supported="22.04"
        if [[ $(awk "BEGIN {print (${VERSION_ID} < ${supported})}") == 1 ]]; then
            echo "- Your version of Ubuntu ${VERSION_ID} is not supported."
            echo "- Please use Ubuntu 22.04 Jammy Jellyfish or newer."
            exit 1
        fi
    else
        echo "- Looks like you're running this script on an unsupported system."
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
    if [ -f /etc/apt/apt.conf.d/20apt-esm-hook.conf ]; then
        dpkg-divert --divert /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak --rename --local /etc/apt/apt.conf.d/20apt-esm-hook.conf > /dev/null 2>/dev/null
        echo -n | sudo tee /etc/apt/apt.conf.d/20apt-esm-hook.conf > /dev/null 2>/dev/null
        chattr +i /etc/apt/apt.conf.d/20apt-esm-hook.conf > /dev/null 2>/dev/null
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
    echo '- Running apt-update'
    apt-get -q update > /dev/null 2>/dev/null
    echo '- Running apt-upgrade'
    apt-get -q -y dist-upgrade > /dev/null 2>/dev/null
    echo '- Running autoremove'
    apt-get -q -y autoremove --purge > /dev/null 2>/dev/null
}

function installPackages() {
    echo 'Installing packages'
    export DEBIAN_FRONTEND=noninteractive
    packages=(
    'ncdu'
    'zstd'
    'zip'
    'unzip'
    'unrar-free'
    )

    # 7zip
    if [[ $version_num -lt "2604" ]]; then
        packages+=('p7zip-full')
    else
        packages+=('7zip')
    fi

    # Neofetch/Fastfetch
    if [[ $version_num -lt "2604" ]]; then
        packages+=('neofetch')
    else
        packages+=('fastfetch')
    fi

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
        echo "- $i"
        if [[ $(dpkg-query -W -f='${Status}' "$i" 2>/dev/null | grep -c "ok installed") == 0 ]]; then
            apt-get -q -y install "$i" > /dev/null 2>/dev/null
            # Verify install
            if [[ $(dpkg-query -W -f='${Status}' "$i" 2>/dev/null | grep -c "ok installed") == 0 ]]; then
                echo "!!! $i failed to install"
            fi
        fi
    done

    # Swap Neofetch for Fastfetch
    if [[ $version_num -ge "2604" ]]; then

        # Neofetch install check
        if dpkg -s neofetch >/dev/null 2>&1; then
            echo 'Patching Neofetch to Fastfetch'
            # Remove Neofetch and dependencies
            apt-get autoremove -y --purge neofetch > /dev/null 2>/dev/null
        fi

        # Make sure Fastfetch is installed
        if ! dpkg -s fastfetch >/dev/null 2>&1; then
            apt-get -q -y install fastfetch > /dev/null 2>/dev/null
        fi

        # Link Neofetch muscle memory to Fastfetch
        # Checks if symlink exists and creates if not
        if ! [ -L /usr/bin/neofetch ]; then
            ln -s /usr/bin/fastfetch /usr/bin/neofetch
        fi

    fi #End Neofetch swap

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
