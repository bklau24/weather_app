// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherProvider();

  final WeatherService _ws = WeatherService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _currentCelcius = 0;
  int get currentCelcius => _currentCelcius;
  List<Weather> _weatherlist = [];
  List<Weather> get weatherlist => _weatherlist;

  Future<void> getWeatherList(String city) async {
    _isLoading = true;
    notifyListeners();
    final resp = await _ws.getForecastWeather(city) as List<Weather>;
    _weatherlist = resp;
    getCurrentCelcius(city);
  }

  Future<void> getCurrentCelcius(String city) async {
    final resp = await _ws.getCurrentWeatherByCity(city);
    _currentCelcius = resp;
    _isLoading = false;
    notifyListeners();
  }
}
