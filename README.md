# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery

## todo:

### enhancements: any enhancement checked here should go into delivery statement as feature
- [ ] use environment variables  
   - [ ] anything with my name in it  
- [ ] makefile for raspberrypi  
- [ ] different adafruit sensors in CLT  
- [ ] monitoring   
- [ ] logging  
- [ ] linting  
- [ ] CICD tool  
- [ ] display data in flask page
- [ ] CLT enables datadownload from bigquery segmented by date or temp range
- [ ] CLT asks for project and account infor and adafruit sensor
- [ ] think venv before anything else in rpi  -  test that
- [ ] more print info in logging - pythonjsonlogger
- [ ] can include toy python scripts for sensor illustraion
- [ ] links to all the sources in the readme file   
- [ ] different schema for bme and bmp  
- [ ] is aliasing source .venv/bin/activate done at root or can be scripted and removed at teardown?
- [ ] encrypt the wifi pwd by running a preparred script that  
- [ ] take inventory of which api are open on start and close when finished  
- [ ] is this too slow ```gcloud functions logs read --limit 50```?  
- [ ] pretty print ```bq ls --format=pretty mydataset_depp```  
- [ ] remove key.json when tearing down
- [ ] random number suffix for bucket?
- [ ] test in diffrent project
- [ ] CLT asks for account then project name and if project doesnt exist asks if wants to create project
- [ ] query from CLT with max rows ```bq --location=US query --use_legacy_sql=false 'SELECT * FROM weatherData.weatherDataTable'```  
- [ ] teardown doesnt yet use PROJECT
- [ ] teardown doesnt yet remove bucket from cloud function

### rejected features
- [ ] random number suffix to storage bucket name is rejected as a feature because the name needs to be employed on the laptop and on the raspberry pi.

### questions  
- [ ] should venv include major installs like gcloud or pubsub's python sdk and libraries like adafruit  
- [ ] should pip installs and api turn ons be done with setups of gcloud components since some are pip install --upgrade package which is diffcult to execute in requirements
- [ ] how best to implement env var for users; can we ask users for their project name and accont number in a CLT?  
- [ ] difference between pip and pip3  
- [ ] does the raspberrypi need a python or is that installed with the OS  
- [ ] what does set do in setting env var and what does { } do?  
- [ ] should all installs be --upgrades?  
- [ ] does cloudfunction api depend on cloudbuild depend on compute?  

### how to evolve to this point  / some of these are lessons and not how tos
- [x] read review take notes on  terminal experiences
- [x] keep notes of every URL used
- [x] leave breadcrumbs for past mistakes and successes in notes because YOU will forget how you did stuff in rapid rabid experimentation
- [x] read the documentation when can > stackoverflow sometimes. 
- [x] some docs suck. some logs suck. then stackoverflow is a goldmine, but even then stackoverflow is full of wreckless workarounds that can corrupt intent of code
- [x] simple tutorials and then build e.g.:  
    - [x] .....  
    - [x] .....  
- [x] experiment in ipython
- [x ] certain experiments ruin the pot
    - [x] disabling api e.g.
 
## architecture:

#### project:
sa key —> bucket
outside —> rpi sensor —> rpi —> python —> sa w key —> pubsub <— cloudfunction —> bq dataset.table

#### msds434deppfp:
iot-weather-publisher key.json —> iot-analytics-depp

weather —> bmp280 —> pi —> iot-data-pipeline-depp.py --> iot-weather-publisher w key.json —> weatherdata —> main.py —> weatherData.weatherDataTable —> weatherDataTable-schema

## hardware:

### purchase raspberrypi et al

### solder sensor 

### connect raspberrypi to sensor

## gcloud and raspberrypi infrastructure as code from a laptop:

### set up gcloud infrastructure from a laptop terminal:

- [x] **laptop terminal environment set up:**

    - [x] clone this project's repository and change to the ```gcp-iot-pipeline``` directory inside.  
    
        ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```  

        ```cd gcp-iot-pipeline``` 

    - [x] remove previous environment, if any, reset the environment and source it.
    
        ```rm -rf .venv```

        ```python3 -m venv .venv```

        ```source .venv/bin/activate```
        
    - [x] export environment variables for project and account. note: these do not carry over from one terminal window to another.

        ```export PROJECT=msds434deppfp```

        ```export ACCOUNT=01674D-E5A779-4E5103```

    - [x] upgrade python's package installer, pip.

        ```python3 -m pip install --upgrade pip```

- [x] **gcp set up:**

    - [x] sets the default project to this current one.

        ```gcloud config set project $PROJECT```

    - [x] link the current project to a billing account.

        ```gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT```

- [x] **pubsub set up:**

    - [x] enable the pubsub api and create the ```weatherdata``` topic.
    
        ```gcloud services enable pubsub.googleapis.com```

        ```gcloud pubsub topics create weatherdata```

    - [x] create a service account named ```iot-weather-publisher```.

        ```gcloud iam service-accounts create iot-weather-publisher --project $PROJECT```

    - [x] bind the service account to a ```pubsub.publisher``` role.
    
        ```gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher```

    - [x] create a key.json file in a directory named for the project in the users home directory.

        ```gcloud iam service-accounts keys create ~/$PROJECT/key.json --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```

    - [x] make a google storage bucket named ```iot-analytics-depp``` and copy the key.json file to this bucket.

        ```gsutil mb gs://iot-analytics-depp```

        ```gsutil cp ~/$PROJECT/key.json gs://iot-analytics-depp```
    
        *[note: the bucket is not essential but allows for the raspberry pi set up to come AFTER the laptop setup; were the latop set up AFTER then the pubsub key could be transfered to the pi via scp:
    ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi```]*

- [x] **big query set up:**

    - [x] enable the pubsub api and create the ```weatherData``` dataset and the ```weatherDataTable``` table inside of the dataset. 

        ```gcloud services enable bigquery.googleapis.com```

        ```bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData```

        ```bq mk --table --project_id $PROJECT --description 'contains received IoT weather data' weatherData.weatherDataTable ./weatherDataTable-schema.json```

- [x] **cloud function set up:**

    - [x] enable the cloudbuild and cloudfunction api's. 

        ```gcloud services enable cloudbuild.googleapis.com```

        ```gcloud services enable cloudfunctions.googleapis.com```

    - [x] deploy the ```iot_weather``` cloud function with a ```weatherdata``` pubsub trigger; source code is held in the ```./stream2bq``` directory.

        ```gcloud functions deploy iot_weather --runtime python38 --trigger-topic weatherdata --source ./stream2bq/```

### setup raspberry pi OS and settings setup from a laptop:

- [x] **open a new terminal window.** 

- [x] **erase SD card via diskutil:**

    - [x] insert the SD card. 

    - [x] find the SD card in a list of attached disks.
    
        ```diskutil list``` 
        
    - [x] replace```disk 2``` in this command with the disk identifier from previous command.  
    
        ```diskutil eraseDisk FAT32 NAME MBRFormat /dev/disk2```

- [x] **load raspbian OS onto the SD card using the raspberry pi imager**

    - [x] Operating System = latest which here is Raspberry Pi OS (32 bit).

    - [x] SD Card = your card which here is "SANDISK SDDR-409 Media - 127.9 GB" here
    
    - [x] YES
    
    - [x] Laptop password
    
    - [x] CONTINUE
    
- [x] **load Wifi preferences onto SD card boot disk**

    - [x] clone this project's repository and change to the ```gcp-iot-pipeline``` directory inside.  

        ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```        
        
        ```cd gcp-iot-pipeline``` 

    - [x] OSX can only see the SD card's ```boot``` directory found at ```/Volumes/boot``` because the boot is the only available SD card directory that is agnostic / firendly to linux/OSX & windows platforms.  View the ```boot``` directory's conents, but don't change to from the ```gcp-iot-pipeline``` directory.
    
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
    - [x] enter the passphrase for your wifi network(s) and copy
        ```nano /Volumes/boot/wpa_supplicant.conf```
        
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

*[note this is another point, prior to the next ```ssh pi@raspberrypi.local```, where one could copy the ```key.json``` to the raspberrypi via   ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi``` and avoid use of the ```gs://iot-analytics-depp``` bucket.]*

### install the weather sensor from laptop ssh into raspberry pi:

- [x] raspberry pi setup:  
    ```ssh pi@raspberrypi.local```  
    
- [x] install gcloud SDK
    - [x] set the following environment variable so gcloud SDK version matches the OS of raspberrypi.
        ```export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"```
    - [x] set gcloud SDK installation location.
        ```echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list```
    - [x] this public key from Google's package repository ensures that Raspberry Pi will verify the security and trust the content during installation.
        ```  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -```
    - [x] redundant update of raspberrypi OS and gcloud SDK install; press ```Enter``` when asked.
    ```sudo apt-get update && sudo apt-get install google-cloud-sdk```

UNSURE WHICH OF THE NEXT 2 CHECKBOXES COMES FIRST.  DO WE WANT TO ENV OFF THE PUBSUB AND OATH AND ADAFRUIT AND GCLOUD INIT?
SHOUULD GCLOUD INIT GO AS LAST STEP IN THE PREVIOUS CHECKBOX?

- [x] clone this project's repo and cd into it.  
        ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```  
        ```cd gcp-iot-pipeline/rpi```  
        ```rm -rf .venv```  
        ```python3 -m venv .venv```  
        ```source .venv/bin/activate```  

- [x] install some dependencies with python's package manaager.
    - [x] tendo is used in ```check_weather.py``` to check if a script is running more than once:
        ```pip install tendo```  
    - [x] these are pubsub and oauth2 packages for python.  
        ```pip install --upgrade google-cloud-pubsub```  
        ```pip3 install --upgrade oauth2client```  
    - [x] datetime is employed in ```checkweather.py```  
    ```pip3 install datetime```  
   - [x] this is the new libary pubished by adafruit, the sensor manufacturer.  
    ```pip3 install adafruit-circuitpython-bmp280```  
- [x] set up gcloud as usual; instructions here, but make sure to select this project and region:
    ```gcloud init --console-only```  
    
### run the weather sensor module to collect data
        
if the repository is already here then cd into it if not clone it and cd into it and activate  
    ```ssh pi@raspberrypi.local```  
    ```cd ~/gcp-iot-pipeline```
    ```export PROJECT=test123depp```
- [x] copy over the key.json credentials and set an environment variable for their location. 
    ```source .venv/bin/activate```  
    ```mkdir -p ~/credentials```  
    ```gsutil cp gs://iot-analytics-depp/key.json ~/credentials/```  
    ```export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/key.json```  
    ```cd ~/gcp-iot-pipeline/rpi```

- [ ] call the sensor with $PROJECT argument  
```iot-data-pipeline-depp.py $PROJECT```.

- [x] tear it down
```bq --location US rm -f --table weatherData.weatherDataTable```  
```gcloud projects remove-iam-policy-binding msds434deppfp --member="serviceAccount:iot-weather-publisher@msds434deppfp.iam.gserviceaccount.com" --role=roles/pubsub.publisher```  
```gcloud iam service-accounts delete iot-weather-publisher@msds434deppfp.iam.gserviceaccount.com```  
```gcloud pubsub topics delete weatherdata```  
```bq --location US rm -f --dataset weatherData```  
```gcloud functions delete iot_weather```  
```gsutil rm -r gs://iot-analytics-depp```  
```rm -r ~/$PROJECT```
```ssh pi@raspberrypi.local rm -rf /home/pi/credentials```
