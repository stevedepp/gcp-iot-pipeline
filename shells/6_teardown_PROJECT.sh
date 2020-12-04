#!/bin/bash

PROJECT=$1

gcloud config set project $PROJECT

bq --location US rm -f --table weatherData.weatherDataTable

#gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher

#gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

#gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

gcloud pubsub topics delete weatherdata

bq --location US rm -f --dataset weatherData

gcloud functions delete iot_weather

gsutil rm -r gs://iot-analytics-depp

rm -r ~/$PROJECT

ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline
