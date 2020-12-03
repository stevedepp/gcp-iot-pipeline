# 7 shell scripts and 4 manual interventions to assemble the gcloud / raspeberrypi infra

## laptop


### manual_1

mkdir folder_name

cd folder_name

git clone https://github.com/stevedepp/gcp-iot-pipeline.git

cd gcp-iot-pipeline

python3 -m venv .venv

source .venv/bin/activate



### ./shells/1_gcp_setup_PROJECT.sh

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


## raspberrypi

### manual_2

put SD card into reader
erase SD card
    diskutil list
    diskutil eraseDisk FAT32 NAME MBRFormat /dev/disk2
load raspian
    

### ./shells/3_sd_card_wifi.sh

#!/bin/bash

ls /Volumes/boot
cp ./rpi/ssh /Volumes/boot
cp ./rpi/wpa_supplicant.conf /Volumes/boot



### manual_3

update wifi passkey
    nano /Volumes/boot/wpa_supplicant.conf
eject card / replace card
ping network
    ping raspberrypi.local



### ./shells/4_update_sd_os.sh

#!/bin/bash

ssh pi@raspberrypi.local

ssh-keygen -R raspberrypi.local

ssh pi@raspberrypi.local
    yes
    raspberry

sudo apt-get install i2c-tools libi2c-dev python-smbus

sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules

sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt

sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime

sudo reboot



### ./shells/5_test_sensor_gcloud_install_setup_PROJECT.sh

#!/bin/bash

PROJECT=$1

ssh pi@raspberrypi.local

sudo i2cdetect -y 1

export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update && sudo apt-get install google-cloud-sdk

gcloud auth login

export PROJECT=test123depp

gcloud config set project $PROJECT

export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')

gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT

gcloud config configurations describe default

gcloud alpha billing accounts list

gcloud projects list

gcloud config get-value core/project

git clone https://github.com/stevedepp/gcp-iot-pipeline.git

cd gcp-iot-pipeline/rpi

python3 -m venv .venv

### manual_4

source .venv/bin/activate

### 6_dependencies_run_PROJECT.sh

#!/bin/bash

PROJECT=$1

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

### 7_teardown_PROJECT.sh

#!/bin/bash

PROJECT=$1

gcloud config set project $PROJECT

bq --location US rm -f --table weatherData.weatherDataTable

gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher

gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com

gcloud pubsub topics delete weatherdata

bq --location US rm -f --dataset weatherData

gcloud functions delete iot_weather

gsutil rm -r gs://iot-analytics-depp

rm -r ~/$PROJECT

ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline
