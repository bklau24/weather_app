import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromRGBO(26, 98, 153, 1).withOpacity(0.9),
          const Color.fromARGB(255, 114, 188, 244).withOpacity(0.8),
        ],
      )),
    );
  }
}
