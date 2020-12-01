env:
	#mkdir -p gcp-iot-pipeline && cd gcp-iot-pipeline && python3 -m venv .venv
	python3 -m venv .venv

install:
	pip install --upgrade google-cloud-bigquery
gcp:
	gcloud config configurations describe default
	gcloud config set project msds434fp
	gcloud alpha billing accounts list
	gcloud projects list
	gcloud config get-value core/project 
	gcloud beta billing projects link msds434fp --billing-account 01674D-E5A779-4E5103

apis:
	gcloud services enable compute.googleapis.com
	gcloud services enable bigquery.googleapis.com
	gcloud services enable pubsub.googleapis.com 
	gcloud services enable cloudfunctions.googleapis.com
	gcloud services enable cloudbuild.googleapis.com
	gcloud services enable dataflow.googleapis.com

table:
	python3 -m pip install --upgrade pip
	pip install google-api-python-client
	pip install oauth2client
	pip install --upgrade google-cloud-bigquery
	bq version
	bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData
	bq mk --table --project_id msds434fp --description "contains received IoT weather data" weatherData.weatherDataTable ./weatherDataTable-schema.json
	bq show --schema --format=prettyjson weatherData.weatherDataTable

pubsub:
	gcloud pubsub topics create weatherdata
	gcloud iam service-accounts create iot-weather-publisher --project msds434fp
	gcloud iam service-accounts list
	gcloud projects add-iam-policy-binding msds434fp --member="serviceAccount:iot-weather-publisher@msds434fp.iam.gserviceaccount.com" --role=roles/pubsub.publisher
	gcloud iam service-accounts keys create ~/key.json --iam-account iot-weather-publisher@msds434fp.iam.gserviceaccount.com
	gcloud iam service-accounts keys list --iam-account iot-weather-publisher@msds434fp.iam.gserviceaccount.com
	ls -la ~/key.json
	cat ~/key.json
	gsutil mb gs://iot-analytics-depp
	gsutil cp ~/key.json gs://iot-analytics-depp
	gsutil ls gs://iot-analytics-depp

function:
	gcloud functions deploy function-weatherPubSubToBQ --entry-point hello_pubsub --runtime=python37 --trigger-topic weatherdata --source ./cloud-function/
	gcloud functions list

dataflow:
	gsutil mb gs://iot-analytics-depp

teardown:
	bq --location US rm -f --table weatherData.weatherDataTable
	gcloud projects remove-iam-policy-binding $$PROJECT --member="serviceAccount:iot-weather-publisher@test123depp.iam.gserviceaccount.com" --role=roles/pubsub.publisher
	gcloud iam service-accounts delete iot-weather-publisher@test123depp.iam.gserviceaccount.com
	gcloud pubsub topics delete weatherdata
	bq --location US rm -f --dataset weatherData
	gcloud functions delete iot_weather
	gsutil rm -r gs://iot-analytics-depp
