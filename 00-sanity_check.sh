#!/bin/bash
#
# Installation Scripts Sanity Check
#
# Checks the current environment before doing any real work.
#

echo "Sanity check starting..."

[ -f common.sh ] \
    && echo "common.sh ... found" \
    || { echo "File 'common.sh' not found in this directory. Change directory and try again." ; exit 1; }

source common.sh

printInfo
printInfo "Checking the environment:"

FREE_SPACE=`df -P . | tail -1 | awk '{print $4}'`
[ $FREE_SPACE -gt 4000000 ] \
    && printInfo "free disk space > 4 GB ... OK" \
    || failure "Not enough disk space. Have at least 4 GB."

ping -c 1 github.com >> /dev/null
[ $? -eq 0 ] \
    && printInfo "Internet connection ... OK" \
    || failure "Internet connection failed."

rm -rf test.txt && touch test.txt && rm test.txt
[ $? -eq 0 ] \
    && printInfo "Local directory Read/Write permissions ... OK" \
    || failure "Could not read or write to this directory. Check your permissions."

[ -e $SD_CARD_DEVICE ] \
    && printInfo "SD Card device '$SD_CARD_DEVICE' exists ... OK" \
    || failure "SD Card device '$SD_CARD_DEVICE' not found. Check that it is connected or update the config.sh file."

printInfo
printInfo "Checking commands:"

command -v dd >> /dev/null \
    && printInfo "dd exists ... OK" \
    || failure "dd not found. All hope is lost."

command -v mkimage >> /dev/null \
    && printInfo "mkimage exists ... OK" \
    || failure "mkimage not found. Install uboot-tools package."

command -v sudo >> /dev/null \
    && printInfo "sudo exists ... OK" \
    || failure "sudo not found. Install sudo package."

command -v sync >> /dev/null \
    && printInfo "sync exists ... OK" \
    || failure "sync not found."


printInfo
printInfo "All tests passed. You're ready to go!"
printInfo "Execute the next script in the sequence and follow the instructions."

