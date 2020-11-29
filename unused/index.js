/**
 * Background Cloud Function to be triggered by PubSub.
 *
 * @param {object} event The Cloud Functions event.
 * @param {function} callback The callback function.
 */
exports.subscribe = function (event, callback) {
  const BigQuery = require('@google-cloud/bigquery');
  const projectId = "msds434fp"; //Enter your project ID here
  const datasetId = "weatherData"; //Enter your BigQuery dataset name here
  const tableId = "weatherDataTable"; //Enter your BigQuery table name here -- make sure it is setup correctly
  const PubSubMessage = event.data;
  // Incoming data is in JSON format
  const incomingData = PubSubMessage.data ? Buffer.from(PubSubMessage.data, 'base64').toString() : `{"sensorID": "na","timecollected":"01/01/1970 00:00:00","zipcode":"00000","latitude":"0.0","longitude":"0.0","temperature":"-273","humidity":"-1","dewpoint":"-273","pressure":"0"}`;
  const jsonData = JSON.parse(incomingData);
  var rows = [jsonData];

  console.log(`Uploading data: ${JSON.stringify(rows)}`);

  // Instantiates a client
  const bigquery = BigQuery({
    projectId: projectId
  });

  // Inserts data into a table
  bigquery
    .dataset(datasetId)
    .table(tableId)
    .insert(rows)
    .then((foundErrors) => {
      rows.forEach((row) => console.log('Inserted: ', row));

      if (foundErrors && foundErrors.insertErrors != undefined) {
        foundErrors.forEach((err) => {
            console.log('Error: ', err);
        })
      }
    })
    .catch((err) => {
      console.error('ERROR:', err);
    });
  // [END bigquery_insert_stream]


  callback();
};
