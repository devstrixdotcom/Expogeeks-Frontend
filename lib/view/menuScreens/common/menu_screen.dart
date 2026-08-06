import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/data/remote/get_user_data.dart';
import 'package:event_pro/data/local/shared_pref_helper.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/view/authScreen/login_screen.dart';
import 'package:event_pro/view/feedback/ExhibitorFlow/visitor_feedback_list.dart';
import 'package:event_pro/view/menuScreens/exhibitor/exihibitors_mettings.dart';
import 'package:event_pro/view/menuScreens/visitor/calendar_screen.dart';
import 'package:event_pro/view/menuScreens/visitor/favorites_screen.dart';
import 'package:event_pro/view/menuScreens/visitor/meeting_list_screen.dart';
import 'package:event_pro/view/menuScreens/exhibitor/meeting_slots_screen.dart';
import 'package:event_pro/view/menuScreens/common/my_profile.dart';
import 'package:event_pro/view/menuScreens/common/notification.dart';
import 'package:event_pro/view/menuScreens/visitor/scanned_exhibitors.dart';
import 'package:event_pro/view/menuScreens/exhibitor/scanned_visitors.dart';
import 'package:flutter/material.dart';

import '../../feedback/VisitorFlow/exhibitor_feedback_list.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    initPref();
    super.initState();
  }

  initPref() async {
    await GetUserData().getUserDetails();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    return BaseScreen(
      onItemSelected: (index) {
        // Navigator.pushNamedAndRemoveUntil(context, getRouteForIndex(index), (route) => false);
        Navigator.pushReplacementNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: WillPopScope(
        onWillPop: () async {
          // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          // return false; // prevent default pop
          // i need simple navigator pop
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Colors.transparent,
            // backgroundColor: Colors.transparent,
            backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Text("Menu",
                style: TextStyle(
                    height: 1.5,
                    
                    fontSize: convertFigmaToUIWidth(20, width),
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            flexibleSpace: Container(
              
              height: convertFigmaToUIWidth(200, width),
              decoration: BoxDecoration(
                color: cyangreen,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Navigator.pushReplacementNamed(context, '/home');
                Navigator.pop(context);
              },
            ),
          ),
          body: Container(
            height: size.height,
            width: size.width,
            // color: Colors.white,
            color: Color.fromRGBO(204, 232, 234, 0.7),
            child: constant.userType != constant.exhibitorUser
                ? Column(
                    children: [
                      // SizedBox(height: 20),
                      SizedBox(height: convertFigmaToUIWidth(20, width),),
                      // Divider(),
                      menuItemBuilder('Scanned Exhibitor', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    ScannedExhibitorsScreen(
                                        isAfterScan: false,
                                        isAfterScanExhibitortorId: '')));
                      }),
                      Divider(),
                      menuItemBuilder('Notification', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    NotificationScreen()));
                      }),
                      Divider(),
                      menuItemBuilder('Meetings', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    MeetingListScreen()));
                      }),
                      Divider(),
                      menuItemBuilder('Calendar', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    CalendarScreen()));
                      }),
                      Divider(),
                      menuItemBuilder('Favorites', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    FavoriteScreen()));
                      }),
                      Divider(),
                      menuItemBuilder('Profile', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    MyProfileScreen()));
                      }),
                      Divider(),
                      // menuItemBuilder('Feedback', () {
                      //   Navigator.push<void>(
                      //       context,
                      //       MaterialPageRoute<void>(
                      //           builder: (BuildContext context) =>
                      //               ExhibitorFeedbackListScreen()));
                      // }),
                      // Divider(),
                      menuItemBuilder('Logout', () {
                        Widget ok = ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(cyangreen)),
                          // child: Text("Ok"),
                          child: Text("Yes"),
                          onPressed: () {
                            Navigator.of(context).pop();
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
                            SharedPreferencesHelper.setIsFirstTime(
                                firstTime: false);
                            Navigator.pushAndRemoveUntil<void>(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        LoginPage()),
                                (route) => false);
                          },
                        );
                        Widget cancel = ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(cyangreen)),
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        );
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              // title: Text("Log out!"),
                              // content: Text("Are you sure you want to log out?"),
                              title: Text(
                                "Log out!",
                                style: TextStyle(fontSize: 
                                // 18
                                convertFigmaToUIWidth(18, width)
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to log out?",
                                style: TextStyle(fontSize: 
                                // 14
                                convertFigmaToUIWidth(14, width)
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              actions: [cancel, ok],
                              elevation: 5,
                            );
                          },
                        );
                      }),
                      Divider(),
                    ],
                  )
                : Column(
                    children: [
                      // SizedBox(height: 20),
                      SizedBox(height: convertFigmaToUIWidth(20, width),),
                      menuItemBuilder('Scanned Visitors', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    ScaneedVistors(isAfterScan: false)));
                      }),
                      Divider(),
                      menuItemBuilder('Notification', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    NotificationScreen()));
                      }),
                      Divider(),
                      menuItemBuilder('Meeting Requests', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    ExhibitorMeetingsScreen(
                                        isFromAppStart: false)));
                      }),
                      Divider(),
                      menuItemBuilder('Meeting Slots', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    MeetingSlotsScreen()));
                      }),
                      Divider(),
                      menuItemBuilder('Profile', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    MyProfileScreen()));
                      }),
                      Divider(),
                      menuItemBuilder('Visitor Feedback', () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    FeedbackListScreens()));
                      }),
                      Divider(),
                      menuItemBuilder('Logout', () {
                        Widget ok = ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(cyangreen)),
                          child: const Text("Ok"),
                          onPressed: () {
                            Navigator.of(context).pop();
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
                            SharedPreferencesHelper.setIsFirstTime(
                                firstTime: false);
                            Navigator.pushAndRemoveUntil<void>(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        LoginPage()),
                                (route) => false);
                          },
                        );
                        Widget cancel = ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(cyangreen)),
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        );

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              // title: Text("Log out!"),
                              // content: Text("Are you sure you want to log out?"),
                              title: Text(
                                "Log out!",
                                style: TextStyle(fontSize: convertFigmaToUIWidth(18, width)),
                              ),
                              content: Text(
                                "Are you sure you want to log out?",
                                style: TextStyle(fontSize: convertFigmaToUIWidth(14, width)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              actions: [cancel, ok],
                              elevation: 5,
                            );
                          },
                        );
                      }),
                      Divider(),
                    ],
                  ),
          ),
          // backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget menuItemBuilder(String text, ontap) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 10, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text,
                style: TextStyle(
                    height: 1.5,
                    fontSize: convertFigmaToUIWidth(19.45, width),
                    fontWeight: FontWeight.w500,
                    color: textColor)),
            Icon(Icons.arrow_forward_ios_rounded, size: 
            // 18
            convertFigmaToUIWidth(18, width)
            ),
          ],
        ),
      ),
    );
  }
}
