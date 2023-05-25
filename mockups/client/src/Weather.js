import React, { useState } from 'react';
import axios from 'axios';

const Weather = () => {
  const [weatherData, setWeatherData] = useState(null);
  const [latitude, setLatitude] = useState('');
  const [longitude, setLongitude] = useState('');

  const handleFormSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.get(`http://localhost:5000/weather?lat=${latitude}&lon=${longitude}`);
      setWeatherData(response.data);
      console.log(response.data);
    } catch (error) {
      console.error(error);
    }
  };

  const convertKelvinToCelsius = (kelvin) => {
    return (kelvin - 273.15).toFixed(2);
  };

  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp * 1000); // Multiply by 1000 to convert from seconds to milliseconds
    return date.toLocaleString();
  };

  const getCoordinates = () => {
    navigator.geolocation.getCurrentPosition((position) => {
      setLatitude(position.coords.latitude);
      setLongitude(position.coords.longitude);
      console.log(latitude);
      console.log(longitude);
    });
  };

  return (
    <div>
      <form onSubmit={handleFormSubmit}>
        <button type="button" onClick={getCoordinates}>Get Location</button>
        <button type="submit">Get Weather</button>
      </form>
      {weatherData && (
        <div>
          <h2>Current Weather</h2>
          <p>Temperature: {convertKelvinToCelsius(weatherData["current"]["temp"])}°C</p>
          <p>Feels Like: {convertKelvinToCelsius(weatherData["current"]["feels_like"])}°C</p>
          <p>Humidity: {weatherData["current"]["humidity"]}%</p>
          <p>Wind Speed: {weatherData["current"]["wind_speed"]}m/s</p>
          <p>Wind Direction: {weatherData["current"]["wind_deg"]}°</p>
          <p>Cloudiness: {weatherData["current"]["clouds"]}%</p>
          <p>Weather: {weatherData["current"]["weather"][0]["description"]}</p>
          <h2>Minutely Precipitation</h2>
          <ul>
            {weatherData.minutely.map((minuteData, index) => (
              <li key={index}>
                <p>Timestamp: {formatTimestamp(minuteData.dt)}</p>
                <p>Precipitation: {minuteData.precipitation} mm</p>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
};

export default Weather;
