from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from dotenv import load_dotenv
import os

# Load the environment variables
load_dotenv()

# OpenWeather API key
API_KEY = os.getenv("OPENWEATHER_API_KEY")

app = Flask(__name__)
CORS(app)

@app.route('/weather', methods=['GET'])
def get_weather():
    print("get_weather() called: ")
    api_key = API_KEY
    latitude = request.args.get('lat')
    longitude = request.args.get('lon')
    print("latitude: ", latitude)
    print("longitude: ", longitude)

    weather_url = f'https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}&appid={api_key}'
    #forecast_url = f'https://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longitude}&appid={api_key}'

    response_weather = requests.get(weather_url)

    weather_data = response_weather.json()
    print("weather_data: ")
    print(weather_data)

    return jsonify(weather_data)

if __name__ == '__main__':
    app.run(port=os.getenv("PORT", default=5000), debug=True)
