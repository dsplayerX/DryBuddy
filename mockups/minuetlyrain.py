import requests
import json
from datetime import datetime
from dotenv import load_dotenv
import os

# Load the environment variables
load_dotenv()

# OpenWeather API key
API_KEY = os.getenv("OPENWEATHER_API_KEY")
LATITUDE = 6.8982721  # Replace with the latitude of your location
LONGITUDE = 79.9226916  # Replace with the longitude of your location

def get_precipitation_forecast():
    url = f"https://api.openweathermap.org/data/3.0/onecall?lat={LATITUDE}&lon={LONGITUDE}&exclude=alerts&appid={API_KEY}"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = json.loads(response.text)
        print(data["current"]["dt"])
        for minute_data in data["minutely"]:
            timestamp = datetime.fromtimestamp(minute_data["dt"])
            precipitation = minute_data["precipitation"]
            print(f"{timestamp}: Precipitation: {precipitation} mm")
    else:
        print("Failed to retrieve weather data.")
        print(response.text)

get_precipitation_forecast()
