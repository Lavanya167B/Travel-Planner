import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class CheckWeatherPage extends StatefulWidget {
  @override
  _CheckWeatherPageState createState() => _CheckWeatherPageState();
}

class _CheckWeatherPageState extends State<CheckWeatherPage> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;

  void _getWeather() async {
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final data = await WeatherService().getWeather(
        city,
      ); // Use getWeather here
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _weatherData = null;
        _isLoading = false;
      });
      // Optionally, display a message in case of error
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch weather data. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _getWeather, child: Text('Get Weather')),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : _weatherData == null
                ? Text('Enter a city to check the weather.')
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weather in ${_weatherData!['name']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Temperature: ${_weatherData!['main']['temp']} °C'),
                    Text(
                      'Condition: ${_weatherData!['weather'][0]['description']}',
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
