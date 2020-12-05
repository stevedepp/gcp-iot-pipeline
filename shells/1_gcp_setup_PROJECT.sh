#!/bin/bash

PROJECT=$1

echo 'project argument is: '$PROJECT
echo 'google auth login is beginning.'

gcloud auth login

echo 'setting default project: '$PROJECT

gcloud config set project $PROJECT

export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')

echo 'linking '$PROJECT' project to '$ACCOUNT' account.'

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

echo 'enabling google pubsub api'

gcloud services enable pubsub.googleapis.com

echo 'creating pubsub topic: weatherdata'

gcloud pubsub topics create weatherdata

echo 'creating service account named "iot-weather-publisher" to be used by sensor to access and publish to pubsub topic for project '$PROJECT

gcloud iam service-accounts create iot-weather-publisher --project $PROJECT

echo 'binding pubsub.publisher role to service account iot-weather-publisher for project '$PROJECT

gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher

echo 'creating key for iot sensor to pubslish to pubsub topic and saving key to ~/'$PROJECT'/pub-key.json'

gcloud iam service-accounts keys create ~/$PROJECT/pub-key.json --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

echo 'makeing google cloud storage bucket iot-analytics-depp'

gsutil mb gs://iot-analytics-depp

echo 'copying pubslisher key to gs://iot-analytics-depp bucket'

gsutil cp ~/$PROJECT/pub-key.json gs://iot-analytics-depp

echo 'some useful infrastructure informtation:'

echo 'existing service accounts:'

gcloud iam service-accounts list

echo 'existing iam policy for project '$PROJECT

gcloud projects get-iam-policy $PROJECT

echo 'existing keys for iot-weather-publisher@'$PROJECT' service account'

gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

ls ~/$PROJECT/pub-key.json

cat ~/$PROJECT/pub-key.json

echo 'contents of gs://iot-analytics-depp bucket:'

gsutil ls gs://iot-analytics-depp

echo 'enabling google big query api'

gcloud services enable bigquery.googleapis.com

echo 'creating weatherData dataset'

bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData

echo 'creating weatherDataTable table inside weatherData dataset'

bq mk --table --project_id $PROJECT --description 'contains received IoT weather data' weatherData.weatherDataTable ./weatherDataTable-schema.json

bq ls --format=pretty

echo 'schema of weatherDataTable:'

bq show --schema --format=prettyjson weatherData.weatherDataTable

bq version

echo 'enabling google cloudbuild api'

gcloud services enable cloudbuild.googleapis.com

echo 'enabling google cloudfunctions api'

gcloud services enable cloudfunctions.googleapis.com

echo 'deploying iot_weather cloudfunction triggered by weatherdata pubsub topic'

gcloud functions deploy iot_weather --runtime python38 --trigger-topic weatherdata --source ./stream2bq/

echo 'cloud function is deployed and operational.  next step is setup of the raspberrypi.'
