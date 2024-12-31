#!/bin/bash

## https://github.com/Rockz1152/Ubuntu
## This script identifies and removes unused Linux kernel packages while ensuring that the 
## current running kernel and essential generic packages are preserved.
## List installed kernel files: dpkg --list | egrep -i --color 'linux-image|linux-headers|linux-modules'

# Get the current running kernel version
current_kernel=$(uname -r)

# Extract the base version of the current kernel (e.g., "5.15.0-130" from "5.15.0-130-generic")
current_kernel_base=${current_kernel%-generic}

# List all installed kernel packages
kernel_packages=$(dpkg --list | grep -E -i 'linux-image|linux-headers|linux-modules' | awk '{print $2}')

# Initialize an array for unused kernels
unused_kernels=()

echo "Current kernel: $current_kernel"
echo "Current kernel base: $current_kernel_base"

# Iterate through kernel packages to find unused ones
for package in $kernel_packages; do
    if [[ $package != *"$current_kernel"* && $package != *"$current_kernel_base"* && \
          $package != "linux-image-generic" && $package != "linux-headers-generic" ]]; then
        unused_kernels+=("$package")
    fi
done

if [[ ${#unused_kernels[@]} -eq 0 ]]; then
    echo "No unused kernels found to remove."
    exit 0
fi

# Confirm with the user before removing
echo "The following unused kernel packages will be removed:"
printf "%s\n" "${unused_kernels[@]}"
read -p "Do you want to proceed? (y/n): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Remove the unused kernel packages
sudo apt-get remove --purge -y "${unused_kernels[@]}"

# Clean up residual files
sudo apt-get autoremove -y
sudo apt-get autoclean

# Update GRUB bootloader
sudo update-grub

echo "Unused kernels have been removed, and GRUB has been updated."
