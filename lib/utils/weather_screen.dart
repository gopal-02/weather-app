import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/utils/hourly_forecast_cards.dart';
import 'package:weather_app/utils/additional_info.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool isLoading = true;
  double currentTemperature = 0;
  String currentWeatherCondition = '';
  String cityName = 'Delhi';
  double currentWindCondition = 0.0;
  double currentHumidity = 0.0;
  double currentPressure = 0.0;
  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<void> getCurrentWeather() async {
    try {
      String apiKey = '65a87dd847f3ed49751ba368eff312a8';
      final response = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentTemperature = (data['main']['temp']);
          isLoading = false;
          currentWeatherCondition = data['weather'][0]['main'];
          currentPressure = (data['main']['pressure'] / 100);
          currentWindCondition = (data['wind']['speed']);
          currentHumidity = (data['main']['humidity'].toDouble());
        });
      } else {
        print('Error: $response.statusCode');
      }
      // final hourResponse = await http.get(Uri.parse(
      //     'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey'));
      // if (response.statusCode == 200) {
      //   final hourlyData = jsonDecode(hourResponse.body);
      //   print(hourResponse.body);
      // } else {
      //   print('Error: $response.statusCode');
      // }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cityName[0].toUpperCase() + cityName.substring(1),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                getCurrentWeather();
              });
              print("Refresh");
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            Text(
                              '${currentTemperature.toStringAsFixed(2)} °C',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              currentWeatherCondition == 'Clouds' ||
                                      currentWeatherCondition == 'Mist' ||
                                      currentWeatherCondition == 'Rain' ||
                                      currentWeatherCondition == 'Haze'
                                  ? Icons.wb_cloudy
                                  : Icons.wb_sunny,
                              size: 64,
                              color: currentWeatherCondition == 'Clouds' ||
                                      currentWeatherCondition == 'Mist' ||
                                      currentWeatherCondition == 'Rain' ||
                                      currentWeatherCondition == 'Haze'
                                  ? Colors.blueGrey
                                  : Colors.yellow,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              currentWeatherCondition,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Hourly Forecast',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          HourlyForecastCard(),
                          HourlyForecastCard(),
                          HourlyForecastCard(),
                          HourlyForecastCard(),
                          HourlyForecastCard(),
                          HourlyForecastCard()
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Additional Info',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AdditionalInfo(
                          title: 'Wind',
                          value: '$currentWindCondition km/h',
                          icon: Icons.air,
                        ),
                        AdditionalInfo(
                          title: 'Humidity',
                          value: '${currentHumidity.round()}%',
                          icon: Icons.water,
                        ),
                        AdditionalInfo(
                          title: 'Pressure',
                          value: '$currentPressure hPa',
                          icon: Icons.arrow_downward,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Change Location'),
                                  content: TextField(
                                    controller: cityController,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter City Name'),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[a-zA-Z]'))
                                    ],
                                    autofocus: true,
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          cityName = cityController.text;
                                          isLoading = true;
                                        });
                                        cityController.clear();
                                        getCurrentWeather();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: const Text(
                          'Change Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
