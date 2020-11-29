
from google.cloud import bigquery
from oauth2client.client import GoogleCredentials
from apiclient.discovery import build
import base64
    
credentials = GoogleCredentials.get_application_default()
service = build('bigquery', 'v2')

projectId = "msds434fp"
datasetId = "weatherData"
tableId = "weatherDataTable"
table_id = f"{projectId}.{datasetId}.{tableId}"
client = bigquery.Client(project=projectId)

def hello_pubsub(event, context):
    """Background Cloud Function to be triggered by Pub/Sub."""
    
    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))
    
    """
    name = {"sensorID": "NewHope", "timecollected": "2020-11-20 04:29:56", "zipcode": 18938, "latitude": 40.364342, "longitude": -74.92, "temperature": 26.41, "humidity": 28.52, "dewpoint": 100.0, "pressure": 1009.8}
    """
    
    name = base64.b64decode(event['data']).decode('utf-8')
    rows_to_insert = [name]
    errors = client.insert_rows_json(table_id, rows_to_insert)  # Make an API request.
    if errors == []:
        print("New rows have been added.")
    else:
        print("Encountered errors while inserting rows: {}".format(errors))
