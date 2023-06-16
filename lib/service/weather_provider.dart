// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import 'package:weather_app/model/weather_model.dart';
import 'dio_client.dart';

class WeatherProvider with ChangeNotifier {
  WeatherProvider();

  final DioClient _dioClient = DioClient();
  String country = "Budapest,hu";

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _currentCelcius = 0;
  int get currentCelcius => _currentCelcius;
  List<Weather> _weatherlist = [];
  List<Weather> get weatherlist => _weatherlist;

  //TODO az összeset felsorolni, de ez is elég
  Map<String, IconData> _iconSet = {
    "Thunderstorm": Icons.thunderstorm,
    "Drizzle": Rain.drizzle_inv,
    "Rain": Rain.rain_inv,
    "Snow": Icons.cloudy_snowing,
    "Clear": Icons.sunny,
    "Clouds": Icons.cloud_sharp
  };

  IconData? weatherIcon(String main) {
    return _iconSet[main];
  }

  Future<void> getWeatherList() async {
    _isLoading = true;
    notifyListeners();
    final resp = await _dioClient.getForecastWeather(country) as List<Weather>;
    _weatherlist = resp;
    getCurrentCelcius();
  }

  Future<void> getCurrentCelcius() async {
    final resp = await _dioClient.getCurrentWeather(country);
    _currentCelcius = resp;
    _isLoading = false;
    notifyListeners();
  }
}

class Rain {
  Rain._();

  static const _kFontFam = 'Rain';
  static const String? _kFontPkg = null;

  static const IconData rain_inv =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData drizzle_inv =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
