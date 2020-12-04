#!/bin/bash
PROJECT = $1
ssh pi@raspberrypi.local 'bash -s' < ./shells/5_dependencies_run_PROJECT.sh $PROJECT
