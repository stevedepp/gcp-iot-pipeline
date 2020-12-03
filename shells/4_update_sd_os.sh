#!/bin/bash

ssh pi@raspberrypi.local
    yes
    raspberry

sudo apt-get install i2c-tools libi2c-dev python-smbus

sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules

sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt

sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime

sudo reboot
