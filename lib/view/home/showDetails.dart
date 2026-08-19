import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/organization_item_details.dart';
import 'package:event_pro/models/organizer_category_list_model.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/sharedwidget/reminder_alert_box.dart';
import 'package:event_pro/view/home/showDetailTabs/exhibitor_list_screen.dart';
import 'package:event_pro/view/home/showDetailTabs/extra_tabs_inShow_details.dart';
import 'package:event_pro/view/home/showDetailTabs/floor_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:event_pro/utils/share_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:visibility_detector/visibility_detector.dart';

// ignore: must_be_immutable
class ShowDetails extends StatefulWidget {
  String titleName;
  String organizationId;
  bool isbooked;
  String startDate;
  String startTime;
  String endDate;
  String endTime;

  ShowDetails({
    super.key,
    required this.titleName,
    required this.organizationId,
    required this.isbooked,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
  });

  @override
  State<ShowDetails> createState() => _ShowDetailsState();
}

class _ShowDetailsState extends State<ShowDetails> with WidgetsBindingObserver {
  TextStyle whiteTextStyle = TextStyle(height: 1.5, color: white);
  // Anchors the iOS/iPad share sheet to the share button.
  final GlobalKey _shareButtonKey = GlobalKey();
  OrganizationItemsDetails? organizationdetails;
  bool isBooked = false;
  List<OrganizerCategoryListModel> organizerCategoryList = [];

  bool isPlayed = false;
  late VideoPlayerController _controllers;
  bool isLoading = true;
  bool isCarouselPaused = false;

  List<DateItem> dateTimeList = [];
  List<String> bookedDates = [];
  List<String> notBookedDates = [];

  int currentIndex = 0;

  DateTime parseDateWithOrdinalAndDay(String dateString) {
    // Declare cleanedDate outside the try blocks
    String cleanedDate =
        dateString.replaceAll(RegExp(r'(st|nd|rd|th)'), '').trim();

    try {
      // Try parsing with day of week
      final dateFormat = DateFormat('EEE dd MMM yyyy');
      return dateFormat.parse(cleanedDate);
    } catch (e) {
      print('Error parsing date with day: $e');

      // Fallback to parsing without day of week
      try {
        final fallbackFormat = DateFormat('dd MMM yyyy');
        return fallbackFormat.parse(cleanedDate);
      } catch (e) {
        print('Fallback parsing also failed: $e');
        throw Exception('Failed to parse date: $dateString');
      }
    }
  }

  // True when the given date is already over (before today).
  // Accepts both raw dates ('2026-08-03') and display dates ('Mon 3rd Aug 2026').
  bool isDatePast(String dateString) {
    if (dateString.trim().isEmpty) return false;

    DateTime? eventDate = DateTime.tryParse(dateString.trim());
    if (eventDate == null) {
      try {
        eventDate = parseDateWithOrdinalAndDay(dateString);
      } catch (e) {
        return false;
      }
    }

    final now = DateTime.now();
    return DateTime(eventDate.year, eventDate.month, eventDate.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  // The API sends show dates as 'Wed 04 Oct 2026', while the booked dates come
  // through as plain '2026-10-04' and render as '4th Oct 2026'. Drop the
  // leading weekday so the show-date rows read the same as the booking rows.
  String withoutWeekday(String date) {
    final parts = date.trim().split(RegExp(r'\s+'));
    if (parts.length == 4) parts.removeAt(0);
    return parts.join(' ');
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialPref();
  }

  Future<void> initialPref() async {
    organizationdetails = null;

    isBooked = false;
    organizerCategoryList = [];

    isLoading = true;

    dateTimeList = [];
    bookedDates = [];
    notBookedDates = [];

    currentIndex = 0;

    print("CALLEDD");
    dynamic response =
        await apiValue.getOrganizerDetails(context, widget.organizationId);
    if (response != null) {
      setState(() {
        isLoading = false;
        organizationdetails = OrganizationItemsDetails.fromJson(response);
        if (organizationdetails != null) {
          dateTimeList = organizationdetails?.dateList ?? [];
          isBooked = organizationdetails?.isBooked.toString() != 'false';
          bookedDates = List<String>.from(response['bookedDates'] ?? []);
          notBookedDates = List<String>.from(response['notBookedDates'] ?? []);
        }
        if (organizationdetails?.videoLink != null &&
            organizationdetails!.videoLink!.isNotEmpty) {
          _controllers = VideoPlayerController.network(
            organizationdetails!.videoLink!,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )..initialize().then((_) {
              setState(() {});
            });
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }

    dynamic organizerCategoryListResponse =
        await apiValue.getOrganizerCategoryList(context, widget.organizationId);

    if (organizerCategoryListResponse != null) {
      setState(() {
        var tempList = organizerCategoryListResponse as List;
        organizerCategoryList = tempList
            .map((i) => OrganizerCategoryListModel.fromJson(i))
            .toList();
        print(organizerCategoryList.length);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('---------------------paused---------------');
      // When app goes to background
      if ((organizationdetails?.videoLink != null &&
              organizationdetails!.videoLink!.isNotEmpty) &&
          _controllers != null &&
          _controllers.value.isInitialized &&
          _controllers.value.isPlaying) {
        _controllers.pause();
        setState(() {
          isPlayed = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      print('---------------------resumed---------------');
      // initialPref().then((_) {
      //   if (mounted) {
      //     setState(() {}); // Force a complete rebuild
      //   }
      // });
      initialPref();
      // When app comes back to foreground:
      // 1. Stop video if playing
      if ((organizationdetails?.videoLink != null &&
              organizationdetails!.videoLink!.isNotEmpty) &&
          _controllers != null &&
          _controllers.value.isInitialized &&
          _controllers.value.isPlaying) {
        _controllers.pause();
        setState(() {
          isPlayed = false;
        });
      }

      // // 2. Refresh data and rebuild the entire widget
      // initialPref().then((_) {
      //   if (mounted) {
      //     setState(() {}); // Force a complete rebuild
      //   }
      // });
    }
  }

  @override
  void dispose() {
    if ((organizationdetails?.videoLink != null &&
            organizationdetails!.videoLink!.isNotEmpty) &&
        _controllers != null &&
        _controllers.value.isInitialized) {
      _controllers.pause();
      _controllers.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Add the buildVideoPlayer() method
  Widget buildVideoPlayer() {
    var width = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controllers.value.isPlaying) {
                  _controllers.pause();
                  isPlayed = false;
                } else {
                  if (_controllers.value.position ==
                      _controllers.value.duration) {
                    _controllers.seekTo(Duration.zero);
                  }
                  _controllers.play();
                  isPlayed = true;
                }
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controllers),
                if (!isPlayed) // Show play button only when paused
                  Container(
                    height: convertFigmaToUIWidth(50, width),
                    width: convertFigmaToUIWidth(50, width),
                    decoration: BoxDecoration(
                      // yahan
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      // size: 30,
                      size: convertFigmaToUIWidth(30, width),
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isPlayed) // Show play button only when paused
          GestureDetector(
            onTap: () {
              setState(() {
                _controllers.play();
                isPlayed = true;
              });
            },
            child: Container(
              // height: 50,
              // width: 50,
              height: convertFigmaToUIWidth(50, width),
              width: convertFigmaToUIWidth(50, width),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.play_arrow,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  // String? getRedirectLinkForDate(String date) {
  //   try {
  //     // Format the input date to match the showDate format in dateList
  //     final inputDate = DateTime.parse(date);
  //     final dateFormat = DateFormat('EEE dd MMM yyyy');
  //     final formattedInputDate = dateFormat.format(inputDate);

  //     // Add the ordinal suffix (th, st, nd, rd) to match the showDate format
  //     final day = inputDate.day;
  //     String suffix = 'th';
  //     if (day % 10 == 1 && day != 11) {
  //       suffix = 'st';
  //     } else if (day % 10 == 2 && day != 12) {
  //       suffix = 'nd';
  //     } else if (day % 10 == 3 && day != 13) {
  //       suffix = 'rd';
  //     }

  //     final formattedDateWithSuffix =
  //         formattedInputDate.replaceFirst(day.toString(), '$day$suffix');

  //     // Find the matching date in dateList
  //     final matchingDate = dateTimeList.firstWhere(
  //       (dateItem) => dateItem.showDate == formattedDateWithSuffix,
  //       orElse: () => DateItem(),
  //     );

  //     return matchingDate.redirectLink;
  //   } catch (e) {
  //     print('Error finding redirect link: $e');
  //     return null;
  //   }
  // }

  String? getRedirectLinkForDate(String date) {
    try {
      // Parse the input date
      final inputDate = DateTime.parse(date);

      // Find the matching date in dateList
      for (var dateItem in dateTimeList) {
        if (dateItem.showDate == null) continue;

        try {
          // Parse the show date with ordinal suffix and day of week
          DateTime parsedShowDate =
              parseDateWithOrdinalAndDay(dateItem.showDate!);

          // Compare just the date parts (ignore time)
          if (parsedShowDate.year == inputDate.year &&
              parsedShowDate.month == inputDate.month &&
              parsedShowDate.day == inputDate.day) {
            return dateItem.redirectLink;
          }
        } catch (e) {
          print('Error parsing show date: ${dateItem.showDate} - $e');
        }
      }

      return null;
    } catch (e) {
      print('Error finding redirect link: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    String removeOrdinalSuffix(String date) {
      return date.replaceAll(RegExp(r'(st|nd|rd|th)'), '').trim();
    }

    List<DateItem> getEligibleDates(List<DateItem> dateList) {
      List<DateItem> eligibleDates = [];
      for (var dateItem in dateList) {
        final showDate = dateItem.showDate ?? '';
        final startTime = dateItem.startTime ?? '';

        if (showDate.isEmpty || startTime.isEmpty) continue;

        try {
          String cleanedShowDate = removeOrdinalSuffix(showDate);
          final dateFormat = DateFormat('EEE dd MMM yyyy');
          final timeFormat = DateFormat('HH:mm');

          DateTime parsedShowDate = dateFormat.parse(cleanedShowDate);
          DateTime parsedStartTime = timeFormat.parse(startTime);

          DateTime eventStartDateTime = DateTime(
            parsedShowDate.year,
            parsedShowDate.month,
            parsedShowDate.day,
            parsedStartTime.hour,
            parsedStartTime.minute,
          );

          DateTime cutoffDateTime =
              eventStartDateTime.subtract(Duration(minutes: 45));
          DateTime now = DateTime.now();

          if (now.isBefore(cutoffDateTime)) {
            eligibleDates.add(dateItem);
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
      return eligibleDates;
    }

    // bool _isNotificationIconVisible() {
    //   try {
    //     for (var dateItem in organizationdetails?.dateList ?? []) {
    //       final showDate = dateItem.showDate ?? '';
    //       final startTime = dateItem.startTime ?? '';

    //       if (showDate.isEmpty || startTime.isEmpty) continue;
    //       String cleanedShowDate = removeOrdinalSuffix(showDate);
    //       final dateFormat = DateFormat('EEE dd MMM yyyy');
    //       final timeFormat = DateFormat('HH:mm');

    //       DateTime parsedShowDate = dateFormat.parse(cleanedShowDate);
    //       DateTime parsedStartTime = timeFormat.parse(startTime);
    //       DateTime eventStartDateTime = DateTime(
    //         parsedShowDate.year,
    //         parsedShowDate.month,
    //         parsedShowDate.day,
    //         parsedStartTime.hour,
    //         parsedStartTime.minute,
    //       );
    //       DateTime cutoffDateTime =
    //           eventStartDateTime.subtract(Duration(minutes: 45));

    //       DateTime now = DateTime.now();
    //       if (now.isBefore(cutoffDateTime)) {
    //         return true;
    //       }
    //     }
    //     return false;
    //   } catch (e) {
    //     print('Error in _isNotificationIconVisible: $e');
    //     return false;
    //   }
    // }

    bool _isNotificationIconVisible() {
      try {
        for (var dateItem in organizationdetails?.dateList ?? []) {
          final showDate = dateItem.showDate ?? '';
          final startTime = dateItem.startTime ?? '';

          if (showDate.isEmpty || startTime.isEmpty) continue;

          try {
            // Parse the date with ordinal suffix and day of week
            DateTime parsedShowDate = parseDateWithOrdinalAndDay(showDate);
            final timeFormat = DateFormat('HH:mm');
            DateTime parsedStartTime = timeFormat.parse(startTime);

            DateTime eventStartDateTime = DateTime(
              parsedShowDate.year,
              parsedShowDate.month,
              parsedShowDate.day,
              parsedStartTime.hour,
              parsedStartTime.minute,
            );

            DateTime cutoffDateTime =
                eventStartDateTime.subtract(Duration(minutes: 45));
            DateTime now = DateTime.now();

            if (now.isBefore(cutoffDateTime)) {
              return true;
            }
          } catch (e) {
            print('Error parsing date in _isNotificationIconVisible: $e');
          }
        }
        return false;
      } catch (e) {
        print('Error in _isNotificationIconVisible: $e');
        return false;
      }
    }

    final showDate = organizationdetails?.dateList?.first.showDate ?? '';
    final dateFormat = DateFormat('EEE dd MMM yyyy');
    DateTime? eventDate;

    // if (showDate.isNotEmpty) {
    //   try {
    //     String cleanedDate = removeOrdinalSuffix(showDate);
    //     eventDate = dateFormat.parse(cleanedDate);
    //   } catch (e) {
    //     print('Error parsing date: $e');
    //   }
    // }

    if (showDate.isNotEmpty) {
      try {
        eventDate = parseDateWithOrdinalAndDay(showDate);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    String bookedDate = bookedDates.isNotEmpty ? bookedDates.first : '';
    return BaseScreen(
      selectedIndex: 4,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });
            initialPref();
          },
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Color.fromRGBO(204, 232, 234, 0.7),
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: cyangreen))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: width,
                          decoration: BoxDecoration(
                            color: cyangreen,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBar(
                                shadowColor: Colors.transparent,
                                backgroundColor: cyangreen,
                                centerTitle: true,
                                iconTheme: IconThemeData(color: Colors.white),
                                scrolledUnderElevation: 0,
                                elevation: 0,
                                title: Text(widget.titleName,
                                    style: TextStyle(
                                        fontSize:
                                            convertFigmaToUIWidth(20, width),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                              SizedBox(
                                  height: convertFigmaToUIWidth(10, width)),
                              Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Builder(
                                      builder: (context) {
                                        final images =
                                            organizationdetails?.imageList ??
                                                [];
                                        final video =
                                            organizationdetails?.videoLink;

                                        final hasImages = images.isNotEmpty;
                                        final hasVideo =
                                            video != null && video.isNotEmpty;

                                        // Total media count
                                        final mediaCount =
                                            images.length + (hasVideo ? 1 : 0);

                                        if (mediaCount <= 1) {
                                          // Show just one image or video directly (no slider)
                                          if (hasImages) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl: images.first,
                                                width: double.infinity,
                                                // height: 200,
                                                height: convertFigmaToUIWidth(
                                                    200, width),
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Icon(Icons.error, size: 30),
                                              ),
                                            );
                                          } else if (hasVideo) {
                                            return VisibilityDetector(
                                              key: Key('video-player'),
                                              onVisibilityChanged:
                                                  (visibilityInfo) {
                                                if (visibilityInfo
                                                        .visibleFraction ==
                                                    0) {
                                                  _controllers.pause();
                                                  setState(() {
                                                    isPlayed = false;
                                                  });
                                                }
                                              },
                                              child: buildVideoPlayer(),
                                            );
                                          } else {
                                            return SizedBox
                                                .shrink(); // No media to show
                                          }
                                        }

                                        // Show slider when more than one media item
                                        return CarouselSlider(
                                          items: [
                                            ...images.map((imageUrl) =>
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(
                                                      Icons.error,
                                                      size:
                                                          convertFigmaToUIWidth(
                                                              30, width),
                                                    ), //size: 30),
                                                  ),
                                                )),
                                            if (hasVideo)
                                              VisibilityDetector(
                                                key: Key('video-player'),
                                                onVisibilityChanged:
                                                    (visibilityInfo) {
                                                  if (visibilityInfo
                                                          .visibleFraction ==
                                                      0) {
                                                    _controllers.pause();
                                                    setState(() {
                                                      isPlayed = false;
                                                    });
                                                  }
                                                },
                                                child: buildVideoPlayer(),
                                              ),
                                          ],
                                          options: CarouselOptions(
                                            // height: 200,
                                            height: convertFigmaToUIWidth(
                                                200, width),
                                            enlargeCenterPage: true,
                                            autoPlay: false,
                                            aspectRatio: 16 / 9,
                                            enableInfiniteScroll: true,
                                            viewportFraction: 1.0,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                currentIndex = index;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if ((organizationdetails!.imageList != null &&
                                          organizationdetails!
                                                  .imageList!.length >
                                              1) ||
                                      (organizationdetails!.videoLink != null &&
                                          organizationdetails!
                                              .videoLink!.isNotEmpty &&
                                          organizationdetails!
                                              .imageList!.isNotEmpty))
                                    Column(
                                      children: [
                                        SizedBox(
                                            height: convertFigmaToUIWidth(
                                                10, width)),
                                        AnimatedSmoothIndicator(
                                          activeIndex: currentIndex,
                                          count: organizationdetails!
                                                  .imageList!.length +
                                              (organizationdetails!.videoLink !=
                                                          null &&
                                                      organizationdetails!
                                                          .videoLink!.isNotEmpty
                                                  ? 1
                                                  : 0),
                                          effect: ExpandingDotsEffect(
                                            dotHeight: 8,
                                            dotWidth: 8,
                                            activeDotColor: LightPinkShade,
                                            dotColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 16, top: 15, bottom: 25),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: convertFigmaToUIWidth(
                                                  430 * 0.74,
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) ??
                                              (430 * 0.74),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16),
                                                child: Text(widget.titleName,
                                                    style: TextStyle(
                                                        fontSize:
                                                            convertFigmaToUIWidth(
                                                                20, width),
                                                        color: Color.fromRGBO(
                                                            244, 244, 244, 1),
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ),
                                              SizedBox(
                                                  height: convertFigmaToUIWidth(
                                                      10, width)), //10),

                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14, top: 4),
                                                    child: Icon(
                                                      Icons.location_on,
                                                      color: Colors.white,
                                                      size:
                                                          convertFigmaToUIWidth(
                                                              15, width),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          convertFigmaToUIWidth(
                                                              6, width)),
                                                  Expanded(
                                                    child: Text(
                                                      organizationdetails
                                                              ?.location ??
                                                          '',
                                                      
                                                      style: whiteTextStyle
                                                          .copyWith(
                                                        fontSize:
                                                            convertFigmaToUIWidth(
                                                                12, width),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color
                                                            .fromRGBO(
                                                            244, 244, 244, 1),
                                                        fontFamily: "Roboto",
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Visibility(
                                              visible: eventDate != null &&
                                                  _isNotificationIconVisible(),
                                              child: circleButton(
                                                image: notificationIcon,
                                                w: width,
                                                onPress: () async {
                                                  try {
                                                    // Filter out ineligible dates
                                                    List<DateItem>
                                                        eligibleDates =
                                                        getEligibleDates(
                                                            organizationdetails!
                                                                    .dateList ??
                                                                []);

                                                    if (eligibleDates.isEmpty) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'No Reminder Available'),
                                                            content: Text(
                                                                'No eligible dates for setting a reminder.'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child:
                                                                    Text('OK'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      return;
                                                    }

                                                    // Use the first eligible date as the default selected date
                                                    String cleanedStartDate =
                                                        removeOrdinalSuffix(
                                                            eligibleDates.first
                                                                .showDate!);
                                                    final dateFormat =
                                                        DateFormat(
                                                            'EEE dd MMM yyyy');
                                                    DateTime parsedDate =
                                                        dateFormat.parse(
                                                            cleanedStartDate);

                                                    await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ReminderAlertBoxDialog(
                                                          eventDate: parsedDate,
                                                          eventId: widget
                                                              .organizationId,
                                                          eventName:
                                                              widget.titleName,
                                                          isMeeting: false,
                                                          startTime: eligibleDates
                                                              .first
                                                              .startTime!, // Use the start time of the first eligible date
                                                          dateList:
                                                              eligibleDates, // Pass only eligible dates
                                                        );
                                                      },
                                                    );
                                                  } catch (e) {
                                                    print(
                                                        'Error parsing date: $e');
                                                    await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text('Error'),
                                                          content: Text(
                                                              'Invalid date format.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: convertFigmaToUIWidth(
                                                  10, width),
                                            ),
                                            circleButton(
                                              key: _shareButtonKey,
                                              image: sendIcon,
                                              w: width,
                                              onPress: () {
                                                String message =
                                                    "${widget.titleName}\n"
                                                    "Get your tickets here:\n"
                                                    "${ticketsUrlForShow(widget.organizationId)}";

                                                shareTextFrom(
                                                    _shareButtonKey
                                                            .currentContext ??
                                                        context,
                                                    message,
                                                    subject: widget.titleName);
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                        height: convertFigmaToUIWidth(
                                            15, width)), //15),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: (dateTimeList.isEmpty)
                                          ? Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    roundedIconFilledButton(
                                                        context,
                                                        icon: Icons
                                                            .calendar_month_outlined,
                                                        text: widget.startDate),
                                                    SizedBox(
                                                      width:
                                                          convertFigmaToUIWidth(
                                                              10, width),
                                                    ),
                                                    roundedIconFilledButton(
                                                        context,
                                                        icon: Icons.alarm,
                                                        text: widget.startTime),
                                                  ],
                                                ),
                                                if (widget.endDate != '')
                                                  SizedBox(
                                                      height:
                                                          convertFigmaToUIWidth(
                                                              15, width)),
                                                if (widget.endDate != '')
                                                  Row(
                                                    children: [
                                                      roundedIconFilledButton(
                                                          context,
                                                          icon: Icons
                                                              .calendar_month_outlined,
                                                          fontsize: 12,
                                                          text: widget.endDate),
                                                      SizedBox(
                                                        width:
                                                            convertFigmaToUIWidth(
                                                                10, width),
                                                      ),
                                                      roundedIconFilledButton(
                                                          context,
                                                          icon: Icons.alarm,
                                                          fontsize: 12,
                                                          text: widget.endTime),
                                                    ],
                                                  ),
                                              ],
                                            )
                                          : ListView.separated(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: dateTimeList.length,
                                              padding: EdgeInsets.all(0),
                                              shrinkWrap: true,
                                              separatorBuilder: (BuildContext
                                                          context,
                                                      int index) =>
                                                  SizedBox(
                                                      height:
                                                          convertFigmaToUIWidth(
                                                              15, width)),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Row(
                                                  children: [
                                                    roundedFourIconsFilledButton(
                                                      context,
                                                      dateIcon: Icons
                                                          .calendar_month_outlined,
                                                      dateText: DateFormatter
                                                          .formatDayWithSuffix(
                                                              withoutWeekday(
                                                                  dateTimeList[
                                                                          index]
                                                                      .showDate
                                                                      .toString())),
                                                      timeIcon:
                                                          Icons.access_time,
                                                      timeText:
                                                          "${dateTimeList[index].startTime} - ${dateTimeList[index].endTime}",
                                                      ticketIcon: Image.asset(
                                                        ticketIcon,
                                                        color: Colors.white,
                                                        width:
                                                            convertFigmaToUIWidth(
                                                                30, width),
                                                        height:
                                                            convertFigmaToUIWidth(
                                                                30, width),
                                                      ),
                                                      redirectLink:
                                                          dateTimeList[index]
                                                              .redirectLink
                                                              .toString(),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: convertFigmaToUIWidth(60, width) ?? 60),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: convertFigmaToUIWidth(24, width)),
                              Container(
                                height: convertFigmaToUIWidth(118, width),
                                alignment: Alignment.center,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing:
                                        convertFigmaToUIWidth(20, width) ?? 10,
                                    children: [
                                      Container(
                                        // color: Colors.green,
                                        width: convertFigmaToUIWidth(74, width),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push<void>(
                                                  context,
                                                  MaterialPageRoute<void>(
                                                    builder: (BuildContext
                                                            context) =>
                                                        FloorPlanScreen(
                                                      redirectLink:
                                                          organizationdetails!
                                                              .redirectLink
                                                              .toString(),
                                                      organizationId:
                                                          widget.organizationId,
                                                      isBooked:
                                                          organizationdetails!
                                                                  .isBooked
                                                                  .toString() !=
                                                              'false',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    convertFigmaToUIWidth(
                                                            10, width) ??
                                                        10),
                                                height: convertFigmaToUIWidth(
                                                    73.01, width),
                                                width: convertFigmaToUIWidth(
                                                    74, width),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      style: BorderStyle.solid,
                                                      color: boldpink,
                                                      width: 2),
                                                ),
                                                child: Image(
                                                    image: AssetImage(
                                                      floorPlanIcon,
                                                    ),
                                                    height:
                                                        convertFigmaToUIWidth(
                                                            38, width),
                                                    width:
                                                        convertFigmaToUIWidth(
                                                            38, width)),
                                              ),
                                            ),
                                            SizedBox(
                                                height: convertFigmaToUIWidth(
                                                    12.9, width)),
                                            Text('FLOOR PLAN',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize:
                                                        convertFigmaToUIWidth(
                                                            12, width),
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(
                                                        85, 85, 85, 1)))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: convertFigmaToUIWidth(74, width),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push<void>(
                                                  context,
                                                  MaterialPageRoute<void>(
                                                    builder: (BuildContext
                                                            context) =>
                                                        ExhibitorListingScreen(
                                                      organizationId:
                                                          widget.organizationId,
                                                      catId: '',
                                                      isBooked:
                                                          organizationdetails!
                                                                  .isBooked
                                                                  .toString() !=
                                                              'false',
                                                      title: 'Exhibitors',
                                                      showName: organizationdetails!.showName.toString(),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    convertFigmaToUIWidth(
                                                            10, width) ??
                                                        10),
                                                height: convertFigmaToUIWidth(
                                                    73.01, width),
                                                width: convertFigmaToUIWidth(
                                                    74, width),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      style: BorderStyle.solid,
                                                      color: boldpink,
                                                      width: 2),
                                                ),
                                                child: Image(
                                                    image: AssetImage(
                                                        exhibitorsIcon),
                                                    height:
                                                        convertFigmaToUIWidth(
                                                            38, width),
                                                    width:
                                                        convertFigmaToUIWidth(
                                                            38, width)),
                                              ),
                                            ),
                                            SizedBox(
                                                height: convertFigmaToUIWidth(
                                                    12.99, width)),
                                            Text('EXHIBITOR',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize:
                                                        convertFigmaToUIWidth(
                                                            12, width),
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(
                                                        85, 85, 85, 1)))
                                          ],
                                        ),
                                      ),
                                      ListView.separated(
                                        itemCount: organizerCategoryList.length,
                                        scrollDirection: Axis.horizontal,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(width: 03);
                                        },
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            width: convertFigmaToUIWidth(
                                                74, width),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    final dateFormat =
                                                        DateFormat(
                                                            'EEE dd MMM yyyy');
                                                    String cleanedStartDate = widget
                                                        .startDate
                                                        .replaceAll(
                                                            RegExp(
                                                                r'(st|nd|rd|th)'),
                                                            '')
                                                        .trim();

                                                    try {
                                                      DateTime parsedDate =
                                                          dateFormat.parse(
                                                              cleanedStartDate);

                                                      Navigator.push<void>(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ExtraTabsInShowsDetails(
                                                            redirectLink:
                                                                organizationdetails!
                                                                    .redirectLink
                                                                    .toString(),
                                                            title: organizerCategoryList[
                                                                        index]
                                                                    .categoryName ??
                                                                '',
                                                            categoryId:
                                                                organizerCategoryList[
                                                                            index]
                                                                        .id ??
                                                                    '',
                                                            // videoId:
                                                            //     organizerCategoryList[
                                                            //                 index]
                                                            //             .videoLink ??
                                                            //         '',
                                                            imageId: organizerCategoryList[
                                                                        index]
                                                                    .bannerLink ??
                                                                '',
                                                            eventDate:
                                                                parsedDate,
                                                            organizationId: widget
                                                                .organizationId,
                                                            titleName: widget
                                                                .titleName,
                                                            startTime: widget
                                                                .startTime,
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      print(
                                                          'Error parsing date: $e');
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        convertFigmaToUIWidth(
                                                                10, width) ??
                                                            10),
                                                    height:
                                                        convertFigmaToUIWidth(
                                                            73.01, width),
                                                    width:
                                                        convertFigmaToUIWidth(
                                                            74, width),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          style:
                                                              BorderStyle.solid,
                                                          color: boldpink,
                                                          width: 2),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(20),
                                                              bottomLeft: Radius
                                                                  .circular(0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          0)),
                                                      child: CachedNetworkImage(
                                                          imageUrl:
                                                              organizerCategoryList[
                                                                          index]
                                                                      .imageLink ??
                                                                  '',
                                                          height:
                                                              convertFigmaToUIWidth(
                                                                  38, width),
                                                          width:
                                                              convertFigmaToUIWidth(
                                                                  38, width)),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height:
                                                        convertFigmaToUIWidth(
                                                            12.99, width)),
                                                Text(
                                                  organizerCategoryList[index]
                                                      .categoryName
                                                      .toString()
                                                      .toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize:
                                                        convertFigmaToUIWidth(
                                                            12, width),
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromRGBO(
                                                        85, 85, 85, 1),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(
                                  height: convertFigmaToUIWidth(24, width)),

                              if (organizationdetails!.description != null &&
                                  organizationdetails!.description != '')
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 34),
                                  child: Center(
                                      // description
                                    child: Text(
                                      textAlign: TextAlign.left,
                                      organizationdetails!.description ?? '',
                                      style: TextStyle(
                                          height: 1.5,
                                          fontSize:
                                              convertFigmaToUIWidth(14, width),
                                          color: Color.fromRGBO(85, 85, 85, 1),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Roboto"),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                  height: convertFigmaToUIWidth(10, width)),
                              if (organizationdetails!.description != null &&
                                  organizationdetails!.description != '')
                                SizedBox(
                                    height: convertFigmaToUIWidth(15, width)),
                              if (isBooked)
                                bookedDates.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Container(
                                              height: convertFigmaToUIWidth(
                                                  1, width),
                                              width: double.infinity,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                              height: convertFigmaToUIWidth(
                                                  10, width)),
                                          Text("BOOKINGS",
                                              style: TextStyle(
                                                  fontSize:
                                                      convertFigmaToUIWidth(
                                                          16, width),
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromRGBO(
                                                      85, 85, 85, 1))),
                                          SizedBox(
                                              height: convertFigmaToUIWidth(
                                                  5, width)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Column(
                                              children: List.generate(
                                                  bookedDates.length, (index) {
                                                // Bookings for dates already
                                                // over are ticked off
                                                final bool isBookingOver =
                                                    isDatePast(
                                                        bookedDates[index]);

                                                // Exhibitors only get the
                                                // ticket action when there are
                                                // still unbooked dates left
                                                final bool showTicket =
                                                    constant.userType ==
                                                            constant
                                                                .exhibitorUser
                                                        ? notBookedDates
                                                            .isNotEmpty
                                                        : true;

                                                return bookingRowCard(
                                                  context,
                                                  dateText: DateFormatter
                                                      .formatDayWithSuffix(
                                                          bookedDates[index]),
                                                  timeText:
                                                      "${dateTimeList[index].startTime} - ${dateTimeList[index].endTime}",
                                                  isOver: isBookingOver,
                                                  showTicket: showTicket,
                                                );
                                              }),
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(
                                        height:
                                            convertFigmaToUIWidth(50, width),
                                        width: double.infinity,
                                        decoration:
                                            BoxDecoration(color: lightpink),
                                        child: Center(
                                          child: Text(
                                            "No booked date available",
                                            style: TextStyle(
                                              fontSize: convertFigmaToUIWidth(
                                                  12, width),
                                              color: Color.fromRGBO(
                                                  100, 76, 76, 1),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                              // SizedBox(
                              //   height: convertFigmaToUIWidth(30, width),
                              // ),
                              SizedBox(
                                height: convertFigmaToUIWidth(200, width),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget roundedIconFilledButton(context, {icon, text, fontsize}) {
    var width = MediaQuery.of(context).size.width;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.only(
          top: convertFigmaToUIWidth(10, width) ?? 10,
          bottom: convertFigmaToUIWidth(10, width) ?? 10,
          left: convertFigmaToUIWidth(15, width) ?? 15,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: white, size: convertFigmaToUIWidth(40, width)),
            SizedBox(width: convertFigmaToUIWidth(15, width)),
            Text(text,
                style: whiteTextStyle.copyWith(
                    fontSize: convertFigmaToUIWidth(fontsize ?? 14, width),
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget roundedFourIconsFilledButton(
    BuildContext context, {
    required IconData dateIcon,
    required String dateText,
    required IconData timeIcon,
    required String timeText,
    required Widget ticketIcon,
    required String redirectLink,
  }) {
    double width = MediaQuery.of(context).size.width;

    // Dates already over are only greyed out - the fade carries the meaning on
    // its own, without a label or a strike through
    final bool isExpired = isDatePast(dateText);
    final Color contentColor =
        isExpired ? Colors.white.withOpacity(0.5) : Colors.white;

    return GestureDetector(
      onTap: () async {
        debugPrint('CLICKED');
        // Check if the date is in the past
        if (isExpired) {
          showToast("This event date is expired.");
          return;
        }
        if (constant.userType == constant.visitorUser) {
          if (redirectLink.isNotEmpty && redirectLink != 'null') {
            await sharingOnTap(redirectLink);
          } else {
            showToast('Booking not available for this date');
          }
        }
      },
      child: Container(
        width: convertFigmaToUIWidth(390, width),
        padding: EdgeInsets.symmetric(
          vertical: convertFigmaToUIWidth(10, width) ?? 10,
          horizontal: convertFigmaToUIWidth(12, width) ?? 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- Date Section ---
              Row(
                children: [
                  Icon(dateIcon,
                      color: contentColor,
                      size: convertFigmaToUIWidth(20, width)),
                  SizedBox(width: convertFigmaToUIWidth(12, width) ?? 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: convertFigmaToUIWidth(150, width) ?? 150),
                    child: Text(
                      dateText,
                      overflow: TextOverflow.ellipsis,
                      style: whiteTextStyle.copyWith(
                        fontSize: convertFigmaToUIWidth(14, width),
                        color: contentColor,
                      ),
                    ),
                  ),
                ],
              ),

              // --- Vertical Divider ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: VerticalDivider(
                  width: convertFigmaToUIWidth(2, width),
                  thickness: 1.1,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),

              // --- Time Section ---
              Row(
                children: [
                  Icon(timeIcon,
                      color: contentColor,
                      size: convertFigmaToUIWidth(20, width)),
                  SizedBox(width: convertFigmaToUIWidth(12, width) ?? 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: convertFigmaToUIWidth(150, width) ?? 150),
                    child: Text(
                      timeText,
                      overflow: TextOverflow.ellipsis,
                      style: whiteTextStyle.copyWith(
                        fontSize: convertFigmaToUIWidth(14, width),
                        color: contentColor,
                      ),
                    ),
                  ),
                ],
              ),

              // --- Ticket Section (NO divider) ---
              // a day that has passed just fades out - no label, no strike
              // through; the ticket action belongs to visitors on live days only
              if (!isExpired && constant.userType == constant.visitorUser)
                Row(
                  children: [
                    SizedBox(width: convertFigmaToUIWidth(12, width) ?? 12),
                    ticketIcon,
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Booking row — same layout/metrics as roundedFourIconsFilledButton
  // (date | divider | time | ticket), only the colours differ because this
  // card sits on the white section instead of the banner.
  Widget bookingRowCard(
    BuildContext context, {
    required String dateText,
    required String timeText,
    required bool isOver,
    required bool showTicket,
  }) {
    double width = MediaQuery.of(context).size.width;
    const Color bookingAccent = Color(0xFF008C8C);
    final Color contentColor = isOver ? Colors.grey : textColor;

    return Container(
      width: convertFigmaToUIWidth(390, width),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(
        vertical: convertFigmaToUIWidth(10, width) ?? 10,
        horizontal: convertFigmaToUIWidth(12, width) ?? 12,
      ),
      decoration: BoxDecoration(
        color: isOver
            ? Color.fromRGBO(230, 230, 230, 0.7)
            : Color.fromRGBO(204, 232, 234, 0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- Date Section ---
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined,
                      color: contentColor,
                      size: convertFigmaToUIWidth(20, width)),
                  SizedBox(width: convertFigmaToUIWidth(12, width) ?? 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: convertFigmaToUIWidth(150, width) ?? 150),
                    child: Text(
                      dateText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: convertFigmaToUIWidth(14, width),
                        fontWeight: FontWeight.w400,
                        color: contentColor,
                      ),
                    ),
                  ),
                ],
              ),

              // --- Vertical Divider ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: VerticalDivider(
                  width: convertFigmaToUIWidth(2, width),
                  thickness: 1.1,
                  color: contentColor.withOpacity(0.5),
                ),
              ),

              // --- Time Section ---
              Row(
                children: [
                  Icon(Icons.access_time,
                      color: contentColor,
                      size: convertFigmaToUIWidth(20, width)),
                  SizedBox(width: convertFigmaToUIWidth(12, width) ?? 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: convertFigmaToUIWidth(150, width) ?? 150),
                    child: Text(
                      timeText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: convertFigmaToUIWidth(14, width),
                        fontWeight: FontWeight.w400,
                        color: contentColor,
                      ),
                    ),
                  ),
                ],
              ),

              // --- Ticket Section (NO divider) ---
              // a booking whose day has passed just fades out - no label, no
              // strike through
              if (!isOver && showTicket)
                Row(
                  children: [
                    SizedBox(width: convertFigmaToUIWidth(12, width) ?? 12),
                    Image.asset(
                      ticketIcon,
                      color: bookingAccent,
                      width: convertFigmaToUIWidth(30, width),
                      height: convertFigmaToUIWidth(30, width),
                    ),
                  ],
                ),
            ],
          ),
        ),
    );
  }

  circleButton({image, onPress, w, Key? key}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        key: key,
        height: convertFigmaToUIWidth(34, w),
        width: convertFigmaToUIWidth(34, w),
        padding: EdgeInsets.all(convertFigmaToUIWidth(6, w) ?? 6),
        decoration: BoxDecoration(
            border: Border.all(color: white, width: 1), shape: BoxShape.circle),
        child: Image(image: AssetImage(image)),
      ),
    );
  }
}
