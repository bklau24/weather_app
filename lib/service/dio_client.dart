import 'package:dio/dio.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/screen/error_screen.dart';
import '../config.dart';

class DioClient {
  final Dio _dio = Dio();
  Dio get dio => _dio;

  DioClient() {
    setDioClient();
  }

  setDioClient() {
    _dio.options.baseUrl = AppConfig.apiUrl;
    _dio.options.connectTimeout = const Duration(seconds: 3);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      handleAPIKey(options);
      return handler.next(options);
    }, onError: (DioException dioError, ErrorInterceptorHandler handler) {
      handleError();
    }));
  }

  handleAPIKey(RequestOptions options) {
    options.queryParameters.putIfAbsent('APPID', () => AppConfig.apiKey);
  }

  handleError() {
    navigatorKey.currentState?.pushReplacementNamed(ErrorScreen.routeName);
  }
}
