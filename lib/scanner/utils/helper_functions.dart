// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:event_pro/scanner/data/local/contants.dart';
import 'package:event_pro/scanner/data/local/shared_pref_helper.dart';
import 'package:event_pro/scanner/utils/color.dart';
import 'package:event_pro/view/authScreen/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mailto/mailto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

showInvalidTokenDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    // child: Text("OK", style: TextStyle(height: 1.5, fontSize: 14)),
    child: TextButton(
                child: Text('OK',
                    style: TextStyle(height: 1.5, color: cyangreen)),
                onPressed: () {
                  Navigator.pop(context);
                }),
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
              builder: (BuildContext context) => const RoleSelectionScreen()),
          (route) => false);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Session Expired", style: TextStyle(height: 1.5, fontSize: 16)),
    content:
        Text("Please Login Again", style: TextStyle(height: 1.5, fontSize: 14)),
    actions: [okButton],
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
    textColor: cyangreen
  );
}

sharingOnTap(String link) async {
  String url = link;
  final encodedUrl = Uri.encodeFull(url);
  Uri uri = Uri.parse(encodedUrl);

  try {
    await launchUrl(uri);
  } catch (e) {
    debugPrint(e.toString());
  } finally {
    await Future.delayed(const Duration(seconds: 3));
  }
}

sendingMails(String mail) async {
  final mailtoLink = Mailto(to: [mail], subject: '', body: '');

  try {
    if (await launch('$mailtoLink')) {
      await canLaunch('$mailtoLink');
    } else {}
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
    String day = dateParts[0].replaceAll(RegExp(r'[^0-9]'), ''); // Remove suffix
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