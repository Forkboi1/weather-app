import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? latitude = 26.406957;
  double? longitude = 43.925240;
  String apiKey = '0b5fec1e91a5a7c5465562c94a896330';
  WeatherResponse? weatherResponse;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchWeatherData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchWeatherData() async {
    final url = 'https://api.openweathermap.org/data/2.5/weather'
        '?id=52490&appid=$apiKey&lat=$latitude&lon=$longitude';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherResponse = WeatherResponse.fromJson(data);
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: weatherResponse == null
          ? const CircularProgressIndicator.adaptive()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weatherResponse!.cityName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Temperature: ${weatherResponse!.temp.round()} °C',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Latitude: ${weatherResponse!.cityLat.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Longitude: ${weatherResponse!.cityLon.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class WeatherResponse {
  final String cityName;
  final double cityLat;
  final double cityLon;
  final double temp;

  WeatherResponse({
    required this.cityName,
    required this.cityLat,
    required this.cityLon,
    required this.temp,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {

    return WeatherResponse(
      cityName: json['name'],
      cityLat: json['coord']['lat'].toDouble(),
      cityLon: json['coord']['lon'].toDouble(),
      temp: kelvinToCelsius(json['main']['temp'].toDouble()),
    );
  }

  static double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
}

}
