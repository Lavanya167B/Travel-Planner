import 'package:flutter/material.dart';
import 'package:flutter_temporary/services/weather_service.dart';
import 'weather_service.dart'; // Import the WeatherService class

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cityController = TextEditingController();
  String _weatherInfo = '';
  bool _loading = false;

  // Function to fetch and display weather info
  void _getWeather() async {
    setState(() {
      _loading = true;
    });

    try {
      WeatherService weatherService = WeatherService();
      var weatherData = await weatherService.getWeather(_cityController.text);

      setState(() {
        _loading = false;
        _weatherInfo =
            'Weather: ${weatherData['weather'][0]['description']}\n'
            'Temperature: ${weatherData['main']['temp']}°C\n'
            'Humidity: ${weatherData['main']['humidity']}%';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _weatherInfo = 'Failed to get weather data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Enter City'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _getWeather, child: Text('Get Weather')),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : Text(_weatherInfo, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
