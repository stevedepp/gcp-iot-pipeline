# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery

## step by step manual construction

### 1. hardware:

#

#### 1.1 purchase raspberrypi et al for $60.20 + tax + shipping.  a shopping list is [here](http://www.adafruit.com/wishlists/514573).  if sold out, then google part number. [arrow](https://www.arrow.com/) is another good supplier.

- [x] any one of these 3 sensors will do; code is written for the [BMP 280 (info page here)](https://learn.adafruit.com/adafruit-bmp280-barometric-pressure-plus-temperature-sensor-breakout), but makes space for the [BME 280 (info page here)](https://learn.adafruit.com/adafruit-bme280-humidity-barometric-pressure-temperature-sensor-breakout).  In theory, you could make the code work for the [HTU21D-F for $15.95 with pre-soldered headers)](https://www.adafruit.com/product/3515).

    $14.95 [Adafruit BME280 I2C or SPI Temperature Humidity Pressure Sensor - STEMMA QT](https://www.adafruit.com/product/2652)

    $9.95 [Adafruit BMP280 I2C or SPI Temperature Barometric Pressure & Altitude Sensor - STEMMA QT](https://www.adafruit.com/product/2651)

- [x] raspberry pi zero is the no frills version of the raspberry pi.  this one has the headers (spikes) already soldered on for you. [$10 without pre-soldered headers here.](https://www.adafruit.com/product/3400)

    $14.00 [Raspberry Pi Zero WH (Zero W with Headers)](https://www.adafruit.com/product/3708)

- [x] if you get stuck in establishing a headless connection (you won't!), you need to connect to a monitor with an adapter.

    $2.95 [Mini HDMI Plug to Standard HDMI Jack Adapter](https://www.adafruit.com/product/2819)
    
- [x] raspberry pi zero does not have an SD card reader like it's higher priced cousins.  need this.  the strap falls off easily.

    $5.95 [USB MicroSD Card Reader/Writer - microSD / microSDHC / microSDXC](https://www.adafruit.com/product/939)
    
- [x] cases for the raspberry pi are handy since the board can get hot and can be delicate.  any one of these will do, but some dont fit the **new raspberry pi zero w**.

    $5.95 [Pibow Zero W Case for Raspberry Pi Zero W](https://www.adafruit.com/product/3471?gclid=CjwKCAiA_Kz-BRAJEiwAhJNY74r1Y4GEjLHUdvaw3BaQ3OW8YWY2tfsHXVrQ17Lj1hZrxjtxgHGCKhoCFM0QAvD_BwE)
    
    $5.95 [Pi Foundation Raspberry Pi Zero Case + Mini Camera Cable](https://www.adafruit.com/product/3446?gclid=CjwKCAiA_Kz-BRAJEiwAhJNY7wwu7bqhY7Ek1x1vKwvhk7JyL9rKqq5eVCQOzIbdP0CLXrfB9klpzRoCnwUQAvD_BwE)

- [x] power needs to be exactly what is specified for specific Raspberry Pi models.

    $7.50 [5V 2.5A Switching Power Supply with 20AWG MicroUSB Cable](https://www.adafruit.com/product/1995)
    
- [x] connect raspberry pi to sensors. you need only 4 but comes in pack of 40.

    $3.95 [Premium Female/Female Jumper Wires - 40 x 6"](https://www.adafruit.com/product/266)
    
- [x] raspberry pi zero does not have a usb port.  need this.

    $4.95 [USB Mini Hub with Power Switch - OTG Micro-USB](https://www.adafruit.com/product/2991)
    
- [x] need some way to read an sd card on your laptop.

- [x] soldering iron + solder (yes you can).

#

#### 1.2 solder sensor - "il buono, il cattivo e il brutto"

from left to right: presoldered by Adafruit.com, my second try which works, and my first try which doesn't.  intentially creepy, [this video](https://learn.adafruit.com/adafruit-guide-excellent-soldering/tools?gclid=CjwKCAiA_Kz-BRAJEiwAhJNY7zFcsxT_4s2VQRSbGrM2Du-dBkpU3QADsDU3OV7TiHUFkUIMYD3QtxoC-VMQAvD_BwE) from Adafruit helped alot.  touch iron to metal to heat and then touch solder to metal which is then hot enough to melt solder.  (don't touch iron to plastic board or circuits.)


<img width="876" alt="Pasted Graphic 3" src="https://user-images.githubusercontent.com/38410965/101258971-0a708b00-36f4-11eb-96b9-eaa439345b2a.png">

#

#### 1.3 connect raspberrypi to sensor

the pins have labels and technical terms but here you go: it depends on how you solder the headers (spikes). if you solder with long spikes one way, i would number the bmp280 or bme280 holes one way or another.  so you need to LOOK at the labels.  the raspberry pi labels the pins in the first column 1 3 5 7 9 11 etc and the second column 2 4 6 8 10.  Only connecting to odd pins on the raspberry pi:

![image](https://user-images.githubusercontent.com/38410965/101259788-0dba4580-36f9-11eb-91ba-2033146c69ae.png)

![](https://codelabs.developers.google.com/codelabs/iot-data-pipeline/img/392c2a9c85187094.png)

# 

ok let's go!

![IMG_1014](https://user-images.githubusercontent.com/38410965/101260684-6260bf00-36ff-11eb-96c0-d0b78de487cd.jpg)

(shown here with 2 sd cards but you only need 1; the other is just showing how the sd card fits into the [usb micro sd card reader/writer](https://www.adafruit.com/product/939) which fits inside the [usb mini hub](https://www.adafruit.com/product/2991).

#

### 2. gcloud and raspberrypi infrastructure as code from a laptop:

#### 2.1 from a laptop terminal, set up gcloud infrastructure:

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

    - [x] make a google storage bucket named ```iot-analytics-depp``` and copy the pub-key.json file to this bucket. [[see note (i)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#notes)]

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

#

#### 2.2 from a laptop terminal, setup SD card with raspberry pi OS and wifi connection settings:

- [x] **from a laptop terminal, using the raspberry pi imager, erase SD card via diskutil and load raspbian OS onto the SD card** [[see note (ii)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#notes)]

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

#

#### 2.3 from a laptop terminal, ssh connect to the raspberrypi, and set up and test connection with the sensor:

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
    
- [x] **configure the OS to see our sensor and know our timezone via command-line or GUI** [[see note (iii)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#notes)]

    - [x] via command line
    
        - [x] toolset and lib for the i2c communications bus (might be optional).
        
            ```sudo apt-get install i2c-tools libi2c-dev python-smbus```
            
        - [x] set Interface Options to include i2c sensor
        
            ```sudo grep -qxF i2c-dev /etc/modules || echo i2c-dev | sudo tee -a /etc/modules```
            
            ```sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt```
            
        - [x] set the time zone
        
            ```sudo cp /usr/share/zoneinfo/US/Eastern /etc/localtime```
    
- [x] **reboot the raspberrypi** [[see note (iv)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#notes)]

    ```sudo reboot```  

- [x] **reconnect via ```ssh``` to the raspberrypi and test the sensor connection. this should return 77.**

    ```ssh pi@raspberrypi.local```

    ```sudo i2cdetect -y 1```

#

#### 2.4 from a laptop terminal with ssh connecton to raspberrypi, install and set up gcloud SDK onto raspberrypi:

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

    - [x] log into gcloud as an authorized user.  follow instructions by copying the link provided into a browser, selecting login email from the popup, and copying the code back into the terminal window as shown.  [[see note (v)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#notes)]

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

#

#### 2.5 from a laptop terminal connected via ssh to the raspberry pi, install sensor's python module and its dependencies on to the rapsberrypi:

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
    
#

#### 2.6 from a laptop terminal connected via ssh to the raspberry pi, run the ```iot-analytics-depp``` weather sensor module:

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

#

#### 2.7 from laptop terminal connected via ssh to the raspberry pi, teardown the gcloud infrastructure as code:

- [x] **exports the current project id to an environment variable PROJECT.**

    ```gcloud config set project $PROJECT```

- [x] **removes every component except some artifact files in google storage.** [[see note (vi)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#notes)]

    ```bq --location US rm -f --table weatherData.weatherDataTable```  

    ```gcloud projects remove-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher```  

    ```gcloud iam service-accounts delete iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```  

    ```gcloud pubsub topics delete weatherdata```  

    ```bq --location US rm -f --dataset weatherData```  

    ```gcloud functions delete iot_weather```  

    ```gsutil rm -r gs://iot-analytics-depp```  

    ```rm -r ~/$PROJECT```

    ```ssh pi@raspberrypi.local rm -rf /home/pi/credentials /home/pi/gcp-iot-pipeline```
    
#    
    
### Notes:

- [x] i.  the bucket is not essential but allows for the raspberry pi set up to come AFTER the laptop setup; were the latop set up AFTER then the pubsub key could be transfered to the pi via secure copy:
    ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi```

- [x] ii.   an alternative but not recommended method for erasing the SD card is a bit risky if you select the wrong disk.
    
        ```diskutil list``` 
        ```diskutil eraseDisk FAT32 NAME MBRFormat /dev/disk2```

- [x] iii.  these settings can be set via a GUI if you prefer to explore.

    ```sudo raspi config GUI```  
    
    - [x] Interface Options  
    
    - [x] P5 I2C Enable/discable automatic loading of I2C kernel module  
    
    - [x] Localisation Options  
    
    - [x] Timezone  

- [x] iv. this is another point, prior to the next ```ssh pi@raspberrypi.local```, where one could copy the ```key.json``` to the raspberrypi via ```scp ~/$PROJECT/key.json pi@raspberrypi.local:/home/pi``` and avoid use of the ```gs://iot-analytics-depp``` bucket.

- [x] v.   the auth-key.json is not used in this configuration, but was attempted as a way to avoid window pop ups in the set up of the raspberrypi's gcloud environment].*

- [x] vi.  did not use this code because did not establish auth key usage 

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
