#!/bin/bash

PROJECT=$1

gcloud config set project $PROJECT

gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher


gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

#gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

gcloud pubsub topics delete weatherdata

gcloud functions delete iot_weather

gsutil rm -r gs://iot-analytics-depp

rm -r ~/$PROJECT

bq --location US rm -f --dataset weatherData


bq --location US rm -f --table weatherData.weatherDataTable


ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline
