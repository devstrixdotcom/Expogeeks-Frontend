import 'dart:io';

import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/data/local/shared_pref_helper.dart';
import 'package:event_pro/data/remote/get_user_data.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/authScreen/login_screen.dart';
import 'package:event_pro/view/authScreen/onboardingscreen.dart';
import 'package:event_pro/view/badges/exhibitorBadge.dart';
import 'package:event_pro/view/badges/scan_qr_screen.dart';
import 'package:event_pro/view/badges/visitor_badge_screen.dart';
import 'package:event_pro/view/home/home_screen.dart';
import 'package:event_pro/view/menuScreens/common/menu_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'view/authScreen/splashscreen.dart';
import 'view/menuScreens/exhibitor/scanned_visitors.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

bool isLoggedIn = false;
bool isFirstTime = true;
late Box hiveBox;

void main() async {
  try {
    await _initializePrefs();
  } catch (e) {
    debugPrint(e.toString());
  }
  runApp(MyApp());
}

Future<void> _initializePrefs() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SharedPreferencesHelper.init();

  // if (Platform.isAndroid) WebView.platform = AndroidWebView();
  final PlatformWebViewControllerCreationParams params = 
    PlatformWebViewControllerCreationParams();
  final WebViewController controller =
      WebViewController.fromPlatformCreationParams(params);

  if (controller.platform is AndroidWebViewController) {
    AndroidWebViewController.enableDebugging(true);
    (controller.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }

  isLoggedIn = SharedPreferencesHelper.getIsLoggedIn();
  isFirstTime = SharedPreferencesHelper.getIsFirstTime();
  constant.userType = SharedPreferencesHelper.getUserType();
  constant.countryCodeValue = SharedPreferencesHelper.getUserCountryCode();
  constant.phoneValue = SharedPreferencesHelper.getUserPhone();
  constant.userId = SharedPreferencesHelper.getUserId();
  constant.userToken = SharedPreferencesHelper.getUserToken();
  constant.nameValue =
      await capitalizeWords(SharedPreferencesHelper.getUserName());
  constant.emailValue = SharedPreferencesHelper.getUserEmail();
  constant.weddingRoleValue = SharedPreferencesHelper.getUserWeddingRole();
  constant.addressValue = SharedPreferencesHelper.getUserAddress();
  constant.budgetValue = SharedPreferencesHelper.getUserBudget();
  // Destination and venue are cached like every other profile field; without
  // these two lines they stay empty on a cold start until getUserDetails()
  // returns, so their profile rows and edit boxes come up blank.
  constant.destinationValue = SharedPreferencesHelper.getDestination();
  constant.venueValue = SharedPreferencesHelper.getVenue();
  constant.expectedDateValue = SharedPreferencesHelper.getExpectedDate();
  constant.qrCodeValue = SharedPreferencesHelper.getQrCode();
  constant.imageLinkValue = SharedPreferencesHelper.getImageLink();
  constant.circularImageLinkValue =
      SharedPreferencesHelper.getCircularImageLink();
  if (isLoggedIn) {
    await GetUserData().getUserDetails();
  }

  await Hive.initFlutter().then((value) async {
    await Hive.openBox('myBox').then((value) => hiveBox = Hive.box('myBox'));
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Pro App',
      theme: ThemeData(
          fontFamily: "Roboto",
          scaffoldBackgroundColor: Colors.white,
          // scaffoldBackgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
          primaryColor: cyangreen,
          useMaterial3: false),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/myBadge': (context) => VisitorBadgeScreen(),
        '/exhibitorBadge': (context) => ExhibitorBadgeScreen(),
        '/scanQR': (context) => ScanQRScreen(),
        '/menu': (context) => MenuScreen(),
        '/scannedVisitors': (context) => ScaneedVistors(isAfterScan: true),
      },
      home: SplashScreenWrapper(),
      
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Simulate splash screen duration (e.g., 3 seconds)
    await Future.delayed(Duration(seconds: 3));

    // Redirect to the appropriate screen based on isFirstTime and isLoggedIn
    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } else if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Show the splash screen
  }
}
