#!/bin/bash

PROJECT=$1

echo '77 means the sensor is correct for this application and seen by the raspberrypi'

sudo i2cdetect -y 1

echo 'working on project: '$PROJECT

echo 'exporting an environment variable to match the gcloud sdk version with raspberrypi os.

export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

echo 'adding a line into google-cloud-sdk.list for where gcloud sdk packages are to be stored the location label is specific to version from previous command'

echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

echo 'adding google package repository public key so raspberrypi authorizes install'

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo 'repeating apt-get update which may not be needed and installing the gcloud sdk'

sudo apt-get update && sudo apt-get install google-cloud-sdk

echo 'first login is a bit cumbersome; follow the prompts.  resistance is futile.'

echo 'highlight the provided link and go to the URL, selecting email, athorizing, copy code and paste back into this terminal window'

gcloud auth login

echo 'configuring the default project '$PROJECT

gcloud config set project $PROJECT

echo 'obtaining the gcloud account number'

export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')

echo 'linking project '$PROJECT' with account '$ACCOUNT' for billing'

gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT

echo 'some useful information:'

echo 'current defaults in the configuration:'

gcloud config configurations describe default

echo 'current account numbers'

gcloud alpha billing accounts list

echo 'current projects in this account'

gcloud projects list

echo 'current default project; may seem redundant but it isnt'

gcloud config get-value core/project

echo 'installing tendo which is imported by the python based sensor controller iot-data-pipeline.py to check if a script is running more than once'

pip install tendo

echo 'installing the python packages for pubsub and oath2 and upgrade both packages'

pip install --upgrade google-cloud-pubsub

pip3 install --upgrade oauth2client

echo 'installing the datetime package for python'

pip3 install datetime

echo 'installing the adafruit libary for bmp280 which is circuitpython based'

pip3 install adafruit-circuitpython-bmp280

echo 'making a raspberrypi directory "~/credentials" to hold the pub-key.json'

mkdir -p ~/credentials

echo 'copying the pub-key.json from google cloud storage gs://iot-analytics-depp to ~/credentials/'

gsutil cp gs://iot-analytics-depp/pub-key.json ~/credentials/

echo 'exporting an environment variable representing path to pub-key.json which is referenced in execution of "credentials = GoogleCredentials.get_application_default()" found in "iot-data-pipeline.py"'

export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/pub-key.json

echo 'executing iot-data-pipeline.py for project '$PROJECT

python3 iot-data-pipeline.py $PROJECT
