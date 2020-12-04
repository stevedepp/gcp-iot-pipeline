#!/bin/bash
PROJECT=$1

# replace printit with ellens or 5
ssh pi@raspberrypi.local 'bash -s' < ./shells/ellens.sh $PROJECT
