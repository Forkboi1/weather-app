import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'weather_response.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? latitude;
  double? longitude;
  String apiKey = '0b5fec1e91a5a7c5465562c94a896330';
  WeatherResponse? weatherResponse;
  TextEditingController _cityController = TextEditingController();
  bool textColor = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
      _fetchWeatherDataByLocation();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchWeatherDataByLocation() async {
    final url = 'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$latitude&lon=$longitude&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherResponse = WeatherResponse.fromJson(data);
          _cityController.clear();
          textColor = true;
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchWeatherDataByCity(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather'
        '?q=$city&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          textColor = true;
          weatherResponse = WeatherResponse.fromJson(data);
        });
      } else {
        setState(() {
          textColor = false;
          _cityController.text = "Wrong city";
        });
        print('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var searchBoxColor = textColor? null: Colors.red;
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              cursorColor: searchBoxColor,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                suffixIcon: IconButton(
                  color: searchBoxColor,
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _fetchWeatherDataByCity(_cityController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            weatherResponse == null
                ? const CircularProgressIndicator.adaptive()
                : Card(
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
                  ElevatedButton(
                    onPressed: (){
                      _fetchWeatherDataByLocation();
                    },
                     child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("My city"),
                        Icon(Icons.my_location)
                      ],
                     ),
                     )
          ],
        ),
      ),
    );
  }
}