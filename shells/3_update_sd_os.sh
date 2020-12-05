#!/bin/bash

sudo apt-get update

sudo apt-get upgrade

sudo apt-get install i2c-tools libi2c-dev python-smbus

sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules

sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt

sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime

python3 -m venv .venv

sudo reboot

echo 'the raspberrypi is rebooting now.  when the green light stops flashing, follow the manual step to source the virtual environment, then execute the next shell script  "4_test_sensor_gcloud_install_setup_dependencies_run_PROJECT.sh".'
