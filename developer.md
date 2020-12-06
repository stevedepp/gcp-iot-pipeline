# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery

## developer notes:

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
- [ ] linting of the above CLT elements if executed in python
- [ ] CICD via github actions / circleci
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
 


[quickstart](https://github.com/stevedepp/gcp-iot-pipeline/blob/main/README.md#quickstart)
