import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/notification_model.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../exhibitor/meeting_slots_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static String id = "NotificationScreen";

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  List<NotificationModel> notificationList = [];
  bool isLoading = true;
  DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    dynamic response = await apiValue.getUserNotificationList(context);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        notificationList =
            tempList.map((i) => NotificationModel.fromJson(i)).toList();
        print(notificationList.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: Scaffold(
        appBar: normalAppBarBuilder("Notifications", context),
        body: Container(
          height: size.height,
          width: size.width,
          color: Color.fromRGBO(204, 232, 234, 0.7),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : notificationList.isEmpty
                  ? Center(
                      child: Text(
                        "No Notifications",
                        style: TextStyle(
                          // fontSize: 18,
                          fontSize: convertFigmaToUIWidth(18, width),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: BouncingScrollPhysics(),
                            child: dateSectionBuilder(notificationList),
                          ),
                        ),
                      ],
                    ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  String removeOrdinalSuffix(String date) {
    return date.replaceAll(RegExp(r'(st|nd|rd|th)'), '');
  }

  Widget dateSectionBuilder(List<NotificationModel> list) {
    double w = MediaQuery.of(context).size.width;

    // Preprocess dates to remove ordinal suffixes
    list.forEach((notification) {
      notification.createdDate =
          removeOrdinalSuffix(notification.createdDate ?? '');
    });

    list.sort((a, b) => DateTime.parse(
            dateFormat.parse(b.createdDate ?? '').toString())
        .compareTo(
            DateTime.parse(dateFormat.parse(a.createdDate ?? '').toString())));

    Map<String, List<NotificationModel>> groupedMeetings = {};

    for (var meeting in list) {
      String formattedDate =
          DateTime.parse(dateFormat.parse(meeting.createdDate!).toString())
              .toString();
      if (groupedMeetings[formattedDate] == null) {
        groupedMeetings[formattedDate] = [];
      }
      groupedMeetings[formattedDate]!.add(meeting);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedMeetings.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 20),
              child: Text(
                DateFormatter.formatDayWithSuffix(
                    dateFormat.format(DateTime.parse(entry.key.toString()))),
                style: TextStyle(
                    height: 1.5,
                    color: Color.fromRGBO(85, 85, 85, 1),
                    fontSize: convertFigmaToUIWidth(14, w),
                    fontWeight: FontWeight.w400),
              ),
            ),
            notificationListBuilder(entry.value),
            if (groupedMeetings.entries.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 55, top: 15),
                child: Divider(color: Colors.grey, thickness: 0.2),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget notificationListBuilder(List<NotificationModel> notiList) {
    double w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: notiList.length,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 14);
        },
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if (constant.userType == 'exhibitor_team') {
                Navigator.pop(context);
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => MeetingSlotsScreen(),
                  ),
                );
              }
            },
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: cyangreenLight,
                          borderRadius: BorderRadius.circular(37)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: convertFigmaToUIWidth(51, w),
                                width: convertFigmaToUIWidth(51, w),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: Icon(Icons.notifications_none_rounded,
                                    color: cyangreen),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notiList[index].message ?? '',
                                    style: TextStyle(
                                        height: 1.5,
                                        color: Color.fromRGBO(85, 85, 85, 1),
                                        fontSize: convertFigmaToUIWidth(12, w),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                SizedBox(width: convertFigmaToUIWidth(8, w)),
                                Container(
                                    height: convertFigmaToUIWidth(24, w),
                                    width: convertFigmaToUIWidth(24, w),
                                    child: Center(
                                        child: Image(
                                            image: AssetImage(requestAccept)))),
                                SizedBox(width: convertFigmaToUIWidth(13, w)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
