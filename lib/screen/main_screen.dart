import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/config.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/weather_provider.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/service/weather_service.dart';
import 'package:weather_app/widgets/background.dart';
import '../service/string_extension.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/mainScreen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currCelcius = 0;
  int _selectedDayIndex = 0;
  String _selectedDay = "";
  List<Weather> _dailyWeather = [];
  bool _changeCity = false;
  String _selectedCity = AppConfig.defaultCity;
  String _errorMsg = "";
  final FocusNode _fnode = FocusNode();
  final DateTime _now = DateTime.now();
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    int month = _now.month;
    int day = _now.day;
    _selectedDay = "${month.toString().padLeft(2, '0')}-$day"; //init mai nap
    _fnode.addListener(noCityFocus);
    //adatok lekérése
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<WeatherProvider>(context, listen: false)
          .getWeatherList(_selectedCity);
    });
    super.initState();
  }

  void noCityFocus() {
    if (!_fnode.hasFocus) {
      setState(() {
        _changeCity = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            //textinput elrejtése, ha nincs megnyitva a keyboard, de az input igen
            if (MediaQuery.of(context).viewInsets.bottom == 0 && _changeCity) {
              setState(() {
                _changeCity = false;
              });
            }
          },
          child: SafeArea(
            child: Stack(children: [
              Background(),
              Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Consumer<WeatherProvider>(
                      builder: (context, value, child) {
                    if (value.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }
                    _currCelcius = value.currentCelcius;
                    _dailyWeather = value.weatherlist
                        .where((element) => element.day == _selectedDay)
                        .toList();
                    return Column(
                      children: [
                        Padding(
                          padding: _changeCity
                              ? const EdgeInsets.only(top: 30)
                              : const EdgeInsets.fromLTRB(15, 30, 0, 0),
                          child: SizedBox(
                            height: 110,
                            child: _changeCity
                                ? userInput() //user adatok bekérése (város)
                                : editButton(), //lehetőség másik város kiválasztására
                          ),
                        ),
                        actualData(), //adott város és hőmérséklet
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return dayRow(index); //napok kiírása
                            },
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: dailyWeatherCol(), //adott napi előrejelzés
                          ),
                        )
                      ],
                    );
                  })),
            ]),
          ),
        ));
  }

  Widget userInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(right: 8),
                height: 55,
                width: MediaQuery.of(context).size.width - 100,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromARGB(77, 236, 234, 234),
                ),
                child: Center(
                  child: TextFormField(
                    onFieldSubmitted: (value) {
                      searchCity();
                    },
                    controller: _cityController,
                    cursorColor: Colors.black,
                    autofocus: true,
                    focusNode: _fnode,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          left: 15,
                        ),
                        hintText: "Type a city name..",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 89, 87, 87),
                            fontSize: 14)),
                  ),
                )),
            SizedBox(
              width: 60,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 197, 195, 195),
                  shadowColor: Colors.transparent,
                ),
                onPressed: searchCity,
                child: const Text(
                  "Go!",
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 45,
          child: Center(
            child: _errorMsg == ""
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.error,
                          color: Color.fromARGB(255, 98, 12, 6), size: 22),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        _errorMsg,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 98, 12, 6),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        )
      ],
    );
  }

  void searchCity() {
    if (_cityController.text != "" &&
        _weatherService.validCityName(_cityController.text)) {
      setState(() {
        _changeCity = false;
        _selectedCity = _cityController.text;
      });
      Provider.of<WeatherProvider>(context, listen: false)
          .getWeatherList(_cityController.text);
    } else {
      setState(() {
        _errorMsg = "Invalid city name!";
      });
    }
  }

  Widget editButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(77, 236, 234, 234),
          shadowColor: Colors.transparent,
          fixedSize: const Size(55, 55),
          shape: const CircleBorder(),
        ),
        onPressed: () {
          setState(() {
            _changeCity = true;
            _cityController.text = "";
            _errorMsg = "";
          });
        },
        child: const Icon(
          Icons.add,
          size: 35,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget actualData() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_pin,
                  size: 28,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 8,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width * 0.9) - 130,
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _selectedCity.capitalize(),
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "$_currCelcius°",
              style: const TextStyle(color: Colors.white, fontSize: 55),
            ),
          ],
        ),
      ),
    );
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
                      _weatherService.weatherIcon(_dailyWeather[index].main),
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                Text(
                  "${_dailyWeather[index].minCelcius}° / ${_dailyWeather[index].maxCelcius}°",
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
