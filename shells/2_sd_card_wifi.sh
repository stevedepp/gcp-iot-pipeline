#!/bin/bash

echo 'files in the boot directory of the SD card before file transfer'

ls /Volumes/boot

echo 'copying blank "ssh" file to boot directory of SD card'

cp ./rpi/ssh /Volumes/boot

echo 'copying "wpa_supplicant.conf" file to boot directory of SD card'

cp ./rpi/wpa_supplicant.conf /Volumes/boot

echo 'files in the boot directory of the SD card after file transfer'

ls /Volumes/boot

echo 'wpa_supplicant.conf file has generic settings for wifi network name and password.  amend those two items and cntrl-o, return, cntrl-x will complete setup.  there are 2 wifi network setups included in this wpa_supplicant.conf.  if you need 1 only, delete the other.  if you need more than 2 copy and paste.'

nano /Volumes/boot/wpa_supplicant.conf

echo 'please safely eject the SD card, place it into the UNPOWERED raspberrypi. Then plug power cord into the raspberrypi, and wait A FEW MINUTES while initial boot occurs.  the ssh and wp_supplicant.conf files are being transfered to their proper directories.  during this process, the blank ssh file enables headless operation and ssh connection.  when the green light stops flashing, try to "ping raspberrypi.local" and stop that with cntrl-c if successful.'
