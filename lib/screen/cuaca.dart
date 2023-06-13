import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  static String routeName = "/weather";

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _city = '';
  String _temperature = '';
  String _description = '';
  bool _isLoading = false;

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = 'YOUR_API_KEY'; // Replace with your API key
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final weatherData = json.decode(response.body);
        final main = weatherData['main'];
        final weather = weatherData['weather'][0];

        setState(() {
          _temperature = (main['temp'] - 273.15).toStringAsFixed(1);
          _description = weather['description'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _temperature = '';
          _description = 'Error fetching weather data';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _temperature = '';
        _description = 'Error fetching weather data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'City',
              ),
              onChanged: (value) {
                setState(() {
                  _city = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchWeatherData,
              child: Text('Get Weather'),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Temperature: $_temperature °C',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: $_description',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
