# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery

## todo:

### enhancements:
- [ ] use environment variables
   - [ ] anything with my name in it
- [ ] makefile for raspberrypi

## architecture

#### project:
sa key —> bucket
outside —> rpi sensor —> rpi —> python —> sa w key —> pubsub <— cloudfunction —> bq dataset.table

#### msds434deppfp:
iot-weather-publisher key.json —> iot-analytics-depp

weather —> bmp280 —> pi —> iot-data-pipeline-depp.py --> iot-weather-publisher w key.json —> weatherdata —> main.py —> weatherData.weatherDataTable —> weatherDataTable-schema

## hardware  

### purchase raspberrypi et al

### solder sensor 

### connect raspberrypi to sensor

## code

### laptop & gcloud set up:

- [x] **laptop terminal environment set up:**

    ```rm -rf .venv```

    ```python3 -m venv .venv```

    ```source .venv/bin/activate```

    ```export PROJECT=msds434deppfp```

    ```export ACCOUNT=msds434deppfp```

    ```python3 -m pip install --upgrade pip```

- [x] **gcp set up:**

    ```gcloud config set project $PROJECT```

    ```gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT```

- [x] **pubsub set up:**

    ```gcloud services enable pubsub.googleapis.com```

    ```gcloud pubsub topics create weatherdata```

    ```gcloud iam service-accounts create iot-weather-publisher --project $PROJECT```

    ```gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher```

    ```gcloud iam service-accounts keys create ~/key.json --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```

    ```gsutil mb gs://iot-analytics-depp```

    ```gsutil cp ~/key.json gs://iot-analytics-depp```
    
    *[note: the bucket is not essential but allows for the raspberry pi set up to come AFTER the laptop setup; were the latop set up AFTER then the pubsub key could be transfered to the pi via scp:
    ```scp ~/key.json pi@raspberrypi.local:/home/pi```]*

- [x] **big query set up:**

    ```gcloud services enable bigquery.googleapis.com```

    ```bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData```

    ```bq mk --table --project_id $PROJECT --description 'contains received IoT weather data' weatherData.weatherDataTable ./weatherDataTable-schema.json```

- [x] **cloud function set up:**

    ```gcloud services enable cloudbuild.googleapis.com```

    ```gcloud services enable cloudfunctions.googleapis.com```

    ```gcloud functions deploy iot_weather --runtime python38 --trigger-topic weatherdata --source ./stream2bq/```

### raspberry pi OS and settings setup occurs on laptop:

- [x] **erase SD card via diskutil:**

    ```diskutil list``` reveals which disk is the SD card; replace```disk 2``` in the next line if different.)  
    ```diskutil eraseDisk FAT32 NAME MBRFormat /dev/disk2```

- [x] **load OS via raspberry pi imager**
    - [x] Operating System = latest which here is Raspberry Pi OS (32 bit).
    - [x] SD Card = your card which here is "SANDISK SDDR-409 Media - 127.9 GB" here
    - [x] YES
    - [x] Laptop password
    - [x] CONTINUE
    
- [x] **load Wifi preferences onto SD card boot disk**
    - [x] clone this project's repo.  
        ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```  
    - [x] path to SD card: boot is the only available directory agnostic firendly to linux/OSX & windows platforms.  
            ```ls /Volumes/boot```  
    - [x] make blank ssh file that on first **headless* raspberrypi boot will enable ssh.  
            ```touch ssh```  
    - [x] there's one of these already in the repo; copy it to the raspberry pi.  
            ```cd rpi```  
            ```cp rpi/ssh /Volumes/boot```  
    - [x] make ```wpa_supplicant.conf``` file with your routers login/password which can be encrypted.  
                    image here
    - [x] there's one of these already in the repo; copy it to the raspberry pi.  
        ```cp rpi/wpa_supplicant.conf /Volumes/boot```  
        
- [x] **put SD card into the raspberrypi and plug the raspberrypi into the wall**  

- [x] **check that it is on the network**  
    ```ping raspberrypi.local```  
    
- [x] **ssh into the raspberrypi - here's where the fun starts!**  
    ```ssh pi@raspberrypi.local```  
    
- [x] **first time, you get** ***boy crying wolf*** **warnings; clear them as follows:**  
    ```ssh-keygen -R raspberrypi.local```  
    
- [x] **try again** ***et viola***  
    ```ssh pi@raspberrypi.local```  

- [x] **update and upgrade the OS if possible.**  
    ```sudo apt-get update```  
    ```sudo apt-get upgrade```  
- [x] **configure the OS to see our sensor and know our timezone**  
    ```sudo raspi config GUI```  
            - [x] Interface Options  
            - [x] P5 I2C Enable/discable automatic loading of I2C kernel module  
            - [x] Localisation Options  
            - [x] Timezone  
- [x] reboot the raspberrypi  
    ```sudo reboot```  

*[note this is another point (prior to the next ```ssh pi@raspberrypi.local``` where one could copy the ```key.json``` to the raspberrypi via   ```scp ~/key.json pi@raspberrypi.local:/home/pi``` and avoid use of the ```gs://iot-analytics-depp``` bucket.]*

### start the weather sensor from laptop ssh into raspberry pi:
