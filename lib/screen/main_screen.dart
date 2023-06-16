import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/weather_provider.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/mainscreen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currCelcius = 0;
  int _selectedDayIndex = 0;
  String _selectedDay = "";
  final DateTime _now = DateTime.now();
  List<Weather> _dailyWeather = [];

  @override
  void initState() {
    int month = _now.month;
    int day = _now.day;
    _selectedDay = "${month.toString().padLeft(2, '0')}-$day";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<WeatherProvider>(context, listen: false).getWeatherList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(26, 98, 153, 1),
              Color.fromARGB(255, 114, 188, 244),
            ],
          )),
          child: Consumer<WeatherProvider>(builder: (context, value, child) {
            if (value.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            _currCelcius = value.currentCelcius;
            _dailyWeather = value.weatherlist
                .where((element) => element.day == _selectedDay)
                .toList();
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Budapest",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$_currCelcius°",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 55),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return dayRow(index);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: dailyWeatherCol(),
                )
              ],
            );
          })),
    ));
  }

  Widget dayRow(int index) {
    DateTime dt = _now.add(Duration(days: index));
    int month = dt.month;
    int day = dt.day;
    String nameOfDay = DateFormat.EEEE().format(dt);
    return GestureDetector(
      onTap: () => setState(() {
        _selectedDayIndex = index;
        _selectedDay = "${month.toString().padLeft(2, '0')}-$day";
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: _selectedDayIndex == index
              ? const Color.fromARGB(255, 226, 221, 221)
              : const Color.fromARGB(77, 236, 234, 234),
        ),
        height: 30,
        alignment: Alignment.center,
        width: (MediaQuery.of(context).size.width * 0.9) / 3.1,
        child: Text(
          nameOfDay,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget dailyWeatherCol() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _dailyWeather.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 70,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dailyWeather[index].hour,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 95,
                      child: Text(
                        _dailyWeather[index].desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Icon(
                      Provider.of<WeatherProvider>(context, listen: false)
                          .weatherIcon(_dailyWeather[index].main),
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                Text(
                  "${_dailyWeather[index].mincelcius}° / ${_dailyWeather[index].maxCelcius}°",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
