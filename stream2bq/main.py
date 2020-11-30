#import sys

import base64
from google.cloud import bigquery
import json

BQ_DATASET = 'weatherData'
BQ_TABLE = 'weatherDataTable'
BQ = bigquery.Client()

def iot_weather(event, context):
    """
        Args:
         event (dict):  The dictionary with data specific to this type of
         event. The `data` field contains the PubsubMessage message. The
         `attributes` field will contain custom attributes if there are any.
         context (google.cloud.functions.Context): The Cloud Functions event
         metadata. The `event_id` field contains the Pub/Sub message ID. The
         `timestamp` field contains the publish time.
    """

    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))
    
    table = BQ.dataset(BQ_DATASET).table(BQ_TABLE)

    row = base64.b64decode(event['data']).decode('utf-8')
    row_json = json.loads(row)
    print('raw',row)
    print('json raw', row_json)
    print(table)
    errors = BQ.insert_rows_json(table,
                                 json_rows=row_json)
