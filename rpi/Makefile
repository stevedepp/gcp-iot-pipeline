env:
	python3 -m venv .venv
	#mkdir -p gcp-iot-pipeline && cd gcp-iot-pipeline && python3 -m venv .venv

setup:
	sudo apt-get update
	sudo apt-get upgrade

install:
	python3 -m pip install --upgrade pip
	pip install -r requirements.txt --use-feature=2020-resolver

config:
	sudo raspi config
reboot:
	sudo reboot
i2c:
	sudo i2cdetect -y 1
gcp:
	export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
	echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	#sudo apt-get update 
	sudo apt-get install google-cloud-sdk
	python3 -m pip install --upgrade pip
	pip3 install google-api-python-client
	sudo pip install --upgrade oauth2client
	#gcloud init --console-only
	gcloud auth application-default login
	pip install tendo
	# not sure if the  auth or init are needed
	gsutil cp gs://iot-analytics-depp/key.json .
	ls

project:
	gcloud config configurations describe default
	gcloud alpha billing accounts list
	gcloud projects list
	gcloud config set project msds434fp
	gcloud config get-value core/project
	gcloud beta billing projects link msds434fp --billing-account 01674D-E5A779-4E5103
apis:
	gcloud services list --available | grep compute
	gcloud services enable compute.googleapis.com
	gcloud services enable bigquery.googleapis.com
	gcloud services enable pubsub.googleapis.com 
	gcloud services enable cloudfunctions.googleapis.com
	gcloud services enable cloudbuild.googleapis.com
	gcloud services enable dataflow.googleapis.com

sensor:
	pip3 install adafruit-circuitpython-bmp280
	pip3 install datetime
	pip3 install --upgrade google-cloud-pubsub
	pip3 install --upgrade oauth2client
	pip3 install tendo
	pip3 install adafruit-circuitpython-bmp280

pubsub:
	sudo pip install --upgrade google-cloud-pubsub
	gsutil cp gs://iot-analytics-depp/key.json .
	cat key.json
	export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/gcp-iot-pipeline/key.json
