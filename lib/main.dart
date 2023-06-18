import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screen/error_screen.dart';
import 'package:weather_app/service/weather_provider.dart';
import 'package:provider/provider.dart';
import 'screen/main_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext ctx) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return ChangeNotifierProvider(
        create: (context) => WeatherProvider(),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: MainScreen(),
          routes: {
            MainScreen.routeName: (context) => MainScreen(),
            ErrorScreen.routeName: (context) => ErrorScreen(),
          },
        ));
  }
}
