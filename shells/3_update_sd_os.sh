#!/bin/bash

sudo apt-get update

sudo apt-get upgrade

sudo apt-get install i2c-tools libi2c-dev python-smbus

sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules

sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt

sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime

python3 -m venv .venv

sudo reboot

echo 'the raspberrypi is rebooting now.  when the green light stops flashing execute the next shell: "4_caller_PROJECT.sh".'
