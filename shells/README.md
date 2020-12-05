# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery

#

## 5 shell scripts and 4 manual steps to assemble the gcloud / raspeberrypi infra
(shell scripts shown do not show the lines of logging found in the actual files)

#

### from the laptop terminal:

#### manual 1: clone the repository

- [x] execute the following commands in a laptop computer's terminal window.

    `mkdir folder_name`  
    `cd folder_name`  
    `git clone https://github.com/stevedepp/gcp-iot-pipeline.git && cd gcp-iot-pipeline`
    
- [x] from this laptop terminal session, from the `/my_folder/gcp-iot-pipeline/` directory, execute the folloing shell command:

    `./shells/1_gcp_setup_PROJECT.sh`

#

#### shell script 1: ./shells/1_gcp_setup_PROJECT.sh

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

#

### from the laptop terminal via ssh connection to raspberrypi:

#### manual 2: initialize the SD card

- [x] put SD card into the card reader.

- [x] load raspian via Raspberry Pi imager.

- [x] eject the SD card from the card reader and re-insert the SD card into the card reader.

- [x] from same laptop terminal session, from the `/my_folder/gcp-iot-pipeline/` directory, execute the folloing shell command:

    `./shells/2_sd_card_wifi.sh`

#

#### shell script 2: ./shells/2_sd_card_wifi.sh

    `#!/bin/bash`
    `ls /Volumes/boot`
    `cp ./rpi/ssh /Volumes/boot`
    `cp ./rpi/wpa_supplicant.conf /Volumes/boot`
    `ls /Volumes/boot`
    `nano /Volumes/boot/wpa_supplicant.conf`

#

#### manual 3: setup communications with the raspberrypi

- [x] the last shell command calls nano editor on `wpa_supplicant.conf`:  
    - [x] in the nano editor, replace the `ssid` and `psk` with network name and passcode.  
    - [x] in the nano editor, there are 2 network names. one can be deleted or more copied in.  
    - [x] `cntrl-o`   
    - [x] `return`  
    - [x] `cntrl-x`  

- [x] safely eject the SD from the card reader.

- [x] insert the SD card into the unpowered raspberrypi

- [x] plug power into the raspberrypi and wait a few minutes while it boots.

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
    
- [x] clone the repository and change to the `gcp-iot-pipeline` directory.

    `git clone https://github.com/stevedepp/gcp-iot-pipeline.git && cd gcp-iot-pipeline`  
    
- [x] execute the next shell command.  

    `./shells/3_update_sd_os.sh`

#

#### shell script 3: ./shells/3_update_sd_os.sh

    `#!/bin/bash`
    `sudo apt-get update`
    `sudo apt-get upgrade`
    `sudo apt-get install i2c-tools libi2c-dev python-smbus`
    `sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules`
    `sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt`
    `sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime`
    `python3 -m venv .venv`  <-- experiment 
    `sudo reboot`

#

#### manual 4: source the raspberrypi's virtual environment.

- [x] the last shell ended with a reboot of the raspberrypi.  wait until the green light stops flickering, then reconnect via ssh.

    `ssh pi@raspberrypi.local`

- [x] change to the `gcp-iot-pipeline` directory and source the virtual environment created in the last line of the last shell script.

    `cd gcp-iot-pipeline && source .venv/bin/activate`

- [x] have your project id handy because the remaining shell commands require a project id.  (project ids are often  but not always the same as project name.)

- [x] execute the folloing shell command.  this `4_test_sensor_gcloud_install_setup_dependencies_run_PROJECT.sh` shell command **needs a project id** as shown here:

    `./shells/4_test_sensor_gcloud_install_setup_dependencies_run_PROJECT.sh project_id`

#

#### shell script 4: ./shells/4_test_sensor_gcloud_install_setup_dependencies_run_PROJECT.sh

    `#!/bin/bash`
    `PROJECT=$1`
    `sudo i2cdetect -y 1`
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
    `pip install tendo`
    `pip install --upgrade google-cloud-pubsub`
    `pip3 install --upgrade oauth2client`
    `pip3 install datetime`
    `pip3 install adafruit-circuitpython-bmp280`
    `mkdir -p ~/credentials`
    `gsutil cp gs://iot-analytics-depp/pub-key.json ~/credentials/`
    `export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/pub-key.json`
    `python3 iot-data-pipeline.py $PROJECT`

#

### from the laptop terminal:

- [x] To unwind all the actions taken so far and remove resource usage on Google Cloud Platform exeute the following shell command.

- [x] from same laptop terminal session, from the `/my_folder/gcp-iot-pipeline/` directory, execute the folloing shell command.  **This shell command needs a project id as shown here**:

    `./shells/5_teardown_PROJECT.sh my_project_id`
 
#### shell script 5: ./shells/5_teardown_PROJECT.sh

    `#!/bin/bash`
    `PROJECT=$1`
    `gcloud config set project $PROJECT`
    `gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher`
    `#gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com`
    `gcloud pubsub topics delete weatherdata`
    `gcloud functions delete iot_weather`
    `gsutil rm -rf gs://iot-analytics-depp`
    `rm -r ~/$PROJECT`
    `bq --location US rm -f --table weatherData.weatherDataTable`
    `bq --location US rm -f --dataset weatherData`
    `ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline`
    `gcloud pubsub topics list`
    `gcloud iam service-accounts list`
    `gsutil ls`
    `bq ls -a`
    `gcloud functions list`
    `gcloud services list`
