# 7 shell scripts and 4 manual interventions to assemble the gcloud / raspeberrypi infra

## laptop


### manual_1

- [x] execute the following commands in a laptop computer's terminal window.

    `mkdir folder_name`
    `cd folder_name`
    `git clone https://github.com/stevedepp/gcp-iot-pipeline.git`
    `cd gcp-iot-pipeline
    `python3 -m venv .venv`
    `source .venv/bin/activate`

### ./shells/1_gcp_setup_PROJECT.sh

    `#!/bin/bash`
    `PROJECT=$1`
    `gcloud auth login`
    `export PROJECT=$PROJECT`
    `gcloud config set project $PROJECT`
    `export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')`
    `gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT`
    `gcloud config configurations describe default`
    `gcloud alpha billing accounts list`
    `gcloud projects list`
    `gcloud config get-value core/project`
    `gcloud services enable pubsub.googleapis.com`
    `gcloud pubsub topics create weatherdata`
    `gcloud iam service-accounts create iot-weather-publisher --project $PROJECT`
    `gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher`
    `gcloud iam service-accounts keys create ~/$PROJECT/pub-key.json --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com`
    `gsutil mb gs://iot-analytics-depp`
    `gsutil cp ~/$PROJECT/pub-key.json gs://iot-analytics-depp`
    `gcloud iam service-accounts list`
    `gcloud projects get-iam-policy $PROJECT`
    `gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com`
    `ls ~/$PROJECT/pub-key.json`
    `cat ~/$PROJECT/key.json`
    `gsutil ls gs://iot-analytics-depp`
    `gcloud services enable bigquery.googleapis.com`
    `bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData`
    `bq mk --table --project_id $PROJECT --description 'contains received IoT weather data' weatherData.weatherDataTable ./weatherDataTable-schema.json`
    `bq show --schema --format=prettyjson weatherData.weatherDataTable`
    `bq version`
    `gcloud services enable cloudbuild.googleapis.com`
    `gcloud services enable cloudfunctions.googleapis.com`
    `gcloud functions deploy iot_weather --runtime python38 --trigger-topic weatherdata --source ./stream2bq/`


## raspberrypi

### manual_2

- [x] put SD card into the card reader.

- [x] load raspian via Raspberry Pi imager.

- [x] eject the SD card from the card reader and re-insert the SD card into the card reader.

- [x] execute the following shell command, `./shells/2_sd_card_wifi.sh` from same laptop terminal session in the same terminal in the project_folder directory made in step **manual_1**.

### ./shells/2_sd_card_wifi.sh

    `#!/bin/bash`
    `git clone https://github.com/stevedepp/gcp-iot-pipeline.git`
    `cd gcp-iot-pipeline`
    `ls /Volumes/boot`
    `cp ./rpi/ssh /Volumes/boot`
    `cp ./rpi/wpa_supplicant.conf /Volumes/boot`
    `ls /Volumes/boot`
    `nano /Volumes/boot/wpa_supplicant.conf`

### manual_3

- [x] the last shell command calls nano editor on `wpa_supplicant.conf`.

- [x] in the nano editor, replace the `ssid` and `psk` with network name and passcode.

- [x] in the nano editor, there are 2 network names. one can be deleted or more copied in.

- [x] `cntrl-o` 

- [x] return

- [x] `cntrl-x`

- [x] safely eject the SD from the card reader.

- [x] insert the SD card into the raspberrypi and wait a few minutes while it boots.

- [x] when the green light stops flashing, move to the next step.

- [x] check the raspberrypi is visible on the network.
    `ping raspberrypi.local`

- [x] if `ping` is successful, `cntrl-c` to stop it.  if not try again in a minute after raspberrypi's boot is complete.
    `cntrl-c`

- [x] ssh into the raspberrypi.
    `ssh pi@raspberrypi.local`

- [x] the first ssh attempt often yields a DANGER warning. there is a good reason, but don't fret.  it probably doesnt apply here. so, just use this command.
    `ssh-keygen -R raspberrypi.local`

- [x] then, try connecting again, following the prompts as shown. (`raspberry` is the default password.)
    `ssh pi@raspberrypi.local`
    `yes`
    `raspberry`

- [x] exit the `ssh` session, i.e. disconnect from the raspberrypi.

- [x] execute this command from the same laptop terminal session in the same project_folder directory made in step **manual_1**.  this `./shells/3_caller.sh` shell command executes the `./shells/3_update_sd_os.sh` shell remotely on the raspberrypi.

### ./shells/3_sd_card_wifi.sh

    `#!/bin/bash`
    `ssh pi@raspberrypi.local 'bash -s' < ./shells/3_update_sd_os.sh`

### ./shells/3_update_sd_os.sh
DO NOT EXECUTE THIS.  IT IS CALLED BY `./shells/3_sd_card_wifi.sh`

    `#!/bin/bash`
    `sudo apt-get update`
    `sudo apt-get upgrade`
    `sudo apt-get install i2c-tools libi2c-dev python-smbus`
    `sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules`
    `sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt`
    `sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime`
    `sudo reboot`

### manual_4

- [x] easy. just execute the next shell command.  needed a manual step here to wait for the reboot to complete.

- [x] the last shell ended with a reboot of the raspberrypi.  wait until the green light stops flickering, then move to the next step.

- [x] have your project id handy because the remaining shell commands require a project id.  (project ids are often  but not always the same as project name.)

- [x] execute this command from the same laptop terminal session in the same project_folder directory made in step **manual_1**.  this `4_caller_PROJECT.sh` shell command executes the `4_test_sensor_gcloud_install_setup_PROJECT.sh` shell command remotely on the raspberrypi, **and needs a project id**: 

    `./shells/4_caller_PROJECT.sh my_project_id`

### ./shells/4_caller_PROJECT.sh my_project_id

    `#!/bin/bash`
    `PROJECT = $1`
    `ssh pi@raspberrypi.local 'bash -s' < ./shells/4_test_sensor_gcloud_install_setup_PROJECT.sh $PROJECT

### ./shells/4_test_sensor_gcloud_install_setup_PROJECT.sh  
DO NOT EXECUTE THIS.  IT IS CALLED BY `4_caller_PROJECT.sh`

    `#!/bin/bash`
    `PROJECT=$1`
    `echo '77 means the detector is seen by the raspberrypi'`
    `sudo i2cdetect -y 1`
    `echo 'working on project: '$PROJECT`
    `export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"`
    `echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list`
    `curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -`
    `sudo apt-get update && sudo apt-get install google-cloud-sdk`
    `gcloud auth login`
    `gcloud config set project $PROJECT`
    `export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')`
    `gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT`
    `gcloud config configurations describe default`
    `gcloud alpha billing accounts list`
    `gcloud projects list`
    `gcloud config get-value core/project`
    `git clone https://github.com/stevedepp/gcp-iot-pipeline.git`
    `cd gcp-iot-pipeline/rpi`
    `python3 -m pip install --upgrade pip`
    `python3 -m venv .venv`
    
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


## whole project

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
