// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/data/local/shared_pref_helper.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/view/authScreen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

showInvalidTokenDialog(BuildContext context) {
  // set up the button
  // Widget okButton = TextButton(
  //   child: Text("OK", style: TextStyle(height: 1.5, fontSize: 14)),
  Widget okButton = Padding(
    padding: const EdgeInsets.only(right: 10),
    child: ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(cyangreen)),
      child: Text("OK"),
      onPressed: () {
        constant.userType = "";
        constant.userId = "";
        constant.userToken = "";
        constant.nameValue = "";
        constant.emailValue = "";
        constant.phoneValue = "";
        constant.weddingRoleValue = "";
        constant.addressValue = "";
        constant.budgetValue = "";
        constant.expectedDateValue = "";
        constant.qrCodeValue = "";
        constant.imageLinkValue = "";
        constant.circularImageLinkValue = "";
        constant.destinationValue = "";
        constant.venueValue = "";
        SharedPreferencesHelper.clearShareCache();
        SharedPreferencesHelper.setIsFirstTime(firstTime: false);
        Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => LoginPage()),
            (route) => false);
      },
    ),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Session Expired", style: TextStyle(height: 1.5, fontSize: 16)),
    content:
        Text("Please Login Again", style: TextStyle(height: 1.5, fontSize: 14)),
    actions: [okButton],
    elevation: 5,
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showStatusFalse(context) {
  Widget ok = TextButton(
    child: Text("Okay"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Server Issue"),
        content:
            Text("We are facing Server Issue Please try again after sometime."),
        actions: [
          ok,
        ],
        elevation: 5,
      );
    },
  );
}

showToast(message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      fontSize: 14.0,
      backgroundColor: boldpink,
      textColor: cyangreen);
}

void showCustomToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 180.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the custom toast into the overlay
  overlay.insert(overlayEntry);

  // Remove the custom toast after a delay
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

sharingOnTap(String link) async {
  String url = link.trim();
  // Guard against null/empty links coming through as the literal "null".
  if (url.isEmpty || url == 'null') {
    debugPrint('sharingOnTap: empty or null link');
    return;
  }
  // Ensure the link has a scheme, otherwise launchUrl can't resolve it.
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }
  final encodedUrl = Uri.encodeFull(url);
  Uri uri = Uri.parse(encodedUrl);

  try {
    // externalApplication opens the WhatsApp / Instagram app instead of an
    // in-app webview on both platforms.
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint(e.toString());
  } finally {
    await Future.delayed(const Duration(seconds: 3));
  }
}

sendingMails(String mail) async {
  final address = mail.trim();
  if (address.isEmpty || address == 'null') {
    debugPrint('sendingMails: empty or null email');
    return;
  }
  // Build the mailto: URI directly instead of via the mailto package +
  // deprecated launch() string API (that path threw RangeError on empty
  // subject/body).
  final uri = Uri(scheme: 'mailto', path: address);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint(e.toString());
  }
}

// Opens WhatsApp chat for the given number. Strips spaces, +, dashes and
// parentheses so the phone= param is digits only (WhatsApp requires this).
openWhatsApp(String? number) async {
  final digits = (number ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) {
    Fluttertoast.showToast(msg: 'No WhatsApp number available');
    return;
  }
  final uri = Uri.parse('https://wa.me/$digits');
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint(e.toString());
  }
}

// Opens an Instagram profile. Accepts a full URL or a bare handle (with or
// without a leading @).
openInstagram(String? linkOrHandle) async {
  var value = (linkOrHandle ?? '').trim();
  if (value.isEmpty || value == 'null') {
    Fluttertoast.showToast(msg: 'No Instagram link available');
    return;
  }
  String url;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    url = value;
  } else {
    final handle = value.replaceFirst('@', '');
    url = 'https://instagram.com/$handle';
  }
  final uri = Uri.parse(Uri.encodeFull(url));
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint(e.toString());
  }
}

makingPhoneCall(tel) async {
  var url = Uri.parse("tel:$tel");
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {}
  } on PlatformException catch (e) {
    debugPrint(e.toString());
  }
}

const AndroidNotificationDetails androidChannel = AndroidNotificationDetails(
  '1',
  'Events',
  importance: Importance.high,
  icon: '@mipmap/ic_launcher',
  color: cyangreen,
  styleInformation: BigTextStyleInformation(''),
  timeoutAfter: 10000,
);

const NotificationDetails platformChannel =
    NotificationDetails(android: androidChannel);

Future<void> showLocalNotification(int id, String title, String body) async {
  if (await Permission.notification.isDenied) {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      showToast("Notification permission denied. Cannot show notification.");
      return;
    }
  }

  await FlutterLocalNotificationsPlugin()
      .show(id, title, body, platformChannel);
}

class WaveVisualizerPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isPlaying;

  WaveVisualizerPainter({required this.animation, required this.isPlaying})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(0, height / 2);

    for (double i = 0; i < width; i++) {
      final y = isPlaying
          ? height / 2 +
              sin((i / width * 2 * pi) + (animation.value * 2 * pi)) *
                  (height / 4) *
                  animation.value
          : height / 2;
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveVisualizerPainter oldDelegate) => isPlaying;
}

String getNameInitials(String name) {
  String tempFirstName = name.split(' ').first;
  String tempLastName = name.contains(' ') ? name.split(' ')[1] : '';
  String tempFirstNameFirstAlphabet = '';
  String tempLastNameLastAlphabet = '';
  String nameInatials = '';

  if (tempFirstName != '') {
    tempFirstNameFirstAlphabet = tempFirstName.split('').first;
  }
  if (tempLastName != '' && tempLastName != ' ') {
    tempLastNameLastAlphabet = tempLastName.split('').first;
  }
  nameInatials = tempFirstNameFirstAlphabet + tempLastNameLastAlphabet;
  return nameInatials.toUpperCase();
}

String capitalizeWords(String name) {
  if (name.isEmpty) return name;
  name = name.trim().replaceAll(RegExp(r'\s+'), ' ');
  List<String> words = name.split(' ');

  List<String> capitalizedWords = words.map((word) {
    if (word.isEmpty) return word;
    if (word.length == 1) return word.toUpperCase();
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();

  return capitalizedWords.join(' ');
}

// class DateFormatter {
//   /// Formats a date string by removing leading zeros and adding the correct suffix (st, nd, rd, th).
//   static String formatDayWithSuffix(String date) {
//     DateTime? parsedDate;

//     // Try parsing standard date-time format (e.g., 2025-02-24 00:00:00.000)
//     try {
//       parsedDate = DateTime.parse(date);
//     } catch (e) {
//       // If parsing fails, assume it's in natural language format (e.g., "01 January 2025")
//       List<String> parts = date.split(' ');

//       if (parts.isNotEmpty) {
//         int startIndex = parts.length == 4 ? 1 : 0; // Skip weekday if present
//         String dayPart =
//             parts[startIndex].replaceAll(RegExp(r'[^0-9]'), ''); // Extract day
//         int day = int.tryParse(dayPart) ?? 0;

//         if (day > 0) {
//           String suffix = _getDaySuffix(day);
//           parts[startIndex] = '$day$suffix'; // Update the day part
//           return parts.join(' '); // Return the formatted string
//         }
//       }
//       return date; // Return original if parsing fails
//     }

//     // If parsing was successful, format it properly
//     int day = parsedDate.day;
//     String suffix = _getDaySuffix(day);
//     String month = DateFormat('MMM')
//         .format(parsedDate); // Abbreviated month name (e.g., Feb)
//     String year = parsedDate.year.toString();

//     return '$day$suffix $month $year'; // Return formatted date
//   }

//   /// Determines the correct suffix for a given day.
//   static String _getDaySuffix(int day) {
//     if (day >= 11 && day <= 13) return 'th'; // Special case for 11-13
//     switch (day % 10) {
//       case 1:
//         return 'st';
//       case 2:
//         return 'nd';
//       case 3:
//         return 'rd';
//       default:
//         return 'th';
//     }
//   }

//   // Used in reminder alert screen(reminder_alert_box.dart)
//   static String formatForDisplay(DateTime date) {
//     return formatDayWithSuffix(DateFormat('EEE dd MMM yyyy').format(date));
//   }

//   // Used in request meeting screen (request_meeting.dart)
//   static String formatForDropdown(String date) {
//     DateTime? parsedDate;
//     try {
//       parsedDate = DateTime.parse(date);
//       return DateFormat('dd MMM yyyy').format(parsedDate);
//     } catch (e) {
//       return date;
//     }
//   }
// }

class DateFormatter {
  /// Formats a date string by removing leading zeros and adding the correct suffix (st, nd, rd, th).
  static String formatDayWithSuffix(String date) {
    DateTime? parsedDate;

    // Try parsing standard date-time format (e.g., 2025-02-24 00:00:00.000)
    try {
      parsedDate = DateTime.parse(date);
    } catch (e) {
      // If parsing fails, assume it's in natural language format (e.g., "01 January 2025")
      List<String> parts = date.split(' ');

      if (parts.isNotEmpty) {
        int startIndex = parts.length == 4 ? 1 : 0; // Skip weekday if present
        String dayPart =
            parts[startIndex].replaceAll(RegExp(r'[^0-9]'), ''); // Extract day
        int day = int.tryParse(dayPart) ?? 0;

        if (day > 0) {
          String suffix = _getDaySuffix(day);
          parts[startIndex] = '$day$suffix'; // Update the day part
          return parts.join(' '); // Return the formatted string
        }
      }
      return date; // Return original if parsing fails
    }

    // If parsing was successful, format it properly
    int day = parsedDate.day;
    String suffix = _getDaySuffix(day);
    String month = DateFormat('MMM')
        .format(parsedDate); // Abbreviated month name (e.g., Feb)
    String year = parsedDate.year.toString();

    return '$day$suffix $month $year'; // Return formatted date
  }

  /// Determines the correct suffix for a given day.
  static String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th'; // Special case for 11-13
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Formats a date string like "3rd Mar 2025" to "2025-03-03".
  static String formatToDatabaseDate(String date) {
    if (date.isEmpty) {
      return ''; // Handle empty date
    }

    // Split the date into parts (e.g., ["3rd", "Mar", "2025"])
    List<String> dateParts = date.split(' ');

    if (dateParts.length < 3) {
      return ''; // Invalid format
    }

    // Extract day, month, and year
    String day =
        dateParts[0].replaceAll(RegExp(r'[^0-9]'), ''); // Remove suffix
    String month = dateParts[1];
    String year = dateParts[2];

    // Convert month name to month number
    String monthNumber = _getMonthNumber(month);

    // Format as "YYYY-MM-DD"
    return '$year-$monthNumber-${day.padLeft(2, '0')}';
  }

  /// Converts month name to month number.
  static String _getMonthNumber(String month) {
    switch (month) {
      case 'Jan':
        return '01';
      case 'Feb':
        return '02';
      case 'Mar':
        return '03';
      case 'Apr':
        return '04';
      case 'May':
        return '05';
      case 'Jun':
        return '06';
      case 'Jul':
        return '07';
      case 'Aug':
        return '08';
      case 'Sep':
        return '09';
      case 'Oct':
        return '10';
      case 'Nov':
        return '11';
      case 'Dec':
        return '12';
      default:
        return '01';
    }
  }

  // Used in reminder alert screen(reminder_alert_box.dart)
  static String formatForDisplay(DateTime date) {
    return formatDayWithSuffix(DateFormat('EEE dd MMM yyyy').format(date));
  }

  // Used in request meeting screen (request_meeting.dart)
  static String formatForDropdown(String date) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}

// Country ISO
String getCountryISOCode(String countryCode) {
  Map<String, String> countryMap = {
    "+1": "US",
    "+7": "RU",
    "+20": "EG",
    "+27": "ZA",
    "+30": "GR",
    "+31": "NL",
    "+32": "BE",
    "+33": "FR",
    "+34": "ES",
    "+36": "HU",
    "+39": "IT",
    "+40": "RO",
    "+41": "CH",
    "+43": "AT",
    "+44": "GB",
    "+45": "DK",
    "+46": "SE",
    "+47": "NO",
    "+48": "PL",
    "+49": "DE",
    "+51": "PE",
    "+52": "MX",
    "+53": "CU",
    "+54": "AR",
    "+55": "BR",
    "+56": "CL",
    "+57": "CO",
    "+58": "VE",
    "+60": "MY",
    "+61": "AU",
    "+62": "ID",
    "+63": "PH",
    "+64": "NZ",
    "+65": "SG",
    "+66": "TH",
    "+81": "JP",
    "+82": "KR",
    "+84": "VN",
    "+86": "CN",
    "+90": "TR",
    "+91": "IN",
    "+92": "PK",
    "+93": "AF",
    "+94": "LK",
    "+95": "MM",
    "+98": "IR",
    "+212": "MA",
    "+213": "DZ",
    "+216": "TN",
    "+218": "LY",
    "+220": "GM",
    "+221": "SN",
    "+222": "MR",
    "+223": "ML",
    "+224": "GN",
    "+225": "CI",
    "+226": "BF",
    "+227": "NE",
    "+228": "TG",
    "+229": "BJ",
    "+230": "MU",
    "+231": "LR",
    "+232": "SL",
    "+233": "GH",
    "+234": "NG",
    "+235": "TD",
    "+236": "CF",
    "+237": "CM",
    "+238": "CV",
    "+239": "ST",
    "+240": "GQ",
    "+241": "GA",
    "+242": "CG",
    "+243": "CD",
    "+244": "AO",
    "+245": "GW",
    "+246": "IO",
    "+248": "SC",
    "+249": "SD",
    "+250": "RW",
    "+251": "ET",
    "+252": "SO",
    "+253": "DJ",
    "+254": "KE",
    "+255": "TZ",
    "+256": "UG",
    "+257": "BI",
    "+258": "MZ",
    "+260": "ZM",
    "+261": "MG",
    "+262": "RE",
    "+263": "ZW",
    "+264": "NA",
    "+265": "MW",
    "+266": "LS",
    "+267": "BW",
    "+268": "SZ",
    "+269": "KM",
    "+290": "SH",
    "+291": "ER",
    "+297": "AW",
    "+298": "FO",
    "+299": "GL",
    "+350": "GI",
    "+351": "PT",
    "+352": "LU",
    "+353": "IE",
    "+354": "IS",
    "+355": "AL",
    "+356": "MT",
    "+357": "CY",
    "+358": "FI",
    "+359": "BG",
    "+370": "LT",
    "+371": "LV",
    "+372": "EE",
    "+373": "MD",
    "+374": "AM",
    "+375": "BY",
    "+376": "AD",
    "+377": "MC",
    "+378": "SM",
    "+379": "VA",
    "+380": "UA",
    "+381": "RS",
    "+382": "ME",
    "+385": "HR",
    "+386": "SI",
    "+387": "BA",
    "+389": "MK",
    "+420": "CZ",
    "+421": "SK",
    "+423": "LI",
    "+500": "FK",
    "+501": "BZ",
    "+502": "GT",
    "+503": "SV",
    "+504": "HN",
    "+505": "NI",
    "+506": "CR",
    "+507": "PA",
    "+508": "PM",
    "+509": "HT",
    "+590": "GP",
    "+591": "BO",
    "+592": "GY",
    "+593": "EC",
    "+594": "GF",
    "+595": "PY",
    "+596": "MQ",
    "+597": "SR",
    "+598": "UY",
    "+599": "AN",
    "+670": "TL",
    "+672": "NF",
    "+673": "BN",
    "+674": "NR",
    "+675": "PG",
    "+676": "TO",
    "+677": "SB",
    "+678": "VU",
    "+679": "FJ",
    "+680": "PW",
    "+681": "WF",
    "+682": "CK",
    "+683": "NU",
    "+685": "WS",
    "+686": "KI",
    "+687": "NC",
    "+688": "TV",
    "+689": "PF",
    "+690": "TK",
    "+691": "FM",
    "+692": "MH",
    "+850": "KP",
    "+852": "HK",
    "+853": "MO",
    "+855": "KH",
    "+856": "LA",
    "+880": "BD",
    "+886": "TW",
    "+960": "MV",
    "+961": "LB",
    "+962": "JO",
    "+963": "SY",
    "+964": "IQ",
    "+965": "KW",
    "+966": "SA",
    "+967": "YE",
    "+968": "OM",
    "+970": "PS",
    "+971": "AE",
    "+972": "IL",
    "+973": "BH",
    "+974": "QA",
    "+975": "BT",
    "+976": "MN",
    "+977": "NP",
    "+992": "TJ",
    "+993": "TM",
    "+994": "AZ",
    "+995": "GE",
    "+996": "KG",
    "+998": "UZ"
  };

  return countryMap[countryCode] ?? "GB"; // Default to "US" if not found
}

// for figma width to UI
double? convertFigmaToUIWidth(double figmaValue, double screenWidth,
    {double? ipadWidth}) {
  try {
    if (screenWidth >= 600) {
      return ipadWidth ?? figmaValue;
    }
    double value = (figmaValue * screenWidth) / 430;
    return value;
  } catch (e) {
    print(e.toString());
    return null;
  }
}
