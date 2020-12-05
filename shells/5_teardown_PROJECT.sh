#!/bin/bash

PROJECT=$1

echo 'project argument is: '$PROJECT

echo 'setting default project: '$PROJECT

gcloud config set project $PROJECT

echo 'removing binding of pubsub.publisher role to service account iot-weather-publisher for project '$PROJECT

gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher

echo 'deleting service account named "iot-weather-publisher" used by sensor to access and publish to pubsub topic for project '$PROJECT

gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

echo 'deleting pubsub topic: weatherdata'

gcloud pubsub topics delete weatherdata

echo 'deleting cloud function: iot_weather'

gcloud functions delete iot_weather

echo 'deleting google cloud storage bucket iot-analytics-depp'

gsutil rm -rf gs://iot-analytics-depp

echo 'deleting directory ~/'$PROJECT' containing pub-key.json'

rm -r ~/$PROJECT

echo 'deleting weatherDataTable table inside weatherData dataset'

bq --location US rm -f --table weatherData.weatherDataTable

echo 'deleting weatherData dataset'

bq --location US rm -f --dataset weatherData

echo 'deleting ~/home/pi/credentials and ~/home/pi/gcp-iot-pipeline folders on raspberrypi. you need to enable via ssh please:'

ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline

echo 'some userful informtation regarding remaining resources for project '$PROJECT

echo 'remaining google pubsub topics:'

gcloud pubsub topics list

echo 'remaining service accounts:'

gcloud iam service-accounts list

echo 'remaining google cloud buckets:'

gsutil ls

echo 'remaining big query datasets:'

bq ls -a

echo 'remaining cloud functions (if blank, then none):'

gcloud functions list

echo 'remaining enabled apis in project '$PROJECT

gcloud services list
