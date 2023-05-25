import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DryBuddyApp());
}

Future<String> loadApiKey() async {
  final secretFile = await rootBundle.loadString('assets/secrets.yaml');
  final secrets = loadYaml(secretFile);
  return secrets['OPENWEATHER_API_KEY'] as String;
}

class DryBuddyApp extends StatelessWidget {
  const DryBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DryBuddy App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

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
  List<dynamic> _minutelyData = [];
  String _weatherIconCode = '';
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
              title: const Text('Location Access Denied'),
              content: const Text(
                  'Please enable location access or try again later.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
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
                title: const Text('Location Access Denied'),
                content: const Text(
                    'Please enable location access or try again later.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
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
        'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&exclude=alerts&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

        setState(() {
          _cityName = '';
          _temperature = (data["current"]["temp"] - 273.15).toStringAsFixed(2);
          _weatherIconCode = data["current"]["weather"][0]["icon"];
          _weatherDescription = data["current"]["weather"][0]["description"];
          _latitude = data["lat"].toString();
          _longitude = data["lon"].toString();
          _feelsLike =
              (data["current"]['feels_like'] - 273.15).toStringAsFixed(2);
          _minutelyData = data["minutely"]; // New line to get minutely data
        });
      } else {
        setState(() {
          _cityName = '';
          _temperature = '';
          _weatherIconCode = '';
          _weatherDescription = 'Error fetching data';
          _latitude = '';
          _longitude = '';
          _feelsLike = '';
          _minutelyData = []; // New line to reset minutely data
        });
      }
    } catch (error) {
      print(error);
      setState(() {
        _cityName = '';
        _temperature = '';
        _weatherIconCode = '';
        _weatherDescription = 'Error fetching data';
        _latitude = '';
        _longitude = '';
        _feelsLike = '';
        _minutelyData = []; // New line to reset minutely data
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
      _weatherIconCode = '';
      _weatherDescription = '';
      _latitude = '';
      _longitude = '';
      _feelsLike = '';
      _isLoading = true;
      _minutelyData = []; // New line to reset minutely data
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
      backgroundColor: Color.fromARGB(
          255, 156, 236, 228), // Set the background color to teal
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(height: 20),
                      Text('City: $_cityName'),
                      Text('Temperature: $_temperature °C'),
                      Image.network(getWeatherIconUrl(_weatherIconCode)),
                      Text('Description: $_weatherDescription'),
                      Text('Latitude: $_latitude'),
                      Text('Longitude: $_longitude'),
                      Text('Feels Like: $_feelsLike °C'),
                      SizedBox(height: 20),
                      Text('Minutely Weather Data:'),
                      if (_minutelyData.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _minutelyData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = _minutelyData[index];
                            final dt = DateTime.fromMillisecondsSinceEpoch(
                                data['dt'] * 1000);
                            final precipitation = data['precipitation'];
                            return ListTile(
                              title: Text('Time: ${dt.toLocal()}'),
                              subtitle:
                                  Text('Precipitation: $precipitation mm/h'),
                            );
                          },
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}
