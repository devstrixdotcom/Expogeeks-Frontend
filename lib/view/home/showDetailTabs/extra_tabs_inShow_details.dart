// import 'dart:convert';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chewie/chewie.dart';
// import 'package:event_pro/data/remote/api_value.dart';
// import 'package:event_pro/utils/color.dart';
// import 'package:event_pro/data/local/contants.dart';
// import 'package:event_pro/utils/helper_functions.dart';
// import 'package:event_pro/utils/images.dart';
// import 'package:event_pro/models/category_show_list_model.dart';
// import 'package:event_pro/view/base_screen.dart';
// import 'package:event_pro/utils/basic_route.dart';
// import 'package:event_pro/sharedwidget/reminder_alert_box.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:event_pro/utils/share_helper.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:video_player/video_player.dart';

// import '../../../models/categoryDetails_model.dart';

// // ignore: must_be_immutable
// class ExtraTabsInShowsDetails extends StatefulWidget {
//   String title;
//   String categoryId;
//   // String videoId;
//   String imageId;
//   String redirectLink;
//   DateTime eventDate;
//   String organizationId;
//   String titleName;
//   String startTime;

//   ExtraTabsInShowsDetails({
//     super.key,
//     required this.redirectLink,
//     required this.title,
//     required this.categoryId,
//     required this.imageId,
//     required this.eventDate,
//     required this.organizationId,
//     required this.titleName,
//     required this.startTime,
//   });

//   @override
//   State<ExtraTabsInShowsDetails> createState() =>
//       _ExtraTabsInShowsDetailsState();
// }

// class _ExtraTabsInShowsDetailsState extends State<ExtraTabsInShowsDetails> {
//   List<CategoryShowListModel> categoryList = [];
//   bool isLoading = true;
//   bool isPlayed = false;
//   VideoPlayerController? _controllers;
//   int showMoreIndex = -1;

//   DateTime? eventtDate;

//   CategoryDetails? categoryDetails;
//   ChewieController? _chewieController;

//   @override
//   void initState() {
//     super.initState();
//     initialPref();
//   }

//   initialPref() async {
//     // setState(() {
//     //   isLoading = true;
//     // });
//     // Clear existing video controllers before making new API calls
//     if (_chewieController != null) {
//       _chewieController?.dispose();
//       _chewieController = null;
//     }
//     if (_controllers != null) {
//       _controllers?.dispose();
//       _controllers = null;
//     }

//     setState(() {
//       isLoading = true;
//       isPlayed = false; // Reset play state
//       categoryDetails = null; // Clear previous category details
//     });

//     // Call GetCategoryShowList
//     try {
//       dynamic response =
//           await apiValue.GetCategoryShowList(context, widget.categoryId);
//       if (response != null) {
//         var tempList = response as List;
//         categoryList =
//             tempList.map((i) => CategoryShowListModel.fromJson(i)).toList();
//         print('CategoryShowList length: ${categoryList.length}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching category show list: $e');
//     }
//     // Call GetCategoryDetails
//     try {
//       dynamic response =
//           await apiValue.GetCategoryDetails(context, widget.categoryId);
//       if (response != null) {
//         categoryDetails = CategoryDetails.fromJson(response);
//         print('CategoryDetailsssss: ${categoryDetails?.videoLink}');
//         if (categoryDetails?.videoLink != null &&
//             categoryDetails!.videoLink.isNotEmpty) {
//           _controllers = VideoPlayerController.network(
//             categoryDetails!.videoLink,
//             videoPlayerOptions: VideoPlayerOptions(
//               mixWithOthers: true,
//               allowBackgroundPlayback: false,
//             ),
//           )..initialize().then((_) {
//               _chewieController = ChewieController(
//                 videoPlayerController: _controllers!,
//                 autoPlay: false,
//                 looping: false,
//                 aspectRatio: _controllers!.value.aspectRatio,
//                 errorBuilder: (context, errorMessage) {
//                   debugPrint('Chewie error: $errorMessage');
//                   showToast('Chewie error');
//                   return Center(
//                     child: Text(
//                       'Error loading video: $errorMessage',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   );
//                 },
//               );
//               setState(() {});
//             }).catchError((error) {
//               debugPrint('Video player initialization error: $error');
//               showToast('Video player initialization error');
//               setState(() {
//                 isPlayed = false;
//               });
//             });
//           _controllers?.addListener(() {
//             if (_controllers!.value.hasError) {
//               debugPrint(
//                   'Video playback error: ${_controllers!.value.errorDescription}');
//               showToast('Video playback error');
//               setState(() {
//                 isPlayed = false; // Fallback to image
//               });
//             }
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching category details: $e');
//       showToast("Error fetching category details");
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   void dispose() {
//     _controllers?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return BaseScreen(
//       selectedIndex: 4,
//       onItemSelected: (index) {
//         Navigator.pushNamed(context, getRouteForIndex(index));
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           scrolledUnderElevation: 0,
//           elevation: 0,
//           shadowColor: Colors.transparent,
//           backgroundColor: Colors.transparent,
//           centerTitle: true,
//           iconTheme: IconThemeData(color: Colors.white),
//           title: SizedBox(
//             width: convertFigmaToUIWidth(300, width),
//             child: Text(
//               widget.title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 height: 1.5,
//                 fontSize: convertFigmaToUIWidth(20, width),
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           flexibleSpace: Container(decoration: BoxDecoration(color: cyangreen)),
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(10),
//             child: SizedBox(),
//           ),
//         ),
//         body: RefreshIndicator(
//           onRefresh: () async {
//             setState(() {
//               isLoading = true;
//             });
//             initialPref();
//           },
//           child: isLoading
//               ? Center(child: CircularProgressIndicator(color: cyangreen))
//               : Container(
//                   height: height,
//                   width: width,
//                   decoration: BoxDecoration(
//                     color: Color.fromRGBO(204, 232, 234, 0.7),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       //----------------------------------------------//

//                       Container(
//                         decoration: BoxDecoration(
//                             color: cyangreen,
//                             borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(100),
//                                 bottomRight: Radius.circular(100))),
//                         width: double.infinity,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: width,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12)),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: isPlayed
//                                     ? SizedBox(
//                                         width: width,
//                                         height:
//                                             convertFigmaToUIWidth(198, width),
//                                         child: VideoPlayer(_controllers!))
//                                     : ClipRRect(
//                                         borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(20),
//                                             topRight: Radius.circular(20),
//                                             bottomLeft: Radius.circular(0),
//                                             bottomRight: Radius.circular(0)),
//                                         child: CachedNetworkImage(
//                                           imageUrl: categoryDetails!.bannerLink,
//                                           width: width,
//                                           height:
//                                               convertFigmaToUIWidth(198, width),
//                                           fit: BoxFit.fill,
//                                           errorWidget: (context, url, error) =>
//                                               Container(
//                                             width: width,
//                                             height: convertFigmaToUIWidth(
//                                                 198, width),
//                                             decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.only(
//                                                     topLeft:
//                                                         Radius.circular(20),
//                                                     topRight:
//                                                         Radius.circular(20)),
//                                                 color: Colors.grey.shade300),
//                                             child: Center(
//                                                 child: Icon(
//                                               Icons.error_outline,
//                                               size: convertFigmaToUIWidth(
//                                                   30, width),
//                                             )),
//                                           ),
//                                         ),
//                                       ),
//                               ),
//                             ),
//                             if (categoryDetails?.videoLink != null &&
//                                 categoryDetails!.videoLink.isNotEmpty &&
//                                 _chewieController != null)
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     isPlayed = !isPlayed;
//                                     if (isPlayed) {
//                                       _chewieController!.play();
//                                     } else {
//                                       _chewieController!.pause();
//                                     }
//                                   });
//                                 },
//                                 child: Container(
//                                   height: convertFigmaToUIWidth(47, width),
//                                   width: convertFigmaToUIWidth(47, width),
//                                   decoration: BoxDecoration(
//                                     color: const Color.fromRGBO(0, 0, 0, 0.6),
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                         color: Colors.white, width: 2),
//                                   ),
//                                   child: Icon(
//                                     isPlayed ? Icons.pause : Icons.play_arrow,
//                                     size: convertFigmaToUIWidth(25, width),
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),

//                       //----------------------------------------------//

//                       Expanded(
//                         child: ListView.separated(
//                           itemCount: categoryList.length,
//                           shrinkWrap: true,
//                           separatorBuilder: (BuildContext context, int index) {
//                             return SizedBox(
//                                 height: convertFigmaToUIWidth(14, width));
//                           },
//                           itemBuilder: (BuildContext context, int index) {
//                             return listItemsBuilder(context, index);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//         ),
//         // backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
//       ),
//     );
//   }

//   Widget listItemsBuilder(BuildContext context, int i) {
//     var width = MediaQuery.of(context).size.width;

//     bool _isNotificationIconVisible(CategoryShowListModel item) {
//       try {
//         String cleanedDate =
//             item.showDate!.replaceAll(RegExp(r'(st|nd|rd|th)'), '').trim();
//         final dateFormat = DateFormat('dd MMM yyyy');
//         final timeFormat = DateFormat('HH:mm');

//         DateTime parsedDate = dateFormat.parse(cleanedDate);
//         DateTime parsedStartTime = timeFormat.parse(item.fromDate ?? '00:00');

//         DateTime eventStartDateTime = DateTime(
//           parsedDate.year,
//           parsedDate.month,
//           parsedDate.day,
//           parsedStartTime.hour,
//           parsedStartTime.minute,
//         );

//         DateTime cutoffDateTime =
//             eventStartDateTime.subtract(Duration(minutes: 45));
//         DateTime now = DateTime.now();
//         return now.isBefore(cutoffDateTime);
//       } catch (e) {
//         print('Error in _isNotificationIconVisible: $e');
//         return false;
//       }
//     }

//     return Padding(
//       padding: EdgeInsets.only(
//         left: 15,
//         right: 15,
//         top: i == 0 ? 20 : 0,
//         bottom: categoryList.length - 1 == i ? 120 : 0,
//       ),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header Section
//             Container(
//               decoration: BoxDecoration(
//                 color: lightpink,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                 ),
//               ),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.alarm,
//                             size: convertFigmaToUIWidth(20, width),
//                             color: brownText),
//                         SizedBox(width: convertFigmaToUIWidth(4.3, width)),
//                         Text(
//                           "${categoryList[i].fromDate ?? ''} - ${categoryList[i].toDate ?? ''}",
//                           style: TextStyle(
//                             height: 1.5,
//                             fontSize: convertFigmaToUIWidth(12, width),
//                             fontWeight: FontWeight.w400,
//                             color: brownText,
//                           ),
//                         ),
//                         SizedBox(width: convertFigmaToUIWidth(11, width)),
//                         Icon(Icons.calendar_month_outlined,
//                             size: convertFigmaToUIWidth(20, width),
//                             color: brownText),
//                         SizedBox(width: convertFigmaToUIWidth(4, width)),
//                         Text(
//                           categoryList[i].showDate ?? '',
//                           style: TextStyle(
//                             height: 1.5,
//                             fontSize: convertFigmaToUIWidth(12, width),
//                             color: brownText,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         circleButton(
//                           image: sendIcon,
//                           onPress: () {
//                             String organizerId =
//                                 base64Encode(utf8.encode(widget.categoryId));
//                             String message =
//                                 "${widget.titleName}\nGet your tickets here:\nhttps://www.expogeeks.co.uk/tickets.php?organizerId=$organizerId";
//                             shareTextFrom(context, message, subject: widget.titleName);
//                           },
//                         ),
//                         SizedBox(width: convertFigmaToUIWidth(10, width)),
//                         Visibility(
//                           visible: _isNotificationIconVisible(categoryList[i]),
//                           child: circleButton(
//                             image: notificationIcon,
//                             onPress: () {
//                               String cleanedDate = categoryList[i]
//                                   .showDate!
//                                   .replaceAll(RegExp(r'(st|nd|rd|th)'), '')
//                                   .trim();
//                               DateTime parsedDate =
//                                   DateFormat('dd MMM yyyy').parse(cleanedDate);

//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return ReminderAlertBoxDialog(
//                                     eventDate: parsedDate,
//                                     eventId: categoryList[i].id!,
//                                     eventName: categoryList[i].name!,
//                                     isMeeting: false,
//                                     startTime: categoryList[i].fromDate,
//                                     showDropdown: false,
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Content Section with fixed height
//             Container(
//               width: double.infinity,
//               height: convertFigmaToUIWidth(184, width),
//               decoration: BoxDecoration(
//                 color: faintPink,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: lightpink,
//                       borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(20),
//                         bottomLeft: Radius.circular(20),
//                         bottomRight: Radius.circular(20),
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(20),
//                       ),
//                       child: CachedNetworkImage(
//                         imageUrl: categoryList[i].imageLink ?? '',
//                         fit: BoxFit.cover,
//                         errorWidget: (context, url, error) => Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.only(
//                               bottomLeft: Radius.circular(20),
//                               topRight: Radius.circular(20),
//                             ),
//                           ),
//                           child: Center(
//                             child: Icon(Icons.error_outline, size: 35),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(width: convertFigmaToUIWidth(4, width)),

//                   // Text Content
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment
//                             .spaceBetween, // This will space out the columns
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // First Column: Title and Description
//                           Expanded(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Title
//                                 Text(
//                                   categoryList[i].name ?? '',
//                                   style: TextStyle(
//                                     height: 1.5,
//                                     fontSize: convertFigmaToUIWidth(14, width),
//                                     color: Color.fromRGBO(50, 50, 50, 1),
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),

//                                 SizedBox(
//                                     height: convertFigmaToUIWidth(4, width)),

//                                 // Description
//                                 Expanded(
//                                   child: Text(
//                                     categoryList[i].description ?? '',
//                                     style: TextStyle(
//                                       height: 1.5,
//                                       fontSize:
//                                           convertFigmaToUIWidth(14, width),
//                                       color: Color.fromRGBO(50, 50, 50, 1),
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           // Second Column: Tickets section - Always at bottom
//                           constant.userType != constant.exhibitorUser
//                               ? categoryList[i].bookingRequired!.toString() ==
//                                       '0'
//                                   ? SizedBox()
//                                   : GestureDetector(
//                                       onTap: () async {
//                                         if (categoryList[i]
//                                                 .isBooked!
//                                                 .toString() ==
//                                             'false') {
//                                           if (widget.redirectLink != '' &&
//                                               widget.redirectLink.toString() !=
//                                                   'null') {
//                                             String url = widget.redirectLink;
//                                             final encodedUrl =
//                                                 Uri.encodeFull(url);
//                                             Uri uri = Uri.parse(encodedUrl);

//                                             try {
//                                               await launchUrl(uri);
//                                               Navigator.pop(context);
//                                             } catch (e) {
//                                               debugPrint(e.toString());
//                                             }
//                                           } else {
//                                             showToast(
//                                                 'Booking not available for url : ${widget.redirectLink.toString()}');
//                                           }
//                                         }
//                                       },
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             'Tickets Available: ${categoryList[i].seatsLeft}',
//                                             style: TextStyle(
//                                               height: 1.5,
//                                               fontSize: convertFigmaToUIWidth(
//                                                   10, width),
//                                               fontWeight: FontWeight.w600,
//                                               color: brownText,
//                                             ),
//                                           ),
//                                           Container(
//                                             width: convertFigmaToUIWidth(
//                                                 80, width),
//                                             height: convertFigmaToUIWidth(
//                                                 30, width),
//                                             decoration: BoxDecoration(
//                                               color: categoryList[i]
//                                                           .isBooked!
//                                                           .toString() !=
//                                                       'false'
//                                                   ? lightpink
//                                                   : white,
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 categoryList[i]
//                                                             .isBooked!
//                                                             .toString() !=
//                                                         'false'
//                                                     ? "Booked"
//                                                     : "Book Now",
//                                                 style: TextStyle(
//                                                   height: 1.5,
//                                                   fontSize:
//                                                       convertFigmaToUIWidth(
//                                                           10, width),
//                                                   fontWeight: FontWeight.w600,
//                                                   color: brownText,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                               : showMoreIndex == i ||
//                                       categoryList[i]
//                                               .bookingRequired!
//                                               .toString() ==
//                                           '0' ||
//                                       (categoryList[i].description != null &&
//                                           categoryList[i].description!.length <
//                                               101)
//                                   ? SizedBox()
//                                   : GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           showMoreIndex = i;
//                                         });
//                                       },
//                                       child: Container(
//                                         width:
//                                             convertFigmaToUIWidth(100, width),
//                                         height:
//                                             convertFigmaToUIWidth(30, width),
//                                         decoration: BoxDecoration(
//                                           color: white,
//                                           borderRadius:
//                                               BorderRadius.circular(20),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             "More info",
//                                             style: TextStyle(
//                                               height: 1.5,
//                                               fontSize: convertFigmaToUIWidth(
//                                                   10, width),
//                                               fontWeight: FontWeight.w600,
//                                               color: brownText,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   circleButton({image, onPress}) {
//     var width = MediaQuery.of(context).size.width;
//     return GestureDetector(
//       onTap: onPress,
//       child: Container(
//         height: convertFigmaToUIWidth(30, width),
//         width: convertFigmaToUIWidth(30, width),
//         padding: EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           border: Border.all(color: brownText, width: 0.5),
//           shape: BoxShape.circle,
//         ),
//         child: Image(image: AssetImage(image), color: brownText),
//       ),
//     );
//   }
// }

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/category_show_list_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/sharedwidget/reminder_alert_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:event_pro/utils/share_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../models/categoryDetails_model.dart';

// ignore: must_be_immutable
class ExtraTabsInShowsDetails extends StatefulWidget {
  String title;
  String categoryId;
  // String videoId;
  String imageId;
  String redirectLink;
  DateTime eventDate;
  String organizationId;
  String titleName;
  String startTime;

  ExtraTabsInShowsDetails({
    super.key,
    required this.redirectLink,
    required this.title,
    required this.categoryId,
    required this.imageId,
    required this.eventDate,
    required this.organizationId,
    required this.titleName,
    required this.startTime,
  });

  @override
  State<ExtraTabsInShowsDetails> createState() =>
      _ExtraTabsInShowsDetailsState();
}

class _ExtraTabsInShowsDetailsState extends State<ExtraTabsInShowsDetails> {
  List<CategoryShowListModel> categoryList = [];
  bool isLoading = true;
  bool isPlayed = false;
  VideoPlayerController? _controllers;
  int showMoreIndex = -1;

  DateTime? eventtDate;

  CategoryDetails? categoryDetails;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    // Clear existing video controllers before making new API calls
    if (_chewieController != null) {
      _chewieController?.dispose();
      _chewieController = null;
    }
    if (_controllers != null) {
      _controllers?.dispose();
      _controllers = null;
    }

    setState(() {
      isLoading = true;
      isPlayed = false; // Reset play state
      categoryDetails = null; // Clear previous category details
    });

    // Call GetCategoryShowList
    try {
      dynamic response =
          await apiValue.GetCategoryShowList(context, widget.categoryId);
      if (response != null) {
        var tempList = response as List;
        categoryList =
            tempList.map((i) => CategoryShowListModel.fromJson(i)).toList();
        print('CategoryShowList length: ${categoryList.length}');
      }
    } catch (e) {
      debugPrint('Error fetching category show list: $e');
    }
    // Call GetCategoryDetails
    try {
      dynamic response =
          await apiValue.GetCategoryDetails(context, widget.categoryId);
      if (response != null) {
        categoryDetails = CategoryDetails.fromJson(response);
        print('CategoryDetailsssss: ${categoryDetails?.videoLink}');
        if (categoryDetails?.videoLink != null &&
            categoryDetails!.videoLink.isNotEmpty) {
          _controllers = VideoPlayerController.network(
            categoryDetails!.videoLink,
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
              allowBackgroundPlayback: false,
            ),
          )..initialize().then((_) {
              _chewieController = ChewieController(
                videoPlayerController: _controllers!,
                autoPlay: false,
                looping: false,
                aspectRatio: _controllers!.value.aspectRatio,
                errorBuilder: (context, errorMessage) {
                  debugPrint('Chewie error: $errorMessage');
                  showToast('Chewie error');
                  return Center(
                    child: Text(
                      'Error loading video: $errorMessage',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              );
              setState(() {});
            }).catchError((error) {
              debugPrint('Video player initialization error: $error');
              showToast('Video player initialization error');
              setState(() {
                isPlayed = false;
              });
            });
          _controllers?.addListener(() {
            if (_controllers!.value.hasError) {
              debugPrint(
                  'Video playback error: ${_controllers!.value.errorDescription}');
              showToast('Video playback error');
              setState(() {
                isPlayed = false; // Fallback to image
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching category details: $e');
      showToast("Error fetching category details");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controllers?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // var height = MediaQuery.of(context).size.height;
    return BaseScreen(
      selectedIndex: 4,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: SizedBox(
            width: convertFigmaToUIWidth(300, width),
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                fontSize: convertFigmaToUIWidth(20, width),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          flexibleSpace: Container(decoration: BoxDecoration(color: cyangreen)),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: SizedBox(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });
            initialPref();
          },
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : Container(
                  // height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(204, 232, 234, 0.7),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //----------------------------------------------//

                      Container(
                        decoration: BoxDecoration(
                            color: cyangreen,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100))),
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: isPlayed
                                    ? SizedBox(
                                        width: width,
                                        height:
                                            convertFigmaToUIWidth(198, width),
                                        child: VideoPlayer(_controllers!))
                                    : ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                        child: CachedNetworkImage(
                                          imageUrl: categoryDetails!.bannerLink,
                                          width: width,
                                          height:
                                              convertFigmaToUIWidth(198, width),
                                          fit: BoxFit.fill,
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: width,
                                            height: convertFigmaToUIWidth(
                                                198, width),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20)),
                                                color: Colors.grey.shade300),
                                            child: Center(
                                                child: Icon(
                                              Icons.error_outline,
                                              size: convertFigmaToUIWidth(
                                                  30, width),
                                            )),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            if (categoryDetails?.videoLink != null &&
                                categoryDetails!.videoLink.isNotEmpty &&
                                _chewieController != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isPlayed = !isPlayed;
                                    if (isPlayed) {
                                      _chewieController!.play();
                                    } else {
                                      _chewieController!.pause();
                                    }
                                  });
                                },
                                child: Container(
                                  height: convertFigmaToUIWidth(47, width),
                                  width: convertFigmaToUIWidth(47, width),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: Icon(
                                    isPlayed ? Icons.pause : Icons.play_arrow,
                                    size: convertFigmaToUIWidth(25, width),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      //----------------------------------------------//

                      Expanded(
                        child: ListView.separated(
                          itemCount: categoryList.length,
                          shrinkWrap: true,
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                                height: convertFigmaToUIWidth(14, width));
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return listItemsBuilder(context, index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        // backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
      ),
    );
  }
  
  Widget listItemsBuilder(BuildContext context, int i) {
    var width = MediaQuery.of(context).size.width;

    bool _isNotificationIconVisible(CategoryShowListModel item) {
      try {
        String cleanedDate =
            item.showDate!.replaceAll(RegExp(r'(st|nd|rd|th)'), '').trim();
        final dateFormat = DateFormat('dd MMM yyyy');
        final timeFormat = DateFormat('HH:mm');

        DateTime parsedDate = dateFormat.parse(cleanedDate);
        DateTime parsedStartTime = timeFormat.parse(item.fromDate ?? '00:00');

        DateTime eventStartDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          parsedStartTime.hour,
          parsedStartTime.minute,
        );

        DateTime cutoffDateTime =
            eventStartDateTime.subtract(Duration(minutes: 45));
        DateTime now = DateTime.now();
        return now.isBefore(cutoffDateTime);
      } catch (e) {
        print('Error in _isNotificationIconVisible: $e');
        return false;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: i == 0 ? 20 : 0,
        bottom: categoryList.length - 1 == i ? 120 : 0,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                color: lightpink,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alarm,
                            size: convertFigmaToUIWidth(20, width),
                            color: brownText),
                        SizedBox(width: convertFigmaToUIWidth(4.3, width)),
                        Text(
                          "${categoryList[i].fromDate ?? ''} - ${categoryList[i].toDate ?? ''}",
                          style: TextStyle(
                            height: 1.5,
                            fontSize: convertFigmaToUIWidth(12, width),
                            fontWeight: FontWeight.w400,
                            color: brownText,
                          ),
                        ),
                        SizedBox(width: convertFigmaToUIWidth(11, width)),
                        Icon(Icons.calendar_month_outlined,
                            size: convertFigmaToUIWidth(20, width),
                            color: brownText),
                        SizedBox(width: convertFigmaToUIWidth(4, width)),
                        Text(
                          categoryList[i].showDate ?? '',
                          style: TextStyle(
                            height: 1.5,
                            fontSize: convertFigmaToUIWidth(12, width),
                            color: brownText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        circleButton(
                          image: sendIcon,
                          onPress: () {
                            String message =
                                "${widget.titleName}\nGet your tickets here:\n${ticketsUrlForShow(widget.organizationId)}";
                            shareTextFrom(context, message, subject: widget.titleName);
                          },
                        ),
                        SizedBox(width: convertFigmaToUIWidth(10, width)),
                        Visibility(
                          visible: _isNotificationIconVisible(categoryList[i]),
                          child: circleButton(
                            image: notificationIcon,
                            onPress: () {
                              String cleanedDate = categoryList[i]
                                  .showDate!
                                  .replaceAll(RegExp(r'(st|nd|rd|th)'), '')
                                  .trim();
                              DateTime parsedDate =
                                  DateFormat('dd MMM yyyy').parse(cleanedDate);

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ReminderAlertBoxDialog(
                                    eventDate: parsedDate,
                                    eventId: categoryList[i].id!,
                                    eventName: categoryList[i].name!,
                                    isMeeting: false,
                                    startTime: categoryList[i].fromDate,
                                    showDropdown: false,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content Section with fixed height
            Container(
              width: double.infinity,
              height: convertFigmaToUIWidth(184, width),
              decoration: BoxDecoration(
                color: faintPink,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: lightpink,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: categoryList[i].imageLink ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.error_outline, size: 35),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: convertFigmaToUIWidth(4, width)),

                  // Text Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Column: Title and Description
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  categoryList[i].name ?? '',
                                  style: TextStyle(
                                    height: 1.5,
                                    fontSize: convertFigmaToUIWidth(14, width),
                                    color: Color.fromRGBO(50, 50, 50, 1),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: convertFigmaToUIWidth(4, width)),

                                // Description with Read More functionality
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final textSpan = TextSpan(
                                        text: categoryList[i].description ?? '',
                                        style: TextStyle(
                                          height: 1.5,
                                          fontSize: convertFigmaToUIWidth(14, width),
                                          color: Color.fromRGBO(50, 50, 50, 1),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      );
                                      
                                      final textPainter = TextPainter(
                                        text: textSpan,
                                        maxLines: 2,
                                        // textDirection: TextDirection.ltr
                                        textDirection: Directionality.of(context),
                                      );
                                      textPainter.layout(maxWidth: constraints.maxWidth);
                                      
                                      final isTextOverflowing = textPainter.didExceedMaxLines;
                                      final description = categoryList[i].description ?? '';
                                      final hasLongDescription = description.length > 100 || isTextOverflowing;
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (showMoreIndex != i)
                                            Text(
                                              description,
                                              style: TextStyle(
                                                height: 1.5,
                                                fontSize: convertFigmaToUIWidth(14, width),
                                                color: Color.fromRGBO(50, 50, 50, 1),
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          else
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  description,
                                                  style: TextStyle(
                                                    height: 1.5,
                                                    fontSize: convertFigmaToUIWidth(14, width),
                                                    color: Color.fromRGBO(50, 50, 50, 1),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          
                                          if (hasLongDescription && showMoreIndex != i)
                                            GestureDetector(
                                              onTap: () {
                                                _showDescriptionDialog(context, description);
                                              },
                                              child: Text(
                                                'Read More',
                                                style: TextStyle(
                                                  fontSize: convertFigmaToUIWidth(12, width),
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Second Column: Tickets section - Always at bottom
                          constant.userType != constant.exhibitorUser
                              ? categoryList[i].bookingRequired!.toString() == '0'
                                  ? SizedBox()
                                  : GestureDetector(
                                      onTap: () async {
                                        if (categoryList[i].isBooked!.toString() == 'false') {
                                          if (widget.redirectLink != '' &&
                                              widget.redirectLink.toString() != 'null') {
                                            String url = widget.redirectLink;
                                            final encodedUrl = Uri.encodeFull(url);
                                            Uri uri = Uri.parse(encodedUrl);

                                            try {
                                              await launchUrl(uri);
                                              Navigator.pop(context);
                                            } catch (e) {
                                              debugPrint(e.toString());
                                            }
                                          } else {
                                            showToast('Booking not available for url : ${widget.redirectLink.toString()}');
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          // Expanded rather than spaceBetween: the
                                          // label is wider on iOS (San Francisco vs
                                          // Roboto), and an unconstrained Text in a
                                          // Row overflows instead of wrapping, so it
                                          // ran underneath the Booked/Book Now pill.
                                          Expanded(
                                            child: Text(
                                              'Tickets Available: ${categoryList[i].seatsLeft}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                height: 1.5,
                                                fontSize: convertFigmaToUIWidth(10, width),
                                                fontWeight: FontWeight.w600,
                                                color: brownText,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: convertFigmaToUIWidth(10, width)),
                                          Container(
                                            width: convertFigmaToUIWidth(80, width),
                                            height: convertFigmaToUIWidth(30, width),
                                            decoration: BoxDecoration(
                                              color: categoryList[i].isBooked!.toString() != 'false'
                                                  ? lightpink
                                                  : white,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Text(
                                                categoryList[i].isBooked!.toString() != 'false'
                                                    ? "Booked"
                                                    : "Book Now",
                                                style: TextStyle(
                                                  height: 1.5,
                                                  fontSize: convertFigmaToUIWidth(10, width),
                                                  fontWeight: FontWeight.w600,
                                                  color: brownText,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                              : showMoreIndex == i ||
                                      categoryList[i].bookingRequired!.toString() == '0' ||
                                      (categoryList[i].description != null &&
                                          categoryList[i].description!.length < 101)
                                  ? SizedBox()
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showMoreIndex = i;
                                        });
                                      },
                                      child: Container(
                                        width: convertFigmaToUIWidth(100, width),
                                        height: convertFigmaToUIWidth(30, width),
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "More info",
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: convertFigmaToUIWidth(10, width),
                                              fontWeight: FontWeight.w600,
                                              color: brownText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDescriptionDialog(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: brownText,
                  ),
                ),
                SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 14,
                        color: cyangreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  circleButton({image, onPress}) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: convertFigmaToUIWidth(30, width),
        width: convertFigmaToUIWidth(30, width),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: brownText, width: 0.5),
          shape: BoxShape.circle,
        ),
        child: Image(image: AssetImage(image), color: brownText),
      ),
    );
  }
}



