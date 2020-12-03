#!/bin/bash

PROJECT=$1
echo $PROJECT
sudo i2cdetect -y 1

export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update && sudo apt-get install google-cloud-sdk

gcloud auth activate-service-account test123depp@appspot.gserviceaccount.com --key-file=test123depp-d4de252b7a56.json

#gcloud auth login

gcloud config set project $PROJECT

export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')

gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT

gcloud config configurations describe default

gcloud alpha billing accounts list

gcloud projects list

gcloud config get-value core/project

pip install tendo

pip install --upgrade google-cloud-pubsub

pip3 install --upgrade oauth2client

pip3 install datetime

pip3 install adafruit-circuitpython-bmp280

mkdir -p ~/credentials

gsutil cp gs://iot-analytics-depp/key.json ~/credentials/

export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/key.json

git clone https://github.com/stevedepp/gcp-iot-pipeline.git

cd gcp-iot-pipeline/rpi

python3 iot-data-pipeline.py $PROJECT