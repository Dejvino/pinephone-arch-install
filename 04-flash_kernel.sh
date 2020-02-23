#!/bin/bash
#
# Flash Kernel to SD Card
#
# Prepares SD Card contents by installing the kernel on it.
#
# Source: https://xnux.eu/howtos/install-arch-linux-arm.html
#

source common.sh

printInfo "Time to flash the kernel onto the SD Card."
printInfo

printInfo "Extracting kernel archive:"
[ -f $KERNEL_ARCHIVE ] || failure "Could not find kernel archive $KERNEL_ARCHIVE. Did you run all the previous steps?"

[ -e $KERNEL_DIR ] && rm -rf $KERNEL_DIR
mkdir -p $KERNEL_DIR || failure "Could not create a directory '$KERNEL_DIR' to extract the archive into."
tar xfz $KERNEL_ARCHIVE --strip-components=1 -C $KERNEL_DIR || failure "Could not extract the kernel archive."

printInfo "Done."
printInfo
printInfo "Entering $KERNEL_DIR directory"
cd $KERNEL_DIR
printInfo
printInfo "You can now modify the boot config."
printInfo "E.g. remove 'quiet' and 'loglevel' parameters to make the boot more verbose."

read -p "Do you want to edit boot config now? [y/N]: "
if [[ $REPLY =~ ^[yY]$ ]]; then
    printInfo "Opening editor $EDITOR"
    $EDITOR boot.cmd
    printInfo "Editor closed."
fi

printInfo
printInfo "Building boot script:"
mkimage -A arm64 -T script -C none -d boot.cmd boot.scr
[ $? -eq 0 ] \
    && printInfo "Done." \
    || failure "Failed generating boot.scr"

printInfo
printInfo "Flashing bootloader to SD Card $SD_CARD_DEVICE:"
read -p "Are you sure you want to continue? [Y/n]: "
[[ $REPLY =~ ^[nN]$ ]] && failure "Terminating."
printInfo "Flashing..."
sudo dd if=uboot.bin of=$SD_CARD_DEVICE bs=1024 seek=8 \
    && printInfo "Done." \
    || failure "Could not flash the bootloader."

printInfo
printInfo "Syncing..."
sync
sleep 2

printInfo
printInfo "Mounting SD Card root $SD_CARD_ROOT and boot $SD_CARD_BOOT partitions:"
if [ -e ../root ]; then
    rm -rf ../root || failure "Could not remove preexisting root directory. Is it still mounted? Is it yours?"
fi
mkdir ../root || failure "Could not create root directory mounting point."
sudo mount $SD_CARD_ROOT ../root \
    && printInfo "root done." \
    || failure "Could not mount $SD_CARD_ROOT."
sudo mount $SD_CARD_BOOT ../root/boot \
    && printInfo "boot done." \
    || failure "Could not mount $SD_CARD_BOOT."

printInfo
printInfo "Copying bootloader to boot partition $SD_CARD_BOOT:"
read -p "Are you sure you want to continue? [Y/n]: "
[[ $REPLY =~ ^[nN]$ ]] && failure "Terminating."
sudo cp boot.scr ../root/boot/ && sudo cp board.itb ../root/boot/ \
    && printInfo "Done." \
    || failure "Copy failed. Is the SD Card mounted correctly?"

printInfo
printInfo "Copying kernel modules to root partition $SD_CARD_ROOT into /lib:"
sudo cp -R -n modules/lib/modules ../root/lib \
    && printInfo "Done." \
    || failure "Copy failed. Is the SD Card mounted correctly?"

printInfo
printInfo "Unmounting SD Card:"
sudo umount ../root/boot \
    && printInfo "boot done." \
    || failure "Could not umount $SD_CARD_BOOT."
sudo umount ../root \
    && printInfo "root done." \
    || failure "Could not umount $SD_CARD_ROOT."
rm -rf ../root || failure "Could not remove root mount point."

printInfo
printInfo "Finished!"

