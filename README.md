# Phantom / PM3 mass storage gadget

This repository contains the scripts and OS images to configure a Phantom or PM3 module as a mass storage gadget
OR flash the EMMC device directly.

This requires a 32-bit Linux ARM OS.

## Installation
The script requires access to USB devices. This can either be run as root or access to all users can be granted for this device.
```
sudo cp etc_udev_rules.d_persistent-usb.rules /etc/udev/rules.d/persistent-usb.rules
sudo systemctl restart udev
```

USB device-mode boot is selected in the ROM if the USB2 VBUS is connected when the SoC is powered on.

* Power off the DUT (Phantom/PM3) device and remove all USB cables.
* Connect the USB cable from the host to the DUT.
* Power on the DUT.
* Run `./msd.sh` or `./burn.sh os.img`

## Mass storage mode

After about 20 seconds of running `msd.sh` the mass storage gadget should be available and will typically appear as `/dev/sda`. The
script exits once the new Linux multi-function USB device is detected. It is then possible to write to the new block-device.

```
Initialising bootloader
Loading MSD gadget
....
Running MSD gadget
Waiting for USB gadget
```

### Writing the OS image
The OS image can be written to the new block-device using dd or other disk imaging commands. It's important to call sync afterwards to ensure that data is flushed.
```
sudo dd if=os.img of=/dev/sda bs=1M status=progress
sync
```

## Flashing the EMMC image (burn.sh)
The `burn.sh` script writes raw disk image to the EMMC without exposing it as a mass storage device. This is likely to be quicker than using the mass storage gadget but does not allow the image to be mounted by the host i.e. it's a write only mechanism.

Usage:
```./burn.sh os.img```

Example output:
```
Initialising bootloader
..
Select EMMC
Flashing EMMC
MSG[DNL]Amlogic USB DNL tool: V[2.6.4] at May 12 2022
...
cmd[oem mwrite 0x20fb0400 normal mmc 1 0x0]
response:
OKAY [  0.048s]
media writing [mwrite:verify=addsum]...
Downloading...
[100%/  527MBytes] 0ms
MSG[DNL]mwrite finish
OKAY [ 48.522s]
finished. total time: 48.570s
```
