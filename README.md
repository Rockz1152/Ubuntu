# Ubuntu
Setup script for Ubuntu Server with support for:
- 26.04 - Resolute Raccoon
- 24.04 - Noble Numbat
- 22.04 - Jammy Jellyfish

## Summary
- Turns off SSH MotD
- Disables Ubuntu Pro notifications
- Removes unwanted packages
- Runs apt update
- Installs base software
- Installs guest tools if running a virtual machine

## Usage
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/Rockz1152/Ubuntu/main/ubuntu_setup.sh)"
```

## Kernel Cleanup Script
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/Rockz1152/Ubuntu/main/kernel-clean.sh)"
```
