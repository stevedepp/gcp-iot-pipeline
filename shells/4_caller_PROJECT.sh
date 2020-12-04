#!/bin/bash
PROJECT=$1
ssh pi@raspberrypi.local 'bash -s' < ./shells/4_test_sensor_gcloud_install_setup_PROJECT.sh $PROJECT
