import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DryBuddyApp());
}

Future<String> loadApiKey() async {
  final secretFile = await rootBundle.loadString('assets/secrets.yaml');
  final secrets = loadYaml(secretFile);
  return secrets['OPENWEATHER_API_KEY'] as String;
}

class DryBuddyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DryBuddy App',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String _cityName = '';
  String _temperature = '';
  String _weatherDescription = '';
  String _latitude = '';
  String _longitude = '';
  String _feelsLike = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  void _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    // Check if location permission is granted
    final locationPermissionStatus = await Permission.locationWhenInUse.status;
    if (locationPermissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        // Fetch weather data using the obtained latitude and longitude
        print('Latitude: ${position.latitude}');
        print('Longitude: ${position.longitude}');

        _fetchWeatherDataByLocation(position.latitude, position.longitude);
      } catch (error) {
        setState(() {
          _isLoading = false;
          _weatherDescription =
              'Error fetching data. Please enable location access or try again later.';
        });
        // Show a dialog or snackbar to inform the user and provide an alternative method to fetch weather data
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Location Access Denied'),
              content:
                  Text('Please enable location access or try again later.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
    } else {
      // Location permission denied, request permission
      final permissionStatus = await Permission.locationWhenInUse.request();
      if (permissionStatus.isGranted) {
        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          // Fetch weather data using the obtained latitude and longitude
          _fetchWeatherDataByLocation(position.latitude, position.longitude);
        } catch (error) {
          setState(() {
            _isLoading = false;
            _weatherDescription =
                'Error fetching data. Please enable location access or try again later.';
          });
          // Show a dialog or snackbar to inform the user and provide an alternative method to fetch weather data
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Location Access Denied'),
                content:
                    Text('Please enable location access or try again later.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }
      } else {
        setState(() {
          _isLoading = false;
          _weatherDescription =
              'Error fetching data. Please enable location access or try again later.';
        });
        return;
      }
    }
  }

  void _fetchWeatherDataByLocation(double latitude, double longitude) async {
    final apiKey = await loadApiKey();
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final mainData = data['main'];
        final weatherData = data['weather'][0];

        setState(() {
          _cityName = data['name'];
          _temperature = (mainData['temp'] - 273.15).toStringAsFixed(2);
          _weatherDescription = weatherData['description'];
          _latitude = latitude.toStringAsFixed(2);
          _longitude = longitude.toStringAsFixed(2);
          _feelsLike = (mainData['feels_like'] - 273.15).toStringAsFixed(2);
        });
      } else {
        setState(() {
          _cityName = '';
          _temperature = '';
          _weatherDescription = 'Error fetching data';
          _latitude = '';
          _longitude = '';
          _feelsLike = '';
        });
      }
    } catch (error) {
      setState(() {
        _cityName = '';
        _temperature = '';
        _weatherDescription = 'Error fetching data';
        _latitude = '';
        _longitude = '';
        _feelsLike = '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _refreshWeatherData() {
    setState(() {
      _cityName = '';
      _temperature = '';
      _weatherDescription = '';
      _isLoading = true;
    });

    _fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DryBuddy App'),
        actions: [
          ElevatedButton(
            onPressed: _refreshWeatherData,
            child: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    Text('City: $_cityName'),
                    Text('Temperature: $_temperature °C'),
                    Text('Description: $_weatherDescription'),
                    Text('Latitude: $_latitude'),
                    Text('Longitude: $_longitude'),
                    Text('Feels Like: $_feelsLike °C'),
                  ],
                ),
        ],
      ),
    );
  }
}
