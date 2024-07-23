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
