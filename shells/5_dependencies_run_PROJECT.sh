#!/bin/bash

PROJECT=$1

pip install tendo

pip install --upgrade google-cloud-pubsub

pip3 install --upgrade oauth2client

pip3 install datetime

pip3 install adafruit-circuitpython-bmp280

mkdir -p ~/credentials

gsutil cp gs://iot-analytics-depp/pub-key.json ~/credentials/

export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/pub-key.json

python3 iot-data-pipeline.py $PROJECT
