import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/models/meetings_list_model.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetingListScreen extends StatefulWidget {
  const MeetingListScreen({super.key});

  @override
  State<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<MeetingListModel> MeetingList = [];
  bool isLoading = true;
  DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    dynamic response = await apiValue.GetUserMeetingList(context);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        MeetingList =
            tempList.map((i) => MeetingListModel.fromJson(i)).toList();
        print(MeetingList.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime correctDate(String dateValue) {
    if (dateValue.isEmpty) {
      return DateTime(1900, 1, 1);
    }

    String cleanedDate = dateValue.replaceAll(RegExp(r'(st|nd|rd|th)'), '');

    try {
      DateTime parsedDate = dateFormat.parse(cleanedDate);
      return parsedDate;
    } catch (e) {
      print('Error parsing date: $dateValue');
      return DateTime(1900, 1, 1);
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
        appBar: normalAppBarBuilder("Meetings", context),

        body: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            color: Color.fromRGBO(204, 232, 234, 0.7),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : MeetingList.isEmpty
                  ? Center(
                      child: Text(
                        "No meetings booked",
                        style: TextStyle(
                            // fontSize: 16,
                            fontSize: convertFigmaToUIWidth(16, width),
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    )
                  // : Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Expanded(
                  //         child: SingleChildScrollView(
                  //           controller: _scrollController,
                  //           physics: BouncingScrollPhysics(),
                  //           child: dateSectionBuilder(MeetingList),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  : dateSectionBuilder(MeetingList),
        ),

        // backgroundColor: Colors.white,
      ),
    );
  }

  Widget dateSectionBuilder(List<MeetingListModel> list) {
    // Size size = MediaQuery.of(context).size;
    double w = MediaQuery.of(context).size.width;
    list.sort((a, b) => correctDate(b.meetingDate ?? '')
        .compareTo(correctDate(a.meetingDate ?? '')));

    Map<String, List<MeetingListModel>> groupedMeetings = {};

    for (var meeting in list) {
      String formattedDate = meeting.meetingDate ?? '';
      if (groupedMeetings[formattedDate] == null) {
        groupedMeetings[formattedDate] = [];
      }
      groupedMeetings[formattedDate]!.add(meeting);
    }

    return SingleChildScrollView(
      // Added SingleChildScrollView here
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      child: Padding(
        // space at bottom
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groupedMeetings.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // entry.key.toString(),
                        DateFormatter.formatDayWithSuffix(entry.key),
                        style: TextStyle(
                            height: 1.5,
                            color: Color.fromRGBO(85, 85, 85, 1),
                            fontSize: convertFigmaToUIWidth(12, w),
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: convertFigmaToUIWidth(2, w),
                      ),
                      Text(
                        entry.value.first.showName ?? '',
                        style: TextStyle(
                            height: 1.5,
                            color: Color.fromRGBO(85, 85, 85, 1),
                            fontSize: convertFigmaToUIWidth(12, w),
                            fontWeight: FontWeight.w500),
                      ),
                      // SizedBox(height: 2),
                      SizedBox(
                        height: convertFigmaToUIWidth(2, w),
                      ),
                    ],
                  ),
                ),
                MeetingListBuilder(entry.value),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 55, top: 15, bottom: 15),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget MeetingListBuilder(List<MeetingListModel> notiList) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.separated(
        // physics: NeverScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: notiList.length,
        // itemCount: 10,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            // height: 14
            height: convertFigmaToUIWidth(14, w),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: notiList[index].status == "Pending"
                ? notiList[index].message.toString().replaceAll(' ', '').isEmpty
                    ? null
                    : () {
                        showDialog(
                            context: context,
                            builder: (context) => editDialog(
                                h, w, notiList[index].message ?? '', context));
                      }
                : notiList[index]
                        .replyMessage
                        .toString()
                        .replaceAll(' ', '')
                        .isEmpty
                    ? null
                    : () {
                        showDialog(
                            context: context,
                            builder: (context) => editDialog(h, w,
                                notiList[index].replyMessage ?? '', context));
                      },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 3),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: cyangreenLight,
                  borderRadius: BorderRadius.circular(37)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: convertFigmaToUIWidth(64, w),
                    width: convertFigmaToUIWidth(64, w),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            notiList[index].imageLink ?? '')),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${notiList[index].exhibitorName ?? ''}",
                          style: TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(85, 85, 85, 1),
                              // fontSize: 10,
                              fontSize: convertFigmaToUIWidth(10, w),
                              fontWeight: FontWeight.w500),
                        ),
                        // SizedBox(height: 2),
                        SizedBox(
                          height: convertFigmaToUIWidth(2, w),
                        ),
                        Text(
                          "${(notiList[index].categoryName ?? '').trim()}",
                          style: TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(85, 85, 85, 1),
                              // fontSize: 10,
                              fontSize: convertFigmaToUIWidth(10, w),
                              fontWeight: FontWeight.w500),
                        ),
                        // SizedBox(height: 2),
                        SizedBox(
                          height: convertFigmaToUIWidth(2, w),
                        ),
                        Text(
                          notiList[index].teamName ?? '',
                          style: TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(85, 85, 85, 1),
                              // fontSize: 10,
                              fontSize: convertFigmaToUIWidth(10, w),
                              fontWeight: FontWeight.w500),
                        ),
                        // SizedBox(height: 2),
                        SizedBox(
                          height: convertFigmaToUIWidth(2, w),
                        ),
                        Text(
                          notiList[index].meetingTime ?? '',
                          style: TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(85, 85, 85, 1),
                              // fontSize: 10,
                              fontSize: convertFigmaToUIWidth(10, w),
                              fontWeight: FontWeight.w500),
                        ),
                        // SizedBox(height: 2),
                        SizedBox(
                          height: convertFigmaToUIWidth(2, w),
                        ),
                        Text(
                          // notiList[index].stallNo ?? '',
                          "Stand No: ${notiList[index].stallNo ?? ''}",
                          style: TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(85, 85, 85, 1),
                              // fontSize: 10,
                              fontSize: convertFigmaToUIWidth(10, w),
                              fontWeight: FontWeight.w500),
                        ),
                        // SizedBox(height: 2),
                        SizedBox(
                          height: convertFigmaToUIWidth(2, w),
                        ),
                        notiList[index].status == "Pending"
                            ? notiList[index]
                                    .message
                                    .toString()
                                    .replaceAll(' ', '')
                                    .isEmpty
                                ? SizedBox()
                                : Text(
                                    "Message: ${notiList[index].message ?? ''}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      // fontSize: 10,
                                      fontSize: convertFigmaToUIWidth(10, w),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                            : notiList[index]
                                    .replyMessage
                                    .toString()
                                    .replaceAll(' ', '')
                                    .isEmpty
                                ? SizedBox()
                                : Text(
                                    "Message: ${notiList[index].replyMessage ?? ''}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      // fontSize: 10,
                                      fontSize: convertFigmaToUIWidth(10, w),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  notiList[index].status == "Pending"
                      ? Container(
                          width: convertFigmaToUIWidth(80, w),
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                              color: Pink,
                              borderRadius: BorderRadius.circular(13)),
                          child: Center(
                              child: Text(notiList[index].status ?? '',
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Colors.white,
                                      // fontSize: 10,
                                      fontSize: convertFigmaToUIWidth(10, w),
                                      fontWeight: FontWeight.w500))),
                        )
                      : notiList[index].status == "Accepted"
                          ? Container(
                              width: convertFigmaToUIWidth(80, w),
                              padding: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(2, 141, 148, 0.5),
                                  borderRadius: BorderRadius.circular(13)),
                              child: Center(
                                  child: Text(notiList[index].status ?? '',
                                      style: TextStyle(
                                          height: 1.5,
                                          color: Colors.white,
                                          // fontSize: 10,
                                          fontSize:
                                              convertFigmaToUIWidth(10, w),
                                          fontWeight: FontWeight.w500))),
                            )
                          : Container(
                              width: convertFigmaToUIWidth(80, w),
                              padding: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(13)),
                              child: Center(
                                  child: Text(notiList[index].status ?? '',
                                      style: TextStyle(
                                          height: 1.5,
                                          color: Colors.white,
                                          // fontSize: 10,
                                          fontSize:
                                              convertFigmaToUIWidth(10, w),
                                          fontWeight: FontWeight.w500))),
                            ),
                  SizedBox(width: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  editDialog(double h, double w, String msg, context) {
    return Dialog(
      child: Container(
        width: convertFigmaToUIWidth(347, w),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
            color: cyangreenLight, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Message:',
                  style: TextStyle(
                      height: 1.5,
                      color: Color.fromRGBO(85, 85, 85, 1),
                      // fontSize: 10,
                      fontSize: convertFigmaToUIWidth(14, w),
                      fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(msg,
                  style: TextStyle(
                     fontSize: convertFigmaToUIWidth(14, w),
                      height: 1.5, color: Color.fromRGBO(85, 85, 85, 1))),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 60,
                padding: EdgeInsets.symmetric(vertical: 2),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(child: Text('Cancel',style: TextStyle(fontSize: convertFigmaToUIWidth(14, w)),)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
