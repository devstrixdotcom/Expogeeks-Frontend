// import 'package:calendar_timeline/calendar_timeline.dart';
// import 'package:event_pro/utils/helper_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../data/remote/api_value.dart';
// import '../../../models/meetings_list_model.dart';
// import '../../../sharedwidget/appbar__search_field.dart';
// import '../../../utils/basic_route.dart';
// import '../../../utils/color.dart';
// import '../../base_screen.dart';

// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({super.key});

//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   final ScrollController _scrollController = ScrollController();
//   List<MeetingListModel> meetingList = [];
//   bool isLoading = true;
//   DateFormat dateFormat = DateFormat('dd MMM yyyy');
//   late DateTime _selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = DateTime.now();
//     initialPref();
//   }

//   Future<void> initialPref() async {
//     try {
//       dynamic response = await apiValue.GetUserMeetingList(context);
//       if (response != null) {
//         setState(() {
//           isLoading = false;
//           var tempList = response as List;
//           meetingList =
//               tempList.map((i) => MeetingListModel.fromJson(i)).toList();

//           // Filter out past meetings
//           meetingList = meetingList.where((meeting) {
//             final meetingDate = correctDate(meeting.meetingDate ?? '');
//             return meetingDate.isAfter(DateTime.now());
//           }).toList();

//           // Set default selectedDate as the meeting's date (first meeting in the list)
//           if (meetingList.isNotEmpty) {
//             _selectedDate = correctDate(meetingList[0].meetingDate ?? '');
//           }
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching meeting list: $e');
//     }
//   }

//   DateTime correctDate(String dateValue) {
//     if (dateValue.isEmpty) return DateTime(1900, 1, 1);

//     String cleanedDate = dateValue.replaceAll(RegExp(r'(st|nd|rd|th)'), '');

//     try {
//       return dateFormat.parse(cleanedDate);
//     } catch (e) {
//       print('Error parsing date: $dateValue');
//       return DateTime(1900, 1, 1);
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;

//     return BaseScreen(
//       onItemSelected: (index) =>
//           Navigator.pushNamed(context, getRouteForIndex(index)),
//       selectedIndex: 3,
//       child: Scaffold(
//         appBar: normalAppBarBuilder("Calendar", context),
//         body: Container(
//           height: height,
//           width: width,
//           color: Color.fromRGBO(204, 232, 234, 0.7),
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator(color: cyangreen))
//               : _buildMeetingList(height, width),
//         ),
//         backgroundColor: Colors.white,
//       ),
//     );
//   }

//   Widget _buildMeetingList(double height, double width) {
//     // Filter meetings for the selected date
//     final selectedDateMeetings = meetingList.where((meeting) {
//       final meetingDate = correctDate(meeting.meetingDate ?? '');
//       return meetingDate.isAtSameMomentAs(_selectedDate);
//     }).toList();

//     // If no meetings for the selected date, show only the calendar
//     if (selectedDateMeetings.isEmpty) {
//       showToast('No Meetings');

//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Center(
//           child: Column(
//             children: [
//               _buildCalendar(),
//               SizedBox(height: 20),
//               Text(
//                 'No Meetings',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             controller: _scrollController,
//             physics: BouncingScrollPhysics(),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Column(
//                 children: [
//                   _buildCalendar(),
//                   SizedBox(height: 20),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHourListWithMeetings(selectedDateMeetings),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _buildHourListWithMeetings(
//   //     List<MeetingListModel> selectedDateMeetings) {
//   //   final hours = const [
//   //     '07:00',
//   //     '08:00',
//   //     '09:00',
//   //     '10:00',
//   //     '11:00',
//   //     '12:00',
//   //     '13:00',
//   //     '14:00',
//   //     '15:00',
//   //     '16:00',
//   //     '17:00',
//   //     '18:00',
//   //     '19:00',
//   //     '20:00',
//   //     '21:00',
//   //     '22:00',
//   //     '23:00'
//   //   ];

//   //   List<Widget> hourWidgets = hours.map((hour) {
//   //     final meetingsForHour = selectedDateMeetings.where((meeting) {
//   //       // Extract hour from meetingTime and compare it with the current hour
//   //       final meetingHour = meeting.meetingTime?.split(':')[0];
//   //       final currentHour = hour.split(':')[0];
//   //       return meetingHour == currentHour;
//   //     }).toList();

//   //     return _buildTimeSlotWithMeetings(hour, meetingsForHour);
//   //   }).toList();

//   //   return Column(
//   //     children: hourWidgets,
//   //   );
//   // }

//   Widget _buildHourListWithMeetings(
//       List<MeetingListModel> selectedDateMeetings) {
//     final hours = const [
//       '07:00',
//       '08:00',
//       '09:00',
//       '10:00',
//       '11:00',
//       '12:00',
//       '13:00',
//       '14:00',
//       '15:00',
//       '16:00',
//       '17:00',
//       '18:00',
//       '19:00',
//       '20:00',
//       '21:00',
//       '22:00',
//       '23:00'
//     ];

//     List<Widget> hourWidgets = hours.map((hour) {
//       final meetingsForHour = selectedDateMeetings.where((meeting) {
//         final meetingTime = correctMeetingTime(meeting.meetingTime ?? '');
//         return meetingTime == hour;
//       }).toList();

//       return _buildTimeSlotWithMeetings(hour, meetingsForHour);
//     }).toList();

//     return Column(
//       children: hourWidgets,
//     );
//   }

//   String correctMeetingTime(String meetingTime) {
//     // Convert 12-hour time to 24-hour format
//     final timeParts = meetingTime.split(':');
//     int hour = int.parse(timeParts[0]);
//     int minute = int.parse(timeParts[1]);

//     if (hour == 12) {
//       hour = 0; // Handle 12 AM case
//     }
//     if (hour < 12) {
//       // Convert to PM by adding 12 hours if time is in AM
//       hour += 12;
//     }

//     return hour.toString().padLeft(2, '0') + ':00'; // Return in 24-hour format
//   }

//   Widget _buildTimeSlotWithMeetings(
//       String hour, List<MeetingListModel> meetingsForHour) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start, // Align the content to the top
//         children: [
//           // Hour container
//           Container(
//             width: 70,
//             decoration: BoxDecoration(
//               color: cyangreen.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8.0),
//               border: Border.all(color: Colors.black54, width: 1),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Center(
//                 child: Text(
//                   hour,
//                   style: TextStyle(fontSize: 12, color: Colors.black),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 10),

//           // Meeting info containers (stacked vertically)
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: meetingsForHour
//                   .map((meeting) => Padding(
//                         padding: const EdgeInsets.only(bottom: 4.0),
//                         child: _buildMeetingInfoContainer(
//                           meeting.exhibitorName ?? 'N/A',
//                           meeting.categoryName ?? 'N/A',
//                           meeting.teamName ?? 'N/A',
//                           meeting.status ?? 'N/A',
//                           true,
//                         ),
//                       ))
//                   .toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCalendar() {
//     // final meetingDate =
//     //     meetingList.isNotEmpty ? meetingList.first.meetingDate ?? 'N/A' : 'N/A';

//     // Get the current date
//     final currentDate = DateTime.now();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: CalendarTimeline(
//             showYears: false,
//             initialDate: _selectedDate,
//             // Start the calendar from today
//             firstDate: currentDate,
//             // Set lastDate to 4 days ahead from today
//             lastDate: currentDate.add(const Duration(days: 4)),
//             onDateSelected: (date) => setState(() => _selectedDate = date),
//             monthColor: Colors.teal[800],
//             dayColor: Colors.teal[200],
//             dayNameColor: const Color(0xFF333A47),
//             activeDayColor: Colors.white,
//             activeBackgroundDayColor: Colors.redAccent[100],
//             dotColor: Colors.white,
//             selectableDayPredicate: (date) => date.isAfter(currentDate
//                 .subtract(Duration(days: 1))), // Prevent selecting past dates
//             locale: 'en',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMeetingInfoContainer(String exhibitorName, String categoryName,
//       String teamName, String status, bool isMeetingTime) {
//     Color containerColor = getStatusColor(status);

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: containerColor,
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.black, width: 1),
//       ),
//       // margin: const EdgeInsets.only(left: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '$exhibitorName ($categoryName)',
//               style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w400),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '$teamName',
//               style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w400),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color getStatusColor(String status) {
//     switch (status) {
//       case 'Accepted':
//         return cyangreen;
//       case 'Rejected':
//         return Colors.red;
//       case 'Pending':
//         return LightPinkShade;
//       default:
//         return white;
//     }
//   }
// }

import 'package:event_pro/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import '../../../data/local/contants.dart';
import '../../../data/remote/api_value.dart';
import '../../../models/meetings_list_model.dart';
import '../../../sharedwidget/appbar__search_field.dart';
import '../../../utils/basic_route.dart';
import '../../../utils/color.dart';
import '../../base_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScrollController _scrollController = ScrollController();

  List<DateSlotsModel> dateSlots = [];

  MeetingListModel? exhibitorDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    print(constant.userType);
    setState(() {
      isLoading = true;
    });

    dynamic response = await apiValue.GetVisitorCalendarDetails(context);

    if (response != null) {
      setState(() {
        isLoading = false;

        // Expecting response to be a List, parsing it accordingly
        List<dynamic> tempList = response as List<dynamic>;

        // Convert list items to MeetingListModel objects
        exhibitorDetails = MeetingListModel(
            dateList: tempList.map((e) => DateSlotsModel.fromJson(e)).toList());

        if (exhibitorDetails!.dateList != null) {
          print(exhibitorDetails!.dateList!.length);
          dateSlots = exhibitorDetails!.dateList!;
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> generateMainTimeSlots(List<TimeSlotsModel> list) {
    List<String> mainTimeSlots = [];
    Set<String> uniqueHours = {};
    for (var slot in list) {
      String hour = slot.time!.split(":")[0];
      uniqueHours.add(hour);
    }
    mainTimeSlots.clear();
    mainTimeSlots.addAll(uniqueHours.map((hour) => "$hour:00").toList());
    mainTimeSlots.sort((a, b) =>
        int.parse(a.split(":")[0]).compareTo(int.parse(b.split(":")[0])));
    return mainTimeSlots;
  }

  List<TimeSlotsModel> getTimeSlotsForHour(
      String hour, List<TimeSlotsModel> list) {
    return list.where((slot) => slot.time!.startsWith(hour)).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: Scaffold(
        appBar: normalAppBarBuilder("Calendar", context),
        body: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Color.fromRGBO(204, 232, 234, 0.7),
            // color: white,
            // borderRadius: BorderRadius.circular(12),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              dateSlots.isEmpty
                                  ? SizedBox(
                                      height: height - kToolbarHeight,
                                      child: Center(
                                        child: Text(
                                          "No Meetings Available",
                                          style: TextStyle(
                                            // fontSize: 16,
                                            fontSize: convertFigmaToUIWidth(16, width),
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: dateSlots.length,
                                      shrinkWrap: true,
                                      // physics: NeverScrollableScrollPhysics(),
                                      physics: ClampingScrollPhysics(),
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(height: 30);
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        List<TimeSlotsModel> timeSlots =
                                            exhibitorDetails!.dateList![index]
                                                    .timeList ??
                                                [];

                                        //ONLY SHOW IF THERE ARE TIME SLOTS
                                        if (timeSlots.isEmpty) {
                                          return SizedBox.shrink();
                                        }

                                        List<String> mainTimeSlots =
                                            generateMainTimeSlots(timeSlots);

                                        String apiexhibitionName =
                                            exhibitorDetails!.dateList![index]
                                                    .exhibitionName ??
                                                "";
                                        List<String> parts = apiexhibitionName
                                            .split(',')
                                            .map((e) => e.trim())
                                            .toSet()
                                            .toList();
                                        String exhibitionName =
                                            parts.join(', ');

                                        return Column(children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                // "${dateSlots[index].dateSlot ?? ""} (${dateSlots[index].exhibitionName ?? ""})",
                                                // date and exhibition name
                                                // "${exhibitorDetails!.dateList![index].exhibitionName ?? ""}",
                                                exhibitionName,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  height: 1.5,
                                                  color: Color.fromRGBO(
                                                      85, 85, 85, 1),
                                                  // fontSize: 13,
                                                  fontSize: convertFigmaToUIWidth(13, width),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // SizedBox(height: 10),
                                          SizedBox(height: convertFigmaToUIWidth(10, width),),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                // "${dateSlots[index].dateSlot ?? ""} (${dateSlots[index].exhibitionName ?? ""})",
                                                // date and exhibition name
                                                "${exhibitorDetails!.dateList![index].dateSlot ?? ""}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  height: 1.5,
                                                  color: Color.fromRGBO(
                                                      85, 85, 85, 1),
                                                  // fontSize: 13,
                                                  fontSize: convertFigmaToUIWidth(13, width),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 24),
                                          //--------------------------time table------------------------------------//

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 25.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    // physics:
                                                    //     NeverScrollableScrollPhysics(),
                                                    physics:
                                                        ClampingScrollPhysics(),
                                                    itemCount:
                                                        mainTimeSlots.length,
                                                    separatorBuilder: (context,
                                                            index) =>
                                                        // SizedBox(height: 10),
                                                        SizedBox(height: convertFigmaToUIWidth(10, width) ?? 10,),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int mainIndex) {
                                                      String hour =
                                                          mainTimeSlots[
                                                                  mainIndex]
                                                              .split(":")[0];
                                                      List<TimeSlotsModel>
                                                          filteredSlots =
                                                          getTimeSlotsForHour(
                                                              hour, timeSlots);

                                                      return GridView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: filteredSlots
                                                            .length,
                                                        controller:
                                                            _scrollController,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 4,
                                                          crossAxisSpacing: 6,
                                                          mainAxisExtent: 33,
                                                          mainAxisSpacing: 6,
                                                        ),
                                                        itemBuilder:
                                                            (context, index) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              if (filteredSlots[
                                                                          index]
                                                                      .isBooked ==
                                                                  'true') {
                                                                _showPopup(
                                                                    context,
                                                                    filteredSlots[
                                                                        index]);
                                                              }
                                                            },
                                                            child: Container(
                                                              width: convertFigmaToUIWidth(65, width),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: _getTimeSlotColor(
                                                                    filteredSlots[
                                                                        index]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border:
                                                                    Border.all(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          0.6),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              
                                                              child: Center(
                                                                child: Text(
                                                                  filteredSlots[
                                                                              index]
                                                                          .time ??
                                                                      '',
                                                                  style:
                                                                      TextStyle(
                                                                    height: 1.5,
                                                                    // fontSize:
                                                                    //     10,
                                                                    fontSize: convertFigmaToUIWidth(10, width),
                                                                    color: _getTextColor(
                                                                        filteredSlots[
                                                                            index]), // Change font color dynamically
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // SizedBox(height: 16),
                                          SizedBox(height: convertFigmaToUIWidth(16, width),),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Container(
                                              height: 1,
                                              width: double.infinity,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                        ]);
                                      },
                                    ),
                              
                              SizedBox(height: convertFigmaToUIWidth(200, width),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Color _getTimeSlotColor(TimeSlotsModel slot) {
    if (slot.isBooked == 'true') {
      switch (slot.meetingStatus) {
        case 'Pending':
          return Pink; // Pink color
        case 'Accepted':
          return cyangreen; // Assuming cyangreen is defined somewhere
        case 'Rejected':
          return const Color.fromARGB(255, 119, 44, 39); // Red color
        default:
          return Color.fromRGBO(255, 255, 255, 0.6); // Default color
      }
    } else {
      return Color.fromRGBO(255, 255, 255, 0.6); // Default color
    }
  }

  Color _getTextColor(TimeSlotsModel slot) {
    if (slot.isBooked == 'true' && slot.meetingStatus == 'Accepted') {
      return Colors.white; // White font for accepted slots
    } else {
      return const Color.fromRGBO(85, 85, 85, 1); // Default font color
    }
  }

// SHOW POPUP

  // void _showPopup(BuildContext context, var selectedSlot) async {
  //   // Show a loading indicator while fetching data
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Center(child: CircularProgressIndicator());
  //     },
  //   );

  //   try {
  //     var response = await apiValue.GetUserMeetingList(context);

  //     Navigator.of(context).pop(); // Close loading dialog

  //     if (response != null && response is List && response.isNotEmpty) {
  //       // Find the meeting matching the selected slot's time
  //       var selectedMeeting = response.firstWhere(
  //         (meeting) => meeting['meetingTime'] == selectedSlot.time,
  //         orElse: () => null,
  //       );

  //       if (selectedMeeting != null) {
  //         // Usage in your existing code:
  //         String status = selectedMeeting['status'] ?? 'N/A';
  //         String meetingTime = selectedMeeting['meetingTime'] ?? 'N/A';
  //         String meetingDate = selectedMeeting['meetingDate'] ?? 'N/A';
  //         meetingDate = DateFormatter.formatDayWithSuffix(meetingDate);
  //         String exhibitorName = selectedMeeting['exhibitorName'] ?? 'N/A';
  //         String categoryName = selectedMeeting['categoryName'] ?? 'N/A';

  //         // Show the actual popup with meeting details
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(15.0), // Rounded corners
  //               ),
  //               title: Text(
  //                 'Meeting Details',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 20.0,
  //                   fontWeight: FontWeight.bold,
  //                   color: cyangreen, // Title color
  //                 ),
  //               ),
  //               content: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     _buildDetailRow('Exhibitor:', exhibitorName),
  //                     _buildDetailRow('Category:', categoryName),
  //                     _buildDetailRow('Date:', meetingDate),
  //                     _buildDetailRow('Time:', meetingTime),
  //                     _buildDetailRow('Status:', status),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       } else {
  //         showToast('Meeting not found for this time.');
  //       }
  //     } else {
  //       showToast('No meeting data found.');
  //     }
  //   } catch (e) {
  //     Navigator.of(context).pop(); // Close loading dialog
  //     showToast('Failed to load data.');
  //   }
  // }
  void _showPopup(BuildContext context, TimeSlotsModel selectedSlot) async {
    var width = MediaQuery.of(context).size.width;
    // Show a loading indicator while fetching data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      var response = await apiValue.GetUserMeetingList(context);

      Navigator.of(context).pop(); // Close loading dialog

      if (response != null && response is List && response.isNotEmpty) {
        // Find the meeting matching the selected slot's time
        var selectedMeeting = response.firstWhere(
          (meeting) => meeting['meetingTime'] == selectedSlot.time,
          orElse: () => null,
        );

        if (selectedMeeting != null) {
          // Usage in your existing code:
          String status = selectedSlot.meetingStatus ??
              'N/A'; // Use meetingStatus from selectedSlot
          String meetingTime = selectedMeeting['meetingTime'] ?? 'N/A';
          String meetingDate = selectedMeeting['meetingDate'] ?? 'N/A';
          String exhibitorName = selectedMeeting['exhibitorName'] ?? 'N/A';
          String categoryName = selectedMeeting['categoryName'] ?? 'N/A';
          String teamName = selectedMeeting['teamName'] ?? 'N/A';
          String stallNo = selectedMeeting['stallNo'] ?? 'N/A';

          // Show the actual popup with meeting details
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0), // Rounded corners
                ),
                title: Text(
                  'Meeting Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontSize: 20.0,
                    fontSize: convertFigmaToUIWidth(20, width),
                    fontWeight: FontWeight.bold,
                    color: cyangreen, // Title color
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Exhibitor:', exhibitorName),
                      _buildDetailRow('Team:', teamName),
                      _buildDetailRow('Stand No.:', stallNo),
                      _buildDetailRow('Category:', categoryName),
                      _buildDetailRow('Date:', meetingDate),
                      _buildDetailRow('Time:', meetingTime),
                      _buildDetailRow(
                          'Status:', status), // Use the correct status
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          showToast('Meeting not found for this time.');
        }
      } else {
        showToast('No meeting data found.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      showToast('Failed to load data.');
    }
  }

// Helper function to create rows for details
  Widget _buildDetailRow(String title, String value) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // More space for title
            child: Text(
              title,
              style: TextStyle(
                // fontSize: 14.0,
                fontSize: convertFigmaToUIWidth(14, width),
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4, // More space for value, reducing extra space
            child: Text(
              value,
              style: TextStyle(fontSize: convertFigmaToUIWidth(14, width), color: Colors.black87),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
