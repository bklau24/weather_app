import 'package:dio/dio.dart';
import 'package:weather_app/model/weather_model.dart';
import '../config.dart';

class DioClient {
  final Dio _dio = Dio();

  DioClient();

  Future<List<Weather>?> getForecastWeather(String country) async {
    List<Weather> weatherlist = [];
    await _dio.get("${AppConfig.apiUrl}forecast", queryParameters: {
      'q': country,
      'APPID': AppConfig.apiKey
    }).then(((Response response) {
      if (response.data != null) {
        List<dynamic> list = response.data["list"];
        for (var element in list) {
          String dttxt = element["dt_txt"];
          double kelvinMin =
              double.parse(element["main"]["temp_min"].toString());
          int celciusMin = (kelvinMin - 273.15).round();
          double kelvinMax =
              double.parse(element["main"]["temp_max"].toString());
          int celciusMax = (kelvinMax - 273.15).round();
          weatherlist.add(Weather(
              dttxt.substring(5, 10),
              dttxt.substring(11, 16),
              celciusMin,
              celciusMax,
              element["weather"][0]["main"].toString(),
              element["weather"][0]["description"].toString()));
        }
      }
    })).catchError((e) {
      throw (e);
    });
    return weatherlist;
  }

  Future<int> getCurrentWeather(String country) async {
    int currentCelcius = 0;
    await _dio.get("${AppConfig.apiUrl}weather", queryParameters: {
      'q': country,
      'APPID': AppConfig.apiKey
    }).then(((Response response) {
      if (response.data != null) {
        if (response.data != null) {
          double kelvin =
              double.parse(response.data["main"]["temp"].toString());
          currentCelcius = (kelvin - 273.15).round();
        }
      }
    })).catchError((e) {
      throw (e);
    });
    return currentCelcius;
  }
}
