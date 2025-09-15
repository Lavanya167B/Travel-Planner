import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey =
      '0fdb1682cfe08a85e0df29f5e7f83425'; // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Function to fetch weather data
  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
