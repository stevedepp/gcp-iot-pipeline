#!/bin/bash

PROJECT=$1

gcloud auth login

export PROJECT=test123depp

gcloud config set project $PROJECT

export ACCOUNT=$(gcloud alpha billing accounts list | awk 'NR==2{print $1}')

gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT

gcloud config configurations describe default

gcloud alpha billing accounts list

gcloud projects list

gcloud config get-value core/project

git clone https://github.com/stevedepp/gcp-iot-pipeline.git

cd gcp-iot-pipeline

rm -rf .venv

python3 -m venv .venv
