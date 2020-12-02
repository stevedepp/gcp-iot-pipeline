# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery

## todo:

### enhancements: any enhancement checked here should go into delivery statement as feature
- [x] use environment variables  
- [x] think venv before anything else in rpi  -  test that
- [ ] is aliasing source .venv/bin/activate done at root or can be scripted and removed at teardown?
- [ ] take inventory of which api are open on start and close when finished - see mon log notes
- [ ] makefile for raspberrypi  
- [ ] different adafruit sensors in CLT  
- [ ] different schema for bme and bmp  
- [ ] display data in flask page
- [ ] CLT enables datadownload from bigquery segmented by date or temp range
- [ ] CLT asks for project and account infor and adafruit sensor
- [ ] CLT asks for account then project name and if project doesnt exist asks if wants to create project
- [ ] more print info in logging - pythonjsonlogger
- [ ] query from CLT with max rows ```bq --location=US query --use_legacy_sql=false 'SELECT columns FROM weatherData.weatherDataTable'```  
- [ ] pretty print ```bq ls --format=pretty mydataset_depp```  
- [x] teardown use PROJECT
- [ ] teardown doesnt yet remove bucket from cloud function
- [ ] CICD tool  
- [ ] links to all the sources in the readme file   
- [ ] is this too slow ```gcloud functions logs read --limit 50```?  
- [x] remove key.json when tearing down
- [x] test in diffrent project
https://cloud.google.com/functions/docs/testing/test-background
- [ ] monitoring-run it and open monitoring
- [ ] logging  
- [ ] linting  
- [ ] can include toy python scripts for sensor illustraion
- [ ] shell script to make the wpa_supplicant.conf with hashed pwd

### rejected features
- [ ] random number suffix to storage bucket name is rejected as a feature because the name needs to be employed on the laptop and on the raspberry pi.
- [x] encrypt the wifi pwd by running a preparred script that <-- No. Use XXX. 



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

https://app.diagrams.net/?splash=0&libs=gcp
https://www.cloudockit.com/the-12-most-used-google-cloud-diagrams-explained/

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

- [x] **preliminary information**:

    ```gcloud config configurations describe default```
    
    ```gcloud alpha billing accounts list```
    
    ```gcloud projects list```
    
    ```gcloud config get-value core/project```

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
    ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi```
    
    - [x] for information:
    
        ```gcloud iam service-accounts list```
        
        ```gcloud projects get-iam-policy $PROJECT```
        
        ```gcloud iam service-accounts keys list --iam-account iot-weather-publisher@msds434fp.iam.gserviceaccount.com```
        
        ```ls ~/$PROJECT/key.json```
        
        ```cat ~/$PROJECT/key.json```
        
        ```gsutil ls gs://iot-analytics-depp```

- [x] **big query set up:**

    - [x] preliminary information:
    
        

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

### setup raspberry pi OS and settings from a laptop:

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
    
    - [x] When the SD card loading is complete, pull out the SD card and put it back in and move to the next step.
    
- [x] **load Wifi preferences onto SD card boot disk**

    - [x] clone this project's repository and change to the ```gcp-iot-pipeline``` directory inside.  

        ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```        
        
        ```cd gcp-iot-pipeline``` 

    - [x] OSX can only see the SD card's ```boot``` directory found at ```/Volumes/boot``` because the boot is the only available SD card directory that is agnostic / firendly to linux/OSX & windows platforms.  View the ```boot``` directory's conents, but don't change to from the ```gcp-iot-pipeline``` directory.
    
        ```ls /Volumes/boot```  
        
    - [x] create a blank ```ssh``` file so that this raspberrypi's first *headless* boot will enable ssh.  this can be accomplished via ```touch /Volumes/boot/ssh```,  but there's an ```ssh``` file already in the repository's ```rpi``` directory; so take the easy road by copying this ```ssh``` file from the repository 's ```rpi```directory to the raspberry pi's ```/Volumes/boot``` directory.  
    
        ```cp rpi/ssh /Volumes/boot```  
        
    - [x] make a ```wpa_supplicant.conf``` file with your routers login/password which can be encrypted.  
    
        image here
                    
    - [x] there's a ```wpa_supplicant.conf``` file already in the repository's ```rpi``` directory; copy it from there to the raspberry pi's ```/Volumes/boot``` directory.

        ```cp rpi/wpa_supplicant.conf /Volumes/boot```  
        
    - [x] open the ```wpa_supplicant.conf``` and enter the passphrase for your wifi network(s).
    
        ```nano /Volumes/boot/wpa_supplicant.conf```
        
- [x] **safely eject the SD card.**

- [x] **put SD card into the raspberrypi. then, plug the raspberrypi into the wall**  

- [x] **check that the raspberrypi is visible on the network**  

    ```ping raspberrypi.local```  
    
- [x] **ssh into the raspberrypi - here's where the fun starts!**  

    ```ssh pi@raspberrypi.local```  
    
- [x] **the first connection attempt may return these** ***boy crying wolf*** **warning; clear them as follows:**  

    ```ssh-keygen -R raspberrypi.local```  
    
- [x] **try connecting again,** ***et viola***  

    ```ssh pi@raspberrypi.local```  

- [x] **update and upgrade the OS if possible.**  

    ```sudo apt-get update```  
    
    ```sudo apt-get upgrade``` 
    
- [x] **configure the OS to see our sensor and know our timezone via command-line or GUI** 

    - [x] via command line
    
        - [x] toolset and lib for the i2c communications bus
        
            ```sudo apt-get install i2c-tools libi2c-dev python-smbus```
            
        - [x] set Interface Options to include i2c sensor
        
            ```sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules```
            
            ```sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt```
            
        - [x] set the time zone
        
        ```sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime```

    - [x] or via GUI

        ```sudo raspi config GUI```  
    
        - [x] Interface Options  
    
        - [x] P5 I2C Enable/discable automatic loading of I2C kernel module  
    
        - [x] Localisation Options  
    
        - [x] Timezone  
    
- [x] reboot the raspberrypi 

    ```sudo reboot```  

*[note: this is another point, prior to the next ```ssh pi@raspberrypi.local```, where one could copy the ```key.json``` to the raspberrypi via   ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi``` and avoid use of the ```gs://iot-analytics-depp``` bucket.]*

### test sensor:

- [x] setup a secure shell log in to raspberrypi: 

    ```ssh pi@raspberrypi.local```  

- [x] should read 77.

    ```sudo i2cdetect -y 1```

### install gcloud SDK onto raspberrypi from a laptop terminal ssh into raspberry pi:

- [x] setup a secure shell log in to raspberrypi: 

    ```ssh pi@raspberrypi.local```  
    
- [x] install gcloud SDK

    - [x] set the following environment variable so gcloud SDK version matches the OS of raspberrypi.
    
        ```export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"```
        
    - [x] set gcloud SDK installation location.
    
        ```echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list```
        
    - [x] this public key from Google's package repository ensures that Raspberry Pi will verify the security and trust the content during installation.
    
        ```curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -```
        
    - [x] redundant update of raspberrypi OS and gcloud SDK install; press ```Enter``` when asked.
    
        ```sudo apt-get update && sudo apt-get install google-cloud-sdk```
    
    - [x] set up gcloud, selecting the current project and region. CHECK SEE IF THIS IS NEEDED.

        ```gcloud init --console-only```  

### install sensor's python module and its dependencies on to the rapsberrypi from a laptop terminal ssh into raspberry pi:

- [x] if not already done so, then setup a secure shell log in to raspberrypi: 

    ```ssh pi@raspberrypi.local```  

- [x] clone this project's repository  and cd into the ```gcp-iot-pipeline/rpi``` directory.

    ```git clone https://github.com/stevedepp/gcp-iot-pipeline.git```  
    
    ```cd gcp-iot-pipeline/rpi```      

- [x] set up and source a virtual environment.  

    ```python3 -m venv .venv```  
    
    ```source .venv/bin/activate```  

- [x] install dependencies with python's package manaager, pip.

    - [x] tendo is used in ```check_weather.py``` to check if a script is running more than once:
    
        ```pip install tendo``` 
        
    - [x] these are pubsub and oauth2 packages for python.  
    
        ```pip install --upgrade google-cloud-pubsub``` 
        
        ```pip3 install --upgrade oauth2client```  
        
    - [x] datetime is employed in ```iot-data-pipeline.py``` 
    
        ```pip3 install datetime``` 
        
   - [x] this is the new libary pubished by adafruit, the sensor manufacturer.  
   
        ```pip3 install adafruit-circuitpython-bmp280```  
    
### run the weather sensor module to collect data
        
- [x] if not already done so, then setup a secure shell log in to raspberrypi, change to the ```gcp-iot-pipeline``` directory, and source its virtual environment: 

    ```ssh pi@raspberrypi.local```  
    
    ```cd gcp-iot-pipeline/rpi```  
    
    ```source .venv/bin/activate```  

- [x] export an environment variable for this project.  

    ```export PROJECT=test123depp```
    
- [x] from the ```iot-analytics-depp``` google storage bucket, copy the ```key.json``` file to the raspberrypi's ```credentials``` directory and set an environment variable ```GOOGLE_APPLICATION_CREDENTIALS``` for the file's path. 

    ```mkdir -p ~/credentials```  
    
    ```gsutil cp gs://iot-analytics-depp/key.json ~/credentials/```  
    
    ```export GOOGLE_APPLICATION_CREDENTIALS=/home/pi/credentials/key.json```  
    

- [x] change to the ```rpi``` directory and call the ```iot-data-pipeline.py``` sensor module with ```$PROJECT``` argument.

    ```cd ~/gcp-iot-pipeline/rpi```
    
    ```python3 iot-data-pipeline.py $PROJECT```.


## teardown the gcloud infrastructure as code from laptop terminal

- [x] exports the current project id to an environment variable PROJECT.

    ```gcloud config set project $PROJECT```

- [x] removes every component except some artifact files in google storage.

    ```bq --location US rm -f --table weatherData.weatherDataTable```  

    ```gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher```  

    ```gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```  

    ```gcloud pubsub topics delete weatherdata```  

    ```bq --location US rm -f --dataset weatherData```  

    ```gcloud functions delete iot_weather```  

    ```gsutil rm -r gs://iot-analytics-depp```  

    ```rm -r ~/$PROJECT```

    ```ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline```
    
    
