#!/bin/bash
#
# Flash Root FS to SD Card
#
# Prepares SD Card contents by populating the Root FS on it.
#
# Source: https://xnux.eu/howtos/install-arch-linux-arm.html
#

source common.sh

printInfo "Time to flash the rootfs onto the SD Card."
printInfo

[ ! -f $ROOTFS_ARCHIVE ] && failure "Missing rootfs archive $ROOTFS_ARCHIVE. Did you run the download step?"
[ ! -e $SD_CARD_BOOT ] && failure "Boot $SD_CARD_BOOT partition not found. Is the device connected? Did you partition it?"
[ ! -e $SD_CARD_ROOT ] && failure "Root $SD_CARD_ROOT partition not found. Is the device connected? Did you partition it?"

if [ -e ./root ]; then
    rm -rf ./root || failure "Could not remove preexisting root directory. Is it still mounted? Is it yours?"
fi
mkdir ./root || failure "Could not create root directory mounting point."

printInfo "Mounting $SD_CARD_ROOT into ./root"
sudo mount $SD_CARD_ROOT ./root || failure "Could not mount the root partition."
sudo mkdir -p ./root/boot || failure "Could not create a boot directory."
printInfo "Mounting $SD_CARD_BOOT into ./root/boot"
sudo mount $SD_CARD_BOOT ./root/boot || failure "Could not mount the boot partition."
printInfo "Storage mounted."

printInfo
printInfo "Time to extract the rootfs into ./root"
read -p "Do you want to continue? [Y/n]: "
if [[ $REPLY =~ ^[nN]$ ]]; then
    sudo umount ./root/boot
    sudo umount ./root
    failure "Terminating."
fi

printInfo "This will take a while without showing any output. Please be patient."
printInfo "Extracting..."
sudo bsdtar -xpf $ROOTFS_ARCHIVE -C ./root || failure "Could not extract the rootfs into ./root"
printInfo "Rootfs extracted."

printInfo
printInfo "Populating ./root/etc/fstab"
sudo bash <<EOF
echo /dev/mmcblk0p1 /boot vfat rw 0 1 > ./root/etc/fstab
echo /dev/mmcblk0p2 / f2fs rw,relatime 0 0 >> ./root/etc/fstab
EOF
if [ $? -ne 0 ]; then
    failure "Could not populate fstab."
fi
printInfo "Done."

printInfo
printInfo "Unmounting..."
sudo umount ./root/boot || failure "Could not unmount ./root/boot"
sudo umount ./root || failure "Could not unmount ./root"
printInfo "Done."

sync

printInfo
printInfo "Rootfs flashed!"
