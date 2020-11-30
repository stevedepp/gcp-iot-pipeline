import time
import board
import busio
import adafruit_bmp280

# from iot
import datetime
import json
from google.cloud import pubsub_v1
from oauth2client.client import GoogleCredentials
from tendo import singleton

# from iot
me = singleton.SingleInstance() # will sys.exit(-1) if other instance is running
SEND_INTERVAL = 60 #seconds
credentials = GoogleCredentials.get_application_default()
# change project to your Project ID
project="msds434fp"
# change topic to your PubSub topic name
topic = "weatherdata"
# set the following four constants to be indicative of where you are placing your weather sensor
sensorID = "NewHope"
sensorZipCode = 18938
sensorLat = 40.364342
sensorLong = -74.951492

# Create library object using our Bus I2C port
i2c = busio.I2C(board.SCL, board.SDA)
sensor = adafruit_bmp280.Adafruit_BMP280_I2C(i2c)

# change this to match the location's pressure (hPa) at sea level
sensor.sea_level_pressure = 1013.25

def read_sensor(weathersensor):
    tempF = weathersensor.temperature
    pressureInches = weathersensor.pressure
    dewpoint = 100.000                  # weathersensor.dewpoint
    humidity = weathersensor.altitude   # weathersensor.humidity
    temp = tempF
    pres = pressureInches
    dew = dewpoint
    hum = humidity
    return (temp, hum, dew, pres)

def createJSON(id, timestamp, zip, lat, long, temperature, humidity, dewpoint, pressure):
    data = {
      'sensorID' : id,
      'timecollected' : timestamp,
      'zipcode' : int(zip),
      'latitude' : lat,
      'longitude' : long,
      'temperature' : temperature,
      'humidity' : humidity,
      'dewpoint' : dewpoint,
      'pressure' : pressure
    }

    json_str = json.dumps(data)
    return json_str

def main():
    publisher = pubsub_v1.PublisherClient()
    topicName = 'projects/' + project + '/topics/' + topic
    print(topicName)
    topic_path = publisher.topic_path(project, topic)
    print(topic_path)
    last_checked = 0
    while True:
        if time.time() - last_checked > SEND_INTERVAL:
            last_checked = time.time()
            temp, hum, dew, pres = read_sensor(sensor)
            print(temp,hum, dew, pres)
            currentTime = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
            s = ", "
            weatherJSON = createJSON(sensorID, currentTime, sensorZipCode, sensorLat, sensorLong, temp, hum, dew, pres)
            print(weatherJSON)
            weatherJSON = weatherJSON.encode("utf-8")
            try:
                future = publisher.publish(topicName, weatherJSON)
                print(weatherJSON)
                print(future)
            except:
                print("There was an error publishing weather data.")
        time.sleep(0.5)

if __name__ == '__main__':
    main()
