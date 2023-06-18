import 'package:flutter/material.dart';
import 'package:weather_app/config.dart';
import 'package:weather_app/screen/main_screen.dart';
import 'package:weather_app/widgets/background.dart';
import '../service/weather_provider.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatefulWidget {
  static const routeName = '/errorScreen';
  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        Background(),
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //TODO: a hiba alapján más hibaüzenet (city not found, no internet connection..)
            const Text(
              "Something went wrong..",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(MainScreen.routeName);
                Provider.of<WeatherProvider>(context, listen: false)
                    .getWeatherList(AppConfig
                        .defaultCity); //frissítsük az alkalmazást a default várossal
              },
              child: const SizedBox(
                height: 100,
                width: 100,
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ),
          ],
        )),
      ]),
    ));
  }
}
