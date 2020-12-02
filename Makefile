#manual
	git clone https://github.com/stevedepp/gcp-iot-pipeline.git && cd gcp-iot-pipeline

env:
	python3 -m venv .venv

#manual 
	source .venv/bin/activate
	export PROJECT=XXXXX
	export ACCOUNT=01674D-E5A779-4E5103 or extract from gcloud	

gcp:
	python3 -m pip install --upgrade pip
	gcloud config set project $$PROJECT
	gcloud beta billing projects link $$PROJECT --billing-account $$ACCOUNT

pubsub:
	gcloud services enable pubsub.googleapis.com
	gcloud pubsub topics create weatherdata
	gcloud iam service-accounts create iot-weather-publisher --project $$PROJECT
	gcloud projects add-iam-policy-binding $$PROJECT --member="serviceAccount:iot-weather-publisher@$$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher
	gcloud iam service-accounts keys create ~/$$PROJECT/key.json --iam-account iot-weather-publisher@$$PROJECT.iam.gserviceaccount.com
	gsutil mb gs://iot-analytics-depp
	gsutil cp ~/$$PROJECT/key.json gs://iot-analytics-depp

pubsubinfo:
	gcloud iam service-accounts list
	gcloud projects get-iam-policy $$PROJECT
	gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$$PROJECT.iam.gserviceaccount.com
	ls ~/$$PROJECT/key.json
	cat ~/$$PROJECT/key.json
	gsutil ls gs://iot-analytics-depp

bq:
	gcloud services enable bigquery.googleapis.com
	bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData
	bq mk --table --project_id $$PROJECT --description 'contains received IoT weather data' weatherData.weatherDataTable ./weatherDataTable-schema.json

bqinfo:
	bq version
	bq show --schema --format=prettyjson weatherData.weatherDataTable

cf
	gcloud services enable cloudbuild.googleapis.com
	gcloud services enable cloudfunctions.googleapis.com
	gcloud functions deploy iot_weather --runtime python38 --trigger-topic weatherdata --source ./stream2bq/

make infra: gcp pubsub pubsubinfo bq bqinfo cf