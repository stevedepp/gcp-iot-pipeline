#!/bin/bash

PROJECT=$1

gcloud config set project $PROJECT

bq --location US rm -f --table weatherData.weatherDataTable

gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher

export A=$(gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com | awk 'NR==3{print $1}')
until [ -z "$A" ];
do
export A=$(gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com | awk 'NR==2{print $1}')
gcloud iam service-accounts keys delete $A --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com;
export A=$(gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com | awk 'NR==3{print $1}')
done

gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

export A=$(gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com | awk 'NR==3{print $1}')
until [ -z "$A" ];
do
export A=$(gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com | awk 'NR==2{print $1}')
gcloud iam service-accounts keys delete $A --iam-account $PROJECT@appspot.gserviceaccount.com
export A=$(gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com | awk 'NR==3{print $1}')
done

gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com

gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

gcloud pubsub topics delete weatherdata

bq --location US rm -f --dataset weatherData

gcloud functions delete iot_weather

gsutil rm -r gs://iot-analytics-depp

#rm -r ~/$PROJECT

#ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline

