#!/bin/bash
#
# Download
#
# Fetches Arch Linux ARM root filesystem, bootloader and kernel.
#
# Source: https://xnux.eu/howtos/install-arch-linux-arm.html
#

source common.sh

printInfo "Time to download all the required components: root filesystem, bootloader and kernel."

printInfo "Downloading Arch Linux ARM from $ROOTFS_URL:"
wget $ROOTFS_URL -O $ROOTFS_ARCHIVE
[ $? -eq 0 ] \
    && printInfo "Done." \
    || failure "Failed to download."

printInfo "Downloading PinePhone Kernel from $KERNEL_URL:"
wget $KERNEL_URL -O $KERNEL_ARCHIVE
[ $? -eq 0 ] \
    && printInfo "Done." \
    || failure "Failed to download."

printInfo "Downloads completed."

