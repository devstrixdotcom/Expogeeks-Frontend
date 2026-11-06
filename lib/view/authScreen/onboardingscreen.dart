import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/data/local/shared_pref_helper.dart';
import 'package:event_pro/sharedwidget/elevated_button.dart';
import 'package:event_pro/view/authScreen/login_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // var sizeboxHeight = MediaQuery.of(context).size.height;

    var sizeboxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(splashScreenImg),
            // SizedBox(height: sizeboxHeight * 0.04),
            SizedBox(height: convertFigmaToUIWidth(40, MediaQuery.of(context).size.width) ?? 40,),
            Text(
              "Welcome",
              style: TextStyle(height: 1.5, fontSize: sizeboxWidth * 0.08, color: textColor),
            ),
            // SizedBox(height: sizeboxHeight * 0.02),
            SizedBox(height: convertFigmaToUIWidth(20, MediaQuery.of(context).size.width) ?? 20,),
            Text(
              "Book VIP tickets and receive exclusive benefits to make your day at the show even more special",
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, fontSize: sizeboxWidth * 0.04, color: textColor),
            ),
            // SizedBox(height: sizeboxHeight * 0.06),
            SizedBox(height: convertFigmaToUIWidth(60, MediaQuery.of(context).size.width) ?? 60,),
            Container(
              width: double.infinity,
              child: filledButtonWidgt(
                context,
                'Get Started',
                () {
                  SharedPreferencesHelper.setIsFirstTime(firstTime: false);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
