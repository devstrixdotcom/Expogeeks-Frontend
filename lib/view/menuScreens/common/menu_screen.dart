import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/data/remote/get_user_data.dart';
import 'package:event_pro/data/local/shared_pref_helper.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/view/authScreen/role_selection_screen.dart';
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

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget Function() builder;

  const _MenuItem(this.title, this.icon, this.builder);
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    initPref();
    super.initState();
  }

  initPref() async {
    await GetUserData().getUserDetails();
    if (mounted) setState(() {});
  }

  bool get _isExhibitor => constant.userType == constant.exhibitorUser;

  List<_MenuItem> get _items => _isExhibitor
      ? [
          _MenuItem('Scanned Visitors', Icons.qr_code_scanner_rounded,
              () => ScaneedVistors(isAfterScan: false)),
          _MenuItem('Notification', Icons.notifications_none_rounded,
              () => NotificationScreen()),
          _MenuItem('Meeting Requests', Icons.handshake_outlined,
              () => ExhibitorMeetingsScreen(isFromAppStart: false)),
          _MenuItem('Meeting Slots', Icons.schedule_rounded,
              () => MeetingSlotsScreen()),
          _MenuItem('Profile', Icons.person_outline_rounded,
              () => MyProfileScreen()),
          _MenuItem('Visitor Feedback', Icons.rate_review_outlined,
              () => FeedbackListScreens()),
        ]
      : [
          _MenuItem(
              'Scanned Exhibitor',
              Icons.qr_code_scanner_rounded,
              () => ScannedExhibitorsScreen(
                  isAfterScan: false, isAfterScanExhibitortorId: '')),
          _MenuItem('Notification', Icons.notifications_none_rounded,
              () => NotificationScreen()),
          _MenuItem('Meetings', Icons.handshake_outlined,
              () => MeetingListScreen()),
          _MenuItem('Calendar', Icons.calendar_month_outlined,
              () => CalendarScreen()),
          _MenuItem('Favorites', Icons.favorite_border_rounded,
              () => FavoriteScreen()),
          _MenuItem('Profile', Icons.person_outline_rounded,
              () => MyProfileScreen()),
        ];

  void _open(Widget Function() builder) {
    Navigator.push<void>(
        context, MaterialPageRoute<void>(builder: (context) => builder()));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final items = _items;
    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushReplacementNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          backgroundColor: cyangreenLight,
          appBar: AppBar(
            shadowColor: Colors.transparent,
            backgroundColor: cyangreenLight,
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
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _profileHeader(width),
                SizedBox(height: 20),
                _card(
                  child: Column(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        menuItemBuilder(items[i].title, items[i].icon,
                            () => _open(items[i].builder)),
                        if (i != items.length - 1)
                          Divider(
                              height: 1,
                              indent: 68,
                              endIndent: 16,
                              color: Colors.grey.shade200),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _card(
                  child: menuItemBuilder(
                      'Logout', Icons.logout_rounded, () => _confirmLogout(width),
                      color: Colors.red.shade600, showChevron: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(color: Colors.transparent, child: child),
    );
  }

  Widget _profileHeader(double width) {
    final name = constant.nameValue.trim();
    final email = constant.emailValue.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return _card(
      child: InkWell(
        onTap: () => _open(() => MyProfileScreen()),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              getCircularImageWidget(
                  convertFigmaToUIWidth(58, width) ?? 58,
                  constant.circularImageLinkValue,
                  cyangreenLight,
                  cyangreen,
                  convertFigmaToUIWidth(22, width) ?? 22,
                  initial),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isNotEmpty ? name : 'Welcome',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: convertFigmaToUIWidth(17, width),
                            fontWeight: FontWeight.w600,
                            color: black)),
                    if (email.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(13, width),
                              color: textColor)),
                    ],
                    SizedBox(height: 6),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: cyangreenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_isExhibitor ? 'Exhibitor' : 'Visitor',
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(11, width),
                              fontWeight: FontWeight.w600,
                              color: cyangreen)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: convertFigmaToUIWidth(16, width),
                  color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(double width) {
    Widget ok = ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(cyangreen)),
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
        SharedPreferencesHelper.setIsFirstTime(firstTime: false);
        Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => const RoleSelectionScreen()),
            (route) => false);
      },
    );
    Widget cancel = ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(cyangreen)),
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
  }

  Widget menuItemBuilder(String text, IconData icon, VoidCallback ontap,
      {Color color = cyangreen, bool showChevron = true}) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      height: 1.5,
                      fontSize: convertFigmaToUIWidth(16, width),
                      fontWeight: FontWeight.w500,
                      color: color == cyangreen ? textColor : color)),
            ),
            if (showChevron)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: convertFigmaToUIWidth(15, width),
                  color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
