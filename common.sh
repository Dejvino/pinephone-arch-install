#!/bin/bash
#
# Common functions and utils for the installation scripts
#

#
# Common functions
#
printError() {
    echo "ERROR: $*" >> /dev/stderr
}

printWarning() {
    echo "WARNING: $*"
}

printNotice() {
    echo "NOTICE: $*"
}

printInfo() {
    echo "$*"
}

failure() {
    printError $*
    exit 1
}

#
# Common definitions
#
ROOTFS_URL=http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
ROOTFS_ARCHIVE=rootfs.tar.gz
 
KERNEL_URL=https://xff.cz/kernels/5.6/pp.tar.gz
KERNEL_ARCHIVE=kernel.tar.gz
KERNEL_DIR=kernel

[ -z ${EDITOR+x} ] && command -v vim >> /dev/null && EDITOR=vim
[ -z ${EDITOR+x} ] && command -v nano >> /dev/null && EDITOR=nano
[ -z ${EDITOR+x} ] && command -v pico >> /dev/null && EDITOR=pico
[ -z ${EDITOR+x} ] && command -v vi >> /dev/null && EDITOR=vi
[ -z ${EDITOR+x} ] && EDITOR=cat

[ -f config.sh ] || failure "File 'config.sh' not found. Create it from the template 'config.sh.default' and try again."
source config.sh

export ROOTFS_URL
export ROOTFS_ARCHIVE
export KERNEL_URL
export KERNEL_ARCHIVE
export KERNEL_DIR
export EDITOR

