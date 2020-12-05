#!/bin/bash

echo 'updating the raspian os'

sudo apt-get update

echo 'upgrading the raspian os; get some coffee ... this times some time'

sudo apt-get upgrade

echo 'the following steps can be achieved via GUI by executing "sudo raspi config GUI"'

echo 'installing the i2c bus tools'

sudo apt-get install i2c-tools libi2c-dev python-smbus

echo 'inserting the "i2c-dev" line into the "/etc/modules" file'

sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules

echo 'uncommenting the "dtparam=i2c_arm=on" parameter setting in "/boot/config.txt" file that turns on the i2c bus'

sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt

echo 'setting the timezone to US Eastern; this could be an argument to this shell script'

sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime

echo 'creating a virtual environment directory ".venv" which is activated manually after reboot'

python3 -m venv .venv

echo 'rebooting the raspberrypi'

sudo reboot

echo 'the raspberrypi is rebooting now.  when the green light stops flashing, follow the manual step to source the virtual environment, then execute the next shell script  "4_test_sensor_gcloud_install_setup_dependencies_run_PROJECT.sh".'
