#!/bin/bash

set -e

src=$(cd "$(dirname "$0")" && pwd)
adnl="${src}/adnl"

if (uname -m | grep -q x86); then
   adnl="${src}/adnl_x86"
fi

die() {
   echo "$@" >&2
   exit 1
}

run_adnl() {
   if [ "${1}" = "oem" ]; then
      # OEM commands don't return a valid error status
      "${adnl}" "$@" > /dev/null 2>&1 || true
   elif [ "${1}" = "partition" ]; then
      "${adnl}" "$@"
   else
      "${adnl}" "$@" > /dev/null 2>&1 || die "ERROR: $*"
   fi
}

echo "Initialising bootloader"
echo -n "."
run_adnl bl1_boot -f bl33
echo -n "."
run_adnl bl2_boot -f bl33
echo

echo "Loading MSD gadget"
run_adnl oem "setenv bootargs console=ttyS0,921600 earlycon=aml_uart,0xfe07a000 loglevel=8 jtag=apao"
echo -n "."
run_adnl partition -M mem -P  0x100000 -F phantom.dtb
echo -n "."
run_adnl partition -M mem -P  0x200000 -F Image
echo -n "."
run_adnl partition -M mem -P 0x8000000 -F ramdisk
echo -n "."
echo

echo "Running MSD gadget"
run_adnl oem "booti 0x200000 0x8000000 0x100000"

echo "Waiting for USB gadget"
while ! lsusb | grep -q "1d6b:0104"; do 
   echo -n .
   sleep 0.2
done
