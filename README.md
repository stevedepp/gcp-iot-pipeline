## Building a Serverless Data Pipeline : IoT to BigQuery

![IMG_1014](https://user-images.githubusercontent.com/38410965/101260684-6260bf00-36ff-11eb-96c0-d0b78de487cd.jpg)

[.](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#1-hardware)

#

### demo video:  

Please click on the video below to unmute the sound or read the transcript [here](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/demo_transcript.md).  

<video src="https://user-images.githubusercontent.com/38410965/111925052-9d53ec00-8a7d-11eb-86d4-567082491bd4.mp4" autoplay controls loop muted style="max-width;">
</video>

#

### quickstart:  
assumes available raspberrypi + SD card + sensor et al [(listed in the full manual infrastructure construction instructions)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#1-hardware) 

- [x] [clone the repository](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-1-clone-the-repository)
- [x] [`./shells/1_gcp_setup_PROJECT.sh`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shell-script-1-shells1_gcp_setup_projectsh)
- [x] [initialize the SD card](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-2-initialize-the-sd-card)
- [x] [`./shells/2_sd_card_wifi.sh`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shell-script-2-shells2_sd_card_wifish)
- [x] [setup communications with the raspberrypi](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-3-setup-communications-with-the-raspberrypi)
- [x] [`./shells/3_update_sd_os.sh`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shell-script-3-shells3_update_sd_ossh)
- [x] [source the raspberrypi's virtual environment](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-4-source-the-raspberrypis-virtual-environment)
- [x] [`./shells/4_test_sensor_gcloud_install_setup_dependencies_run_PROJECT.sh project_id`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shell-script-4-shells4_test_sensor_gcloud_install_setup_dependencies_run_projectsh)
- [x] [`./shells/5_teardown_PROJECT.sh my_project_id`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shell-script-5-shells5_teardown_projectsh)


### architecture diagram:

![image](https://user-images.githubusercontent.com/38410965/101238673-b80d7b00-36af-11eb-9917-05abd428979d.png)

#### $PROJECT:

	service account key —> bucket 
					-> python @ raspberry —> pubsub —> cloudfunction —> bq dataset.table
	temp press humidity —> sensor 

#### test456depp:

	pub-key —> iot-analytics
				 -> iot-data-pipeline.py —> weatherdata —> main.py —> weatherData.weatherDataTable
	bmp280 —> raspberry pi    
	
### full manual construction of infrastructure is found [here](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#step-by-step-manual-construction) 

### full command-line construction of infra is found [here](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#5-shell-scripts-and-4-manual-steps-to-assemble-the-gcloud--raspeberrypi-infra)

### developer notes are found [here](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/developer.md#developer-notes)
