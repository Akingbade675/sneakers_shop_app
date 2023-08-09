import "dart:convert";
import "dart:ui";

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:weather_app/additional_forecast_item.dart";
import "package:weather_app/constants.dart";
import "package:weather_app/hourly_forecast_card.dart";

import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weatherData;

  Future<Map<String, dynamic>> getWeatherData() async {
    //const currentUrl = '$openWeatherMapBaseUrl/weather?q=Ikorodu&appid=$openWeatherMapAppId';
    try {
      const forecastUrl =
          '${openWeatherMapBaseUrl}forecast?q=Ikorodu&appid=$openWeatherMapAppId';
      //final response = jsonDecode((await http.get(Uri.parse(currentUrl))).body) as Map<String, dynamic>;

      final response =
          jsonDecode((await http.get(Uri.parse(forecastUrl))).body);

      if (response['cod'] != '200') {
        throw 'An error occurred';
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    weatherData = getWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weatherData = getWeatherData();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!['list'][0];
          final currentWeather = data['weather'][0]['main'];
          final currentTemperature = data['main']['temp'];
          final currentHumidity = data['main']['humidity'];
          final currentWindSpeed = data['wind']['speed'];
          final currentPressure = data['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${currentTemperature.toStringAsFixed(2)} K',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                  currentWeather == 'Rain'
                                      ? Icons.cloudy_snowing
                                      : Icons.cloud,
                                  size: 64),
                              const SizedBox(height: 16),
                              Text(
                                currentWeather,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hourly Weather Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 113,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!['list'][index + 1];
                      final weather = data['weather'][0]['main'];
                      final date = DateTime.parse(data['dt_txt']);
                      final formattedTime = DateFormat.j().format(date);

                      var icon = Icons.sunny;
                      if (weather == 'Rain') {
                        icon = Icons.cloudy_snowing;
                      } else if (weather == 'Clouds') {
                        icon = Icons.cloud;
                      }

                      return HourlyForecastCard(
                        icon: icon,
                        time: formattedTime,
                        humidity: data['main']['temp'].toString(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalForecastItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalForecastItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalForecastItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
