import React, { Component } from "react";
import ReactDOM from "react-dom";

class Coords extends Component {
  state = {
    latitude: "",
    longitude: "",
  };

  componentDidMount() {
    navigator.geolocation.getCurrentPosition((position) => {
      this.setState({
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
      });
    });
  }

  render() {
    return (
      <div>
        <h4>Current Location</h4>
        <p>Latitude: {this.state.latitude}</p>
        <p>Longitude: {this.state.longitude}</p>
      </div>
    );
  }
}

export default Coords;
