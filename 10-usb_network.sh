#!/bin/bash
#
# Install support for USB networking
#
# Adds a module for USB networking and sets up a local network.
#
# Source: https://xnux.eu/howtos/install-arch-linux-arm.html
#

source common.sh

printInfo "USB Networking"
printInfo


read -p "Do you want to install the network to the device? [Y/n]: "
if [[ ! $REPLY =~ ^[nN]$ ]]; then
    [ ! -e $SD_CARD_ROOT ] && failure "Root $SD_CARD_ROOT partition not found. Is the device connected? Did you partition it?"
    if [ -e ./root ]; then
        rm -rf ./root || failure "Could not remove preexisting root directory. Is it still mounted? Is it yours?"
    fi
    mkdir ./root || failure "Could not create root directory mounting point."

    printInfo "Mounting $SD_CARD_ROOT into ./root"
    sudo mount $SD_CARD_ROOT ./root || failure "Could not mount the root partition."
    printInfo "Done."

    printInfo
    printInfo "Adding autoloading of g_cdc to ./root/etc/modules-load.d/usb0.conf"
    read -p "Do you want to continue? [Y/n]: "
    if [[ $REPLY =~ ^[nN]$ ]]; then
        sudo umount ./root
        failure "Terminating."
    fi
    sudo bash <<EOF
echo g_cdc > ./root/etc/modules-load.d/usb0.conf
EOF
    if [ $? -ne 0 ]; then
        sudo umount ./root
        failure "Could not add the g_cdc module config file."
    fi
    printInfo "Done."

    printInfo
    printInfo "Adding usb0 network config file ./root/etc/systemd/network/usb0.network"
    sudo bash <<EOF
cat > ./root/etc/systemd/network/usb0.network <<EOM
[Match]
Name=usb0

[Network]
Address=10.0.0.2/24
Gateway=10.0.0.1
DHCP=no
EOM
EOF
    if [ $? -ne 0 ]; then
        sudo umount ./root
        failure "Could not add the usb0 network config file."
    fi
    printInfo "Done."

    read -p "Do you want to edit the config file now? [y/N]: "
    if [[ $REPLY =~ ^[yY]$ ]]; then
        printInfo "Opening editor $EDITOR"
        sudo $EDITOR ./root/etc/systemd/network/usb0.network
        printInfo "Editor closed."
    fi

    printInfo
    printInfo "Unmounting..."
    sudo umount ./root || failure "Could not unmount ./root"
    printInfo "Done."
fi

printInfo
read -p "Do you want to install the network to THIS computer? [Y/n]: "
if [[ ! $REPLY =~ ^[nN]$ ]]; then
    printInfo "Adding usb network config file to the host system in /etc/systemd/network/pp.network"
    sudo bash <<EOF
cat > /etc/systemd/network/pp.network <<EOM
[Match]
Name=changeme

[Network]
Address=10.0.0.1/24
DHCP=no
EOM
EOF
    printInfo "Done."

    printInfo
    printInfo "You still need to update the placeholder network device name."
    printInfo "See the output of 'ip addr show' to find the name:"
    ip addr show
    read -p "Do you want to edit the config file now? [y/N]: "
    if [[ $REPLY =~ ^[yY]$ ]]; then
        printInfo "Opening editor $EDITOR"
        sudo $EDITOR /etc/systemd/network/pp.network
        printInfo "Editor closed."
    fi

    printInfo
    printInfo "Restarting systemd-networkd for changes to take effect..."
    sudo systemctl restart systemd-networkd || failure "Could not restart the service."
    printInfo "Done."
fi

printInfo
printInfo "Finished!"
