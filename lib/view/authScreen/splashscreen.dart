import 'package:event_pro/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:event_pro/utils/color.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: cyangreen,
      body: Center(
        child: Text(
          "Expo Geeks",
          style: TextStyle(
            color: white,
            fontSize: convertFigmaToUIWidth(24, w) ?? 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
