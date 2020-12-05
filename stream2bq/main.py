#import sys

import base64
from google.cloud import bigquery
import json

BQ_DATASET = 'weatherData'
BQ_TABLE = 'weatherDataTable'
BQ = bigquery.Client()

def iot_weather(event, context):

    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))

    msg = f'Function triggered by messageId {context.event_id} published at {context.timestamp}'
    print(msg)

    table = BQ.dataset(BQ_DATASET).table(BQ_TABLE)

    row = base64.b64decode(event['data']).decode('utf-8')
    row_json = json.loads(row)
    print('raw',row)
    print('json raw', row_json)
    print(table)
    errors = BQ.insert_rows_json(table,
                                 json_rows=row_json)
