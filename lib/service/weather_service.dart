import 'package:flutter/material.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/dio_client.dart';

class WeatherService {
  WeatherService();

  final DioClient _dioClient = DioClient();
  final double _kelvinConvertConstant = 273.15;
  List<Weather> _weatherList = [];
  int _currentCelcius = 0;

  Future<List<Weather>?> getForecastWeather(String country) async {
    var response =
        await _dioClient.dio.get("/forecast", queryParameters: {'q': country});
    if (response.data != null) {
      List<dynamic> list = response.data["list"];
      populateWeatherList(list);
    }
    return _weatherList;
  }

  void populateWeatherList(List<dynamic> weatherElements) {
    _weatherList = [];
    for (var element in weatherElements) {
      Weather weather = createWeatherFromElement(element);
      _weatherList.add(weather);
    }
  }

  Weather createWeatherFromElement(dynamic element) {
    String dttxt = element["dt_txt"];
    String day = dttxt.substring(5, 10);
    String hour = dttxt.substring(11, 16);
    int minCelcius = calculateCelsiusFromKelvinString(
        element["main"]["temp_min"].toString());
    int maxCelcius = calculateCelsiusFromKelvinString(
        element["main"]["temp_max"].toString());
    String main = element["weather"][0]["main"].toString();
    String desc = element["weather"][0]["description"].toString();
    return Weather(day, hour, minCelcius, maxCelcius, main, desc);
  }

  Future<int> getCurrentWeatherByCity(String city) async {
    _currentCelcius = 0;
    var response =
        await _dioClient.dio.get("/weather", queryParameters: {'q': city});
    if (response.data != null) {
      setCurrentCelcius(response.data["main"]["temp"].toString());
    }
    return _currentCelcius;
  }

  setCurrentCelcius(String temperatureInKelvinString) {
    _currentCelcius =
        calculateCelsiusFromKelvinString(temperatureInKelvinString);
  }

  int calculateCelsiusFromKelvinString(String temperatureInKelvin) {
    double kelvin = double.parse(temperatureInKelvin);
    return calculateCelsiusFromKelvinDouble(kelvin);
  }

  int calculateCelsiusFromKelvinDouble(double temperatureInKelvin) {
    return (temperatureInKelvin - _kelvinConvertConstant).round();
  }

  //TODO az összeset felsorolni, de ez is elég
  final Map<String, IconData> _iconSet = {
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

  //elfogadott karakterek: angol abc betűi, plusz .-' és whitespace
  bool validCityName(String city) {
    RegExp reg = RegExp(r"^[A-Za-z\s\(').-]+$");
    return reg.hasMatch(city);
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
