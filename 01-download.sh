#!/bin/bash
#
# Download
#
# Fetches Arch Linux ARM root filesystem, bootloader and kernel.
#
# Source: https://xnux.eu/howtos/install-arch-linux-arm.html
#

source common.sh

printInfo "Time to download all the required components:"
printInfo " - root filesystem"
printInfo " - bootloader and kernel"
printInfo

if [ -f $ROOTFS_ARCHIVE ]
then
    printInfo "Found Arch Linux ARM rootfs, skipping download."
    printInfo " (You can run 99-cleanup.sh or delete the file '$ROOTFS_ARCHIVE' to force an update.)"
else
    printInfo "Downloading Arch Linux ARM from $ROOTFS_URL:"
    wget $ROOTFS_URL -O $ROOTFS_ARCHIVE
    [ $? -eq 0 ] \
        && printInfo "Done." \
        || failure "Failed to download."
fi

printInfo

if [ -f $KERNEL_ARCHIVE ]
then
    printInfo "Found PinePhone Kernel, skipping download."
    printInfo " (You can run 99-cleanup.sh or delete the file '$KERNEL_ARCHIVE' to force an update.)"
else
    printInfo "Downloading PinePhone Kernel from $KERNEL_URL:"
    wget $KERNEL_URL -O $KERNEL_ARCHIVE
    [ $? -eq 0 ] \
        && printInfo "Done." \
        || failure "Failed to download."
fi

stageFinished "Run step 02 to continue."

