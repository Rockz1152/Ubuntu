# Ubuntu
Setup script for Ubuntu Server with support for:
- 22.04 - Jammy Jellyfish
- 20.04 - Focal Fossa

## Summary
- Turns off SSH MotD
- Disables Ubuntu Pro notifications
- Removes unwanted packages
- Runs apt update
- Installs base software
- Installs guest tools if running a virtual machine

## Usage
```
curl -sL https://raw.githubusercontent.com/Rockz1152/Ubuntu/main/ubuntu_setup.sh | sudo bash
```
