#!/bin/bash

git clone https://github.com/stevedepp/gcp-iot-pipeline.git
cd gcp-iot-pipeline
ls /Volumes/boot
cp ./rpi/ssh /Volumes/boot
cp ./rpi/wpa_supplicant.conf /Volumes/boot
ls /Volumes/boot
nano /Volumes/boot/wpa_supplicant.conf

echo 'please safely eject the SD card, place it into the raspberrypi and wait a few minutes while initial boot occurs.  the ssh and wp_supplicant.conf files are being transfered to their proper directories.  during this process, the blank ssh file enables headless operation and ssh connection.  when the green light stops flashing, try to "ping raspberrypi.local" and stop that with cntrl-c if successful.'
