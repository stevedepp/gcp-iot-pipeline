# gcp-iot-pipeline
Building a Serverless Data Pipeline : IoT to BigQuery

## todo:

### enhancements:
- [ ] use environment variables
   - [ ] anything with my name in it
- [ ] makefile for raspberrypi

## architecture

#### project:
sa key —> bucket
outside —> rpi sensor —> rpi —> python —> sa w key —> pubsub <— cloudfunction —> bq dataset.table

#### msds434deppfp:
iot-weather-publisher key.json —> iot-analytics-depp

weather —> bmp280 —> pi —> iot-data-pipeline-depp.py --> iot-weather-publisher w key.json —> weatherdata —> main.py —> weatherData.weatherDataTable —> weatherDataTable-schema

## code

- [x] laptop terminal environment:

    ```rm -rf .venv```

    ```python3 -m venv .venv```

    ```source .venv/bin/activate```

    ```export PROJECT=msds434deppfp```

    ```export ACCOUNT=msds434deppfp```

    ```python3 -m pip install --upgrade pip```

- [x] gcp set up:

    ```gcloud config set project $PROJECT```

    ```gcloud beta billing projects link $PROJECT --billing-account $ACCOUNT```

- [x] pubsub set up:

    ```gcloud services enable pubsub.googleapis.com```

    ```gcloud pubsub topics create weatherdata```

- [x] iam:

    ```gcloud iam service-accounts create iot-weather-publisher --project $PROJECT```

    ```gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:iot-weather-publisher@$PROJECT.iam.gserviceaccount.com" --role=roles/pubsub.publisher```

    ```gcloud iam service-accounts keys create ~/key.json --iam-account iot-weather-publisher@$PROJECT.iam.gserviceaccount.com```

    ```gsutil mb gs://iot-analytics-depp```

    ```gsutil cp ~/key.json gs://iot-analytics-depp```

