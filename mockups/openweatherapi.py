import os
import requests
from dotenv import load_dotenv

# Load the environment variables
load_dotenv()

# OpenWeather API key
API_KEY = os.getenv("OPENWEATHER_API_KEY")
print("API_KEY: ", API_KEY)

# Set the city and country code
CITY = "Battaramulla"
COUNTRY_CODE = "LK"

# Making the request using url
URL = "https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric".format(
    city=CITY,
    api_key=API_KEY,
)

# Making the request using url
URL2 = "https://api.openweathermap.org/data/3.0/onecall?lat=33.44&lon=-94.04&exclude=hourly,daily&appid={api_key}".format(
    api_key=API_KEY,
)

response = requests.get(URL)

# Check the response status code
if response.status_code == 200:
    # The request was successful, so get the weather data
    weather_data = response.json()

    # Print the weather data
    print(weather_data)
else:
    # The request failed, so print the error message
    print(response.status_code)
    print(response.text)
