#!/bin/bash

PROJECT=$1

gcloud auth login

export PROJECT=test123depp

gcloud config set project $PROJECT

export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')

gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT

gcloud config configurations describe default

gcloud alpha billing accounts list

gcloud projects list

gcloud config get-value core/project

python3 -m pip install --upgrade pip

gcloud pubsub topics create weatherdata

gcloud iam service-accounts create iot-weather-publisher --project $PROJECT

gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher

gcloud iam service-accounts keys create ~/$PROJECT/key.json --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

gsutil mb gs://iot-analytics-depp

gsutil cp ~/$PROJECT/key.json gs://iot-analytics-depp

gcloud iam service-accounts list

gcloud projects get-iam-policy $PROJECT

gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

ls ~/$PROJECT/key.json

cat ~/$PROJECT/key.json

gsutil ls gs://iot-analytics-depp

gcloud services enable bigquery.googleapis.com

bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData

bq mk --table --project_id $PROJECT --description 'contains received IoT weather data' weatherData.weatherDataTable ./weatherDataTable-schema.json

bq show --schema --format=prettyjson weatherData.weatherDataTable

bq version

gcloud services enable cloudbuild.googleapis.com

gcloud services enable cloudfunctions.googleapis.com

gcloud functions deploy iot_weather --runtime python38 --trigger-topic weatherdata --source ./stream2bq/
