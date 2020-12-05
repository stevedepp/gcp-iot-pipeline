# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery


## quickstart: assumes raspberrypi + SD card + sensor all set up

- [x] ```mkdir folder_name```
- [x] ```cd folder_name```
- [x] ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```
- [x] ```cd gcp-iot-pipeline```
- [x] ```python3 -m venv .venv```
- [x] ```source .venv/bin/activate```
- [x] ```./shells/1_gcp_setup_PROJECT.sh```
- [x] ```./shells/ellen.sh```
- [x] view output in BQ
- [x] ```./shells/7_teardown_PROJECT.sh```

## todo:

### enhancements: any enhancement checked here should go into delivery statement as feature
- [x] use environment variables 
    - [x] PROJECT
    - [x] ACCOUNT
- [x] user CLT arguments
    - [x] project
    - [ ] see constants in next todo item
- [ ] constants for infrastructure assets would make this more generic tool for more sensors:
    - [x] project
    - [ ] pubsub topic name
    - [ ] iot sensor service account name 
    - [ ] preferred key.json name and path
    - [ ] preferred cloud function name
    - [ ] timezone for the sensor
- [x] test placement of venv and source to reduce clicks in raspberrypi setup
- [ ] take inventory of which api are enabled on creation and teardown and difference
    - [x] as created
    - [x] on teardown
    - [ ] show difference
- [x] makefile for gcp and raspberrypi for development 
- [x] CLT project argument
- [ ] CLT adafruit sensor argument
- [ ] CLT logic for schema for adafruit bme and bmp sensors
- [ ] CLT asks for account then project name and if project doesnt exist asks if wants to create project
- [ ] CLT to turn data collection on / off
- [ ] CLT to test if 
    - [ ] gcloud infra built
    - [ ] raspberrypi infra built
- [ ] CLT enables datadownload from bigquery 
    - [x] by date 
    - [x] by temp range
    - [x] with max rows  
    ```bq --location=US query --use_legacy_sql=false 'SELECT columns FROM weatherData.weatherDataTable'```
    ```bq ls --format=pretty mydataset```
- [x] CLT logging via echo
- [ ] CLT display data in flask page
- [x] teardown PROJECT
- [x] teardown doesnt yet remove bucket from cloud function
- [ ] CICD tool  
- [ ] structured README.md
    - [ ] quickstart 
    - [ ] quickstart detail
    - [ ] full manual build
- [x] remove key.json when tearing down
- [x] test in diffrent project
- [ ] architecture diagram
    https://app.diagrams.net/?splash=0&libs=gcp
    https://www.cloudockit.com/the-12-most-used-google-cloud-diagrams-explained/

### rejected features
- [x] random number suffix to storage bucket name is rejected as a feature because the name needs to be employed on the laptop and on the raspberry pi.
- [x] encrypt the wifi pwd by running a preparred script that <-- No. Use XXX. 
- [x] ```gcloud functions logs read --limit 50```?  <-- No. Is too slow.
- [x] shell script to encrypt wifi password in wpa_supplicant.conf <-- No. is not encryption and feature soon deprecated
- [x] laptop terminal remotely calls/executes raspberrypi shell scripts <-- NOT YET. Done, and worthy feature, but too fast so that some operations that are skipped or written over.
- [x] raspberrypi setup works with key and auth service account without gcloud auth login popups etc <-- NOT YET needs work: 
    `gcloud auth activate-service-account $PROJECT@appspot.gserviceaccount.com --key-file=auth-key.json`

### q and a
- [x] q: can aliasing source .venv/bin/activate be scripted and removed at teardown?
    - [x] a: cannot be scripted dynamically or called remotely.
- [x] q: should venv include major installs like gcloud or pubsub's python sdk and libraries like adafruit?
    - [x] a: unecessary for gcloud but gcloud python sdks must be in the sourced venv.  so only one sourced venv is needed through out the repository as noted in manual build readme.
- [x] q: should pip installs and api turn ons be done all at once in setups of gcloud components?
- [x] q: should pip installs include --upgrade package?
    - [x] a: very difficult to implement in all cases in requirements.txt; can be done in shell script though.
- [ ] a: difference between pip and pip3?
- [x] a: does the raspberrypi need a python or is that installed with the OS?
    - [x] included in the OS.
- [ ] q: what does `set` do in setting env var and what does { } do?  
    - [x] a: `set` versus `export` is detailed in stackexchange.
- [ ] q: does cloudfunction api depend on cloudbuild depend on compute?  
    - [ ] a: unclear.  tested both directions but errors seem random and corrupting.

### how to evolve to this point  / some of these are lessons and not how tos
- [x] review terminal logs, resolve uncertainties ASAP, take notes on terminal experiences for reflection
- [x] keep notes of every URL used to solve a problem and not solve a problem but investigated
- [x] leave breadcrumbs for past mistakes and successes in notes because YOU will forget how you did stuff in rapid rabid experimentation
- [x] read the documentation when can > stackoverflow sometimes. 
- [x] some docs suck. some logs suck. then stackoverflow is a goldmine, but even then stackoverflow is full of wreckless workarounds that can corrupt intent of code
- [x] avoid unofficial tutorials 
- [x] use official tutorials especially when code breaks for hours
- [x] experiment in ipython
- [x] certain experiments can ruin / corrupt your project settings. delete project and start over.
    - [x] disabling api's e.g.
 
## architecture diagram:

todo item

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

### from a laptop terminal, set up gcloud infrastructure:

- [x] **gcp set up:**

    - [x] log into gcloud as an authorized user.  this step is necessary to set up gcloud CLI on the raspberrypi, but may not be needed to set up gcloud CLI on this laptop if the user already runs ```gcloud``` on this laptop.   If taking this step, follow instructions by copying the link provided into a browser, selecting login email from the popup, and copying the passcode back into the terminal window as shown. 

        ```gcloud auth login```

    - [x] export a ```PROJECT``` environment variable for the user's project.  note: this environment variable does not carry over from one terminal window to another.

        ```export PROJECT=users_project```
    
        ```gcloud config set project $PROJECT```

    - [x] get the account number from gcloud and export an  ```ACCOUNT```environment variable . 

        ```export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')```
    
    - [x] link the current project to the billing account saved in the ```ACCOUNT``` environment variable.
    
        ```gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT```

    - [x] preliminary information:

        ```gcloud config configurations describe default```
    
        ```gcloud alpha billing accounts list```
        
        ```gcloud projects list```
        
        ```gcloud config get-value core/project```

- [x] **pubsub set up:**

    - [x] enable the pubsub api and create the ```weatherdata``` topic.
    
        ```gcloud services enable pubsub.googleapis.com```

        ```gcloud pubsub topics create weatherdata```

    - [x] create a service account named ```iot-weather-publisher```.

        ```gcloud iam service-accounts create iot-weather-publisher --project $PROJECT```

    - [x] bind the service account to a ```pubsub.publisher``` role.
    
        ```gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher```

    - [x] create pub-key.json file in a directory named for the project in the users home directory.

        ```gcloud iam service-accounts keys create ~/$PROJECT/pub-key.json --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```

    - [x] make a google storage bucket named ```iot-analytics-depp``` and copy the pub-key.json file to this bucket (see notes).

        ```gsutil mb gs://iot-analytics-depp```

        ```gsutil cp ~/$PROJECT/pub-key.json gs://iot-analytics-depp```

    - [x] for information:
    
        ```gcloud iam service-accounts list```
        
        ```gcloud projects get-iam-policy $PROJECT```
        
        ```gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```
        
        ```ls ~/$PROJECT/pub-key.json```
        
        ```cat ~/$PROJECT/pub-key.json```
        
        ```gsutil ls gs://iot-analytics-depp```

- [x] **big query set up:**

    - [x] enable the pubsub api and create the ```weatherData``` dataset and the ```weatherDataTable``` table inside of the dataset. 

        ```gcloud services enable bigquery.googleapis.com```

        ```bq --location US mk --dataset --description 'to contain weather data received from pubsub' weatherData```

        ```bq mk --table --project_id $PROJECT --description 'contains received IoT weather data' weatherData.weatherDataTable ./weatherDataTable-schema.json```
        
    - [x] show the constructed schema
    
    ```bq show --schema --format=prettyjson weatherData.weatherDataTable```

    ```bq version```
    
- [x] **cloud function set up:**

    - [x] enable the cloudbuild and cloudfunction api's. 

        ```gcloud services enable cloudbuild.googleapis.com```

        ```gcloud services enable cloudfunctions.googleapis.com```

    - [x] deploy the ```iot_weather``` cloud function with a ```weatherdata``` pubsub trigger; source code is held in the ```./stream2bq``` directory.

        ```gcloud functions deploy iot_weather --runtime python38 --trigger-topic weatherdata --source ./stream2bq/```

### from a laptop terminal, setup SD card with raspberry pi OS and wifi connection settings:

- [x] **from a laptop terminal, using the raspberry pi imager, erase SD card via diskutil and load raspbian OS onto the SD card (see notes)**

    - [x] Operating System = latest which here is *Raspberry Pi OS (32 bit)*.

    - [x] SD Card = your card which here is *SANDISK SDDR-409 Media - 127.9 GB*.
    
    - [x] YES
    
    - [x] Laptop password
    
    - [x] CONTINUE
    
    - [x] When the SD card loading is complete, pull the SD card from the reader and put it back in to the reader and move to the next step.
    
- [x] **from a laptop terminal, load Wifi preferences onto SD card boot disk**

    - [x] clone this project's repository and change to the ```gcp-iot-pipeline``` directory inside.  
    
        ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```  

        ```cd gcp-iot-pipeline``` 
        
    - [x] OSX can only see the SD card's ```boot``` directory found at ```/Volumes/boot``` because the boot is the only available SD card directory that is agnostic / firendly to linux/OSX & windows platforms.  View the ```boot``` directory's conents, but don't change to from the ```gcp-iot-pipeline``` directory.
    
        ```ls /Volumes/boot```  
        
    - [x] create a blank ```ssh``` file so that this raspberrypi's first *headless* boot will enable ssh.  this can be accomplished via ```touch /Volumes/boot/ssh```,  but there's an ```ssh``` file already in the repository's ```rpi``` directory; so take the easy road by copying this ```ssh``` file from the repository 's ```rpi```directory to the raspberry pi's ```/Volumes/boot``` directory.  
    
        ```cp ./rpi/ssh /Volumes/boot```  
        
    - [x] make a ```wpa_supplicant.conf``` file with your routers login/password which can be encrypted.  
    
        image here
                    
    - [x] there's a ```wpa_supplicant.conf``` file already in the repository's ```rpi``` directory; copy it from there to the raspberry pi's ```/Volumes/boot``` directory.

        ```cp ./rpi/wpa_supplicant.conf /Volumes/boot```  
        
    - [x] open the ```wpa_supplicant.conf``` and enter the passphrase for your wifi network(s).
    
        ```nano /Volumes/boot/wpa_supplicant.conf```
        
- [x] **safely eject the SD card.**

### ssh connect to the raspberrypi from a laptop terminal, set up and test connection with the sensor:

**these steps can be done from any directory; so, remain in the same terminal and ```cd gcp-iot-pipeline``` directory**

- [x] **put SD card into the raspberrypi. then, plug the raspberrypi into the wall. give it a few minutes to boot up during which time it is copying the ```ssh``` and ```wpa_supplicant.conf``` to new locations and expanding files in the non-boot section of the SD card.  When the green light stops flashing, the raspberrypi is then fully booted.  Continue with the next step.**

- [x] **check that the raspberrypi is visible on the network.  after the raspberrypi pings you back a few times, simply ```cntrl-c``` to end the ping.**  

    ```ping raspberrypi.local```  
    
- [x] **ssh into the raspberrypi - here's where the fun starts!**  

    ```ssh pi@raspberrypi.local```  
    
- [x] **the first connection attempt may return these** ***boy crying wolf*** **warnings; clear them as follows:**  

    ```ssh-keygen -R raspberrypi.local```  
    
- [x] **try connecting again with the default password,** ***et viola***  

    ```ssh pi@raspberrypi.local```  
    
    ```yes```
    
    ```raspberry```
    
- [x] **update and upgrade the OS if possible.**  

    ```sudo apt-get update```  
    
    ```sudo apt-get upgrade``` 
    
- [x] **configure the OS to see our sensor and know our timezone via command-line or GUI** 

    - [x] via command line
    
        - [x] toolset and lib for the i2c communications bus (might be optional).
        
            ```sudo apt-get install i2c-tools libi2c-dev python-smbus```
            
        - [x] set Interface Options to include i2c sensor
        
            ```sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules```
            
            ```sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt```
            
        - [x] set the time zone
        
            ```sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime```
    
- [x] **reboot the raspberrypi (see notes)**

    ```sudo reboot```  

- [x] **reconnect via ```ssh``` to the raspberrypi and test the sensor connection. this should return 77.**

    ```ssh pi@raspberrypi.local```

    ```sudo i2cdetect -y 1```

### install and set up gcloud SDK onto raspberrypi from a laptop terminal connected via ssh to the raspberrypi:

- [x] **if not already connected, then setup a secure shell connection with the raspberrypi.** 

    ```ssh pi@raspberrypi.local```  
    
- [x] **install gcloud SDK.**

    - [x] set the following environment variable so gcloud SDK version matches the OS of raspberrypi.
    
        ```export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"```
        
    - [x] set gcloud SDK installation location.
    
        ```echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list```
        
    - [x] this public key from Google's package repository ensures that Raspberry Pi will verify the security and trust the content during installation.
    
        ```curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -```
        
    - [x] redundant update of raspberrypi OS and gcloud SDK install; press ```Enter``` when asked.
    
        ```sudo apt-get update && sudo apt-get install google-cloud-sdk```
        
- [x] **gcloud setup for the raspberrypi terminal is similar to the laptop terminal, but ```gcloud auth login``` in mandatory.**

    - [x] log into gcloud as an authorized user.  follow instructions by copying the link provided into a browser, selecting login email from the popup, and copying the code back into the terminal window as shown. 

        ```gcloud auth login```

    - [x] export an environment variable for this ```PROJECT```.  note: this environment variable does not carry over from one terminal window to another.

        ```export PROJECT=users_project```

        ```gcloud config set project $PROJECT```

    - [x] get the account number from gcloud and export an  ```ACCOUNT```environment variable . 

        ```export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')```

    - [x] link the current project to the billing account saved in the ```ACCOUNT``` environment variable.

        ```gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT```

    - [x] preliminary information:

        ```gcloud config configurations describe default```

        ```gcloud alpha billing accounts list```
    
        ```gcloud projects list```
    
        ```gcloud config get-value core/project```

### install sensor's python module and its dependencies on to the rapsberrypi from a laptop terminal connected via ssh to the raspberry pi:

- [x] **if not already done so, then setup a secure shell log in to raspberrypi.**

    ```ssh pi@raspberrypi.local```  

- [x] **clone this project's repository  and cd into the ```gcp-iot-pipeline/rpi``` directory.**

    ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```  
    
    ```cd gcp-iot-pipeline/rpi```
    
- [x] upgrade python's package installer, pip.

    ```python3 -m pip install --upgrade pip```

- [x] **set up and source the  ```gcp-iot-pipeline/rpi``` directory's ```.venv``` virtual environment.**

    ```python3 -m venv .venv```  
    
    ```source .venv/bin/activate```  <-- This step is essential, and thus remotely executed shell scripts cannot cross from before this point to after this point. 

- [x] **install dependencies for the ```iot-data-pipeline.py``` weather sensor python module.**

    - [x] tendo is used in ```iot-data-pipeline.py``` to check if a script is running more than once:
    
        ```pip install tendo``` 
        
    - [x] these are pubsub and oauth2 SDK packages for python.  
    
        ```pip install --upgrade google-cloud-pubsub```
        
        ```pip3 install --upgrade oauth2client```  
        
    - [x] datetime is employed in ```iot-data-pipeline.py``` 
    
        ```pip3 install datetime``` 
        
   - [x] this is the new libary pubished by adafruit, the sensor manufacturer.  
   
        ```pip3 install adafruit-circuitpython-bmp280```  
    
### run the ```iot-analytics-depp``` weather sensor module from a laptop terminal connected via ssh to the raspberry pi:

- [x]  **if not already executed, then:** 

    - [x] setup a secure shell connection with the raspberrypi.

        ```ssh pi@raspberrypi.local```  

    - [x] change to the ```gcp-iot-pipeline/rpi``` directory.
    
        ```cd gcp-iot-pipeline/rpi```  
    
    - [x] source the  ```gcp-iot-pipeline/rpi``` directory's ```.venv``` virtual environment.

        ```source .venv/bin/activate```  

    - [x] export a ```PROJECT``` environment variable for the current project. to test whether the project environment variable is still available ```echo $PROJECT```.  if blank, set it again.
    
        ```export PROJECT=test123depp```
    
- [x] **from the ```iot-analytics-depp``` google storage bucket, copy the ```key.json``` file to the raspberrypi's ```credentials``` directory and set an environment variable ```GOOGLE_APPLICATION_CREDENTIALS``` for the file's path.** 

    ```mkdir -p ~/credentials```  
    
    ```gsutil cp gs://iot-analytics-depp/pub-key.json ~/credentials/```  
    
    ```export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/pub-key.json```  

- [x] **from the ```gcp-iot-pipeline/rpi``` directory, call the ```iot-data-pipeline.py``` sensor module with ```$PROJECT``` argument.**
    
    ```python3 iot-data-pipeline.py $PROJECT```.

## teardown the gcloud infrastructure as code from laptop terminal

- [x] **exports the current project id to an environment variable PROJECT.**

    ```gcloud config set project $PROJECT```

- [x] **removes every component except some artifact files in google storage.**

    ```bq --location US rm -f --table weatherData.weatherDataTable```  

    ```gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher```  

    ```gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```  

    ```gcloud pubsub topics delete weatherdata```  

    ```bq --location US rm -f --dataset weatherData```  

    ```gcloud functions delete iot_weather```  

    ```gsutil rm -r gs://iot-analytics-depp```  

    ```rm -r ~/$PROJECT```

    ```ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline```
    
    
    
Notes:

- [x] An alternative but not recommended method for erasing the SD card is a bit risky if you select the wrong disk.
    
        ```diskutil list``` 
        ```diskutil eraseDisk FAT32 NAME MBRFormat /dev/disk2```

- [x] these settings can be set via a GUI if you prefer to explore.

        ```sudo raspi config GUI```  
    
        - [x] Interface Options  
    
        - [x] P5 I2C Enable/discable automatic loading of I2C kernel module  
    
        - [x] Localisation Options  
    
        - [x] Timezone  


- [x] note: this is another point, prior to the next ```ssh pi@raspberrypi.local```, where one could copy the ```key.json``` to the raspberrypi via ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi``` and avoid use of the ```gs://iot-analytics-depp``` bucket.

- [x] note: the bucket is not essential but allows for the raspberry pi set up to come AFTER the laptop setup; were the latop set up AFTER then the pubsub key could be transfered to the pi via secure copy:
    ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi```

- [x] note: the auth-key.json is not used in this configuration, but was attempted as a way to avoid window pop ups in the set up of the raspberrypi's gcloud environment].*

- [x] did not use this code because did not establish auth key usage

        ```gcloud iam service-accounts keys create ~/$PROJECT/auth-key.json --iam-account $PROJECT@appspot.gserviceaccount.com```
        ```gsutil cp ~/$PROJECT/auth-key.json gs://iot-analytics-depp```
        ```gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com```

        ```export A=$(gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com | awk 'NR==3{print $1}')```
        ```until [ -z "$A" ];```
        ```do```
        ```export A=$(gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com | awk 'NR==2{print $1}')```
        ```gcloud iam service-accounts keys delete $A --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com;```
        ```export A=$(gcloud iam service-accounts keys list --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com | awk 'NR==3{print $1}')```
        ```done```

        ```export A=$(gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com | awk 'NR==3{print $1}')```
        ```until [ -z "$A" ];```
        ```do```
        ```export A=$(gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com | awk 'NR==2{print $1}')```
        ```gcloud iam service-accounts keys delete $A --iam-account $PROJECT@appspot.gserviceaccount.com```
        ```export A=$(gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com | awk 'NR==3{print $1}')```
        ```done```

        ```gcloud iam service-accounts keys list --iam-account $PROJECT@appspot.gserviceaccount.com```
