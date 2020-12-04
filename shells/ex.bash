#!/bin/bash
# call this with ./shells/ex.bash test456depp
PROJECT=$1
scp ~/$PROJECT/{pub-key.json,auth-key.json} pi@raspberrypi.local:/home/pi/

# replace printit with ellens or 5
ssh pi@raspberrypi.local 'bash -s' < ./shells/printit.sh $PROJECT
