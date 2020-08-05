#!/bin/bash
#
# Format SD Card
#
# Prepares SD Card partition table and formats it.
#
# Source: https://xnux.eu/howtos/install-arch-linux-arm.html
#

source common.sh

printInfo "Time to prepare the SD Card."

printInfo
printInfo "Running lsblk for your convenience:"
lsblk

printInfo
printInfo "Target device: $SD_CARD_DEVICE"
[ ! -e $SD_CARD_DEVICE ] && failure "Target device not found. Did you update the config file? Is the device connected?"
printInfo "...boot partition: $SD_CARD_BOOT"
printInfo "...root partition: $SD_CARD_ROOT"

read -p "Do you want to continue and format this device? [y/N]: "
if [[ ! $REPLY =~ ^[yY]$ ]]; then
    failure "Terminating."
fi

read -p "This will ERASE the device completely. Are you sure? [y/N]: "
if [[ ! $REPLY =~ ^[yY]$ ]]; then
    failure "Terminating."
fi

printInfo
printInfo "Clearing start of device..." # to remove previous MBR and U-Boot data
sudo dd if=/dev/zero of=$SD_CARD_DEVICE bs=512 count=1024 \
	|| failure "Could not clear the start of $SD_CARD_DEVICE."
printInfo "Clearing end of device..." # to remove previous GPT data
sudo dd if=/dev/zero of=$SD_CARD_DEVICE bs=512 seek=$(( $(blockdev --getsz $SD_CARD_DEVICE) - 1024 )) count=1024 \
	|| failure "Could not clear the end of $SD_CARD_DEVICE."
printInfo "Done."

printInfo
printInfo "Partitioning started..."
sudo sfdisk $SD_CARD_DEVICE <<EOF
label: dos
unit: sectors

4MiB,252MiB,
256MiB,,
EOF
if [ $? -ne 0 ]; then
    failure "Could not write partition table."
fi
printInfo "Partitioning done."

sleep 0.5
sync

[ ! -e $SD_CARD_BOOT ] && failure "Boot $SD_CARD_BOOT partition not found. Did partitioning fail?"
[ ! -e $SD_CARD_ROOT ] && failure "Root $SD_CARD_ROOT partition not found. Did partitioning fail?"

printInfo
printInfo "Formatting boot partition..."
sudo mkfs.vfat -n BOOT $SD_CARD_BOOT || failure "Could not format root partition."
printInfo "Formatting root partition..."
sudo mkfs.f2fs -f -l ROOT $SD_CARD_ROOT || failure "Could not format boot partition."
printInfo "Done."

stageFinished "Run the step 03 to flash a root filesystem."

