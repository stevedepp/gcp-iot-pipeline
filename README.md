# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery


## quickstart [(details)](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#5-shell-scripts-and-4-manual-interventions-to-assemble-the-gcloud--raspeberrypi-infra): assumes available raspberrypi + SD card + sensor 

- [x] [clone the repository](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-1-clone-the-repository)
- [x] [`./shells/1_gcp_setup_PROJECT.sh`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shells1_gcp_setup_projectsh)
- [x] [initialize the SD card](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-2-initialize-the-sd-card)
- [x] [`./shells/2_sd_card_wifi.sh`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shells2_sd_card_wifish)
- [x] [setup communications with the raspberrypi](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-3-setup-communications-with-the-raspberrypi)
- [x] [`./shells/3_update_sd_os.sh`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shells3_update_sd_ossh)
- [x] [source the raspberrypi's virtual environment](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#manual-4-source-the-raspberrypis-virtual-environment)
- [x] [`./shells/4_test_sensor_gcloud_install_setup_dependencies_run_PROJECT.sh project_id`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shells4_test_sensor_gcloud_install_setup_dependencies_run_projectsh)
- [x] [`./shells/5_teardown_PROJECT.sh my_project_id`](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/shells/README.md#shells5_teardown_projectsh)


## architecture diagram:

<img width="452" alt="Google Cloud Platform" src="https://user-images.githubusercontent.com/38410965/101238537-eccd0280-36ae-11eb-8ff9-478f6fa6b809.png">

#### project:
sa key —> bucket
outside —> rpi sensor —> rpi —> python —> sa w key —> pubsub <— cloudfunction —> bq dataset.table

#### msds434deppfp:
iot-weather-publisher key.json —> iot-analytics-depp

weather —> bmp280 —> pi —> iot-data-pipeline-depp.py --> iot-weather-publisher w key.json —> weatherdata —> main.py —> weatherData.weatherDataTable —> weatherDataTable-schema

## full manual construction of infra is found [here](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/manual.md#step-by-step-manual-construction) 

## developer notes are found [here](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/developer.md#developer-notes)
