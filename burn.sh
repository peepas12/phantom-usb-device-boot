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

[ -n "${1}" ] || die "Usage: $(basename "$0") os.img"
image_file="${1}"
[ -f "${image_file}" ] || die "EMMC image \"${image_file}\" not found"

echo "Initialising bootloader"
echo -n "."
run_adnl bl1_boot -f bl33
echo -n "."
run_adnl bl2_boot -f bl33
echo

run_adnl oem "setenv bootargs"
echo "Select EMMC"
run_adnl oem "disk_initial 1"
echo "Flashing EMMC"
run_adnl partition -m mmc -p 1 -f "${image_file}"
