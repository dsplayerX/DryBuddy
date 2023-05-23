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
          <p>City: {weatherData.name}</p>
          <p>Temperature: {convertKelvinToCelsius(weatherData.main.temp)}°C</p>
          <p>Feels Like: {convertKelvinToCelsius(weatherData.main.feels_like)}°C</p>
          <p>Minimum Temperature: {convertKelvinToCelsius(weatherData.main.temp_min)}°C</p>
          <p>Maximum Temperature: {convertKelvinToCelsius(weatherData.main.temp_max)}°C</p>
          <p>Weather: {weatherData.weather[0].main}</p>
          <p>Description: {weatherData.weather[0].description}</p>
          <p>Humidity: {weatherData.main.humidity}%</p>
          <p>Wind Speed: {weatherData.wind.speed}m/s</p>
          <p>Wind Direction: {weatherData.wind.deg}°</p>
          <p>Cloudiness: {weatherData.clouds.all}%</p>
          <p>Pressure: {weatherData.main.pressure}hPa</p>
          <p>Visibility: {weatherData.visibility}m</p>
          <p>Sunrise: {new Date(weatherData.sys.sunrise * 1000).toLocaleTimeString()}</p>
          <p>Sunset: {new Date(weatherData.sys.sunset * 1000).toLocaleTimeString()}</p>
          <p>Latitude: {weatherData.coord.lat}</p>
          <p>Longitude: {weatherData.coord.lon}</p>
          <p>Country: {weatherData.sys.country}</p>
        </div>
      )}
    </div>
  );
};

export default Weather;
