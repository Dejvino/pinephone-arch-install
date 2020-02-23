#!/bin/bash
#
# Cleanup
#
# Remove any previous files, unmount drives.
#

source common.sh

printInfo "Starting cleanup."
printInfo

printInfo "Removing rootfs archive"
[ -e $ROOTFS_ARCHIVE ] && rm -rf $ROOTFS_ARCHIVE

printInfo "Removing kernel archive"
[ -e $KERNEL_ARCHIVE ] && rm -rf $KERNEL_ARCHIVE

printInfo "Removing extracted kernel"
[ -e $KERNEL_DIR ] && rm -rf $KERNEL_DIR

printInfo "Unmounting boot and root."
[ -e root/boot ] && sudo umount root/boot
[ -e root ] && sudo umount root
rm -rf root

printInfo
printInfo "Finished!"

