#!/bin/bash

pip install tendo

pip install --upgrade google-cloud-pubsub

pip3 install --upgrade oauth2client

pip3 install datetime

pip3 install adafruit-circuitpython-bmp280

export PROJECT=test123depp

mkdir -p ~/credentials

gsutil cp gs://iot-analytics-depp/key.json ~/credentials/

export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/key.json

python3 iot-data-pipeline.py $PROJECT
