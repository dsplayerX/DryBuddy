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

    onecall_url = f"https://api.openweathermap.org/data/3.0/onecall?lat={latitude}&lon={longitude}&exclude=alerts&appid={API_KEY}"
    response = requests.get(onecall_url)

    onecall_data = response.json()

    print("OneCall Data: ")
    print(onecall_data)

    print("\n\n\n Minutely Data: ")
    print(onecall_data["minutely"])

    return jsonify(onecall_data)

if __name__ == '__main__':
    app.run(port=os.getenv("PORT", default=5000), debug=True)
