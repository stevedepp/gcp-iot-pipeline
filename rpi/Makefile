ssh:
	ssh pi@raspberrypi.local
env:
	python3 -m venv .venv
apt:
	sudo apt-get updat
	sudo apt-get upgrade
	sudo raspi config GUI
gcloud:
        echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" |  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        sudo apt-get update && sudo apt-get install google-cloud-sdk
	gcloud init --console-only

dependencies:
	pip install tendo
	pip install --upgrade google-cloud-pubsub
	pip3 install --upgrade oauth2client
	pip3 install datetime
	pip3 install adafruit-circuitpython-bmp280
sensor:
	mkdir -p ~/credentials
	gsutil cp gs://iot-analytics-depp/key.json ~/credentials/
data:
	cd ~/gcp-iot-pipeline/rpi
	python3 iot-data-pipeline.py $$PROJECT

reboot:
	sudo reboot
i2c:
	sudo i2cdetect -y 1
