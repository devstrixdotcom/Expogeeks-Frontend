import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/exhibitor_details_model.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/sharedwidget/reminder_alert_box.dart';
import 'package:event_pro/view/home/exhibitorDetail/offers.dart';
import 'package:event_pro/view/menuScreens/visitor/request_meeting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:event_pro/utils/share_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../models/organization_item_details.dart';
import '../../../sharedwidget/customProgressDialog.dart';

class ExhibitorDetailsScreen extends StatefulWidget {
  String titleName;
  String exhibitorId;
  bool isBooked;
  String? showName;

  /// Exhibition (show) id this exhibitor was opened from, used to build the
  /// shared ticket link. Null/empty when the caller doesn't know the show
  /// (e.g. the favourites list), in which case the share falls back to the
  /// site home.
  String? exhibitionId;

  ExhibitorDetailsScreen({
    super.key,
    required this.isBooked,
    required this.titleName,
    required this.exhibitorId,
    this.showName,
    this.exhibitionId,
  });

  @override
  State<ExhibitorDetailsScreen> createState() => _ExhibitorDetailsScreenState();
}

class _ExhibitorDetailsScreenState extends State<ExhibitorDetailsScreen>
    with WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  ExhibitorDetailsModel? exhibitorDetails;
  OrganizationItemsDetails? organizationItemsDetails;
  bool isPlayed = false;
  VideoPlayerController? _controllers;
  bool _controllerInitialized = false;
  bool isVisible = true;
  bool isLoading = true;
  bool isFav = false;
  bool isBooked = false;
  bool isbuttonSharing = false;

  late PermissionStatus status;
  Directory? downloadDirectory;
  var downloadFolder;
  List<Permission> permissions = [Permission.photos, Permission.mediaLibrary];

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
    _initializeNotifications();
    initialPref(true);
  }

  // @override
  // void dispose() {
  //   if (_controllers != null && _controllers.value.isInitialized) {
  //     _controllers.dispose();
  //   }
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }
  @override
  void dispose() {
    _controllers?.dispose(); // Use null-aware operator
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.paused) {
  //     if (_controllers?.value.isInitialized ?? false) {
  //       _controllers?.pause();
  //     }
  //   } else if (state == AppLifecycleState.resumed) {
  //     if (_controllers?.value.isInitialized ?? false && !isPlayed) {
  //       _controllers?.play();
  //     }
  //   }
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      if (_controllers?.value.isInitialized ?? false) {
        _controllers?.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if ((_controllers?.value.isInitialized ?? false) && !isPlayed) {
        _controllers?.play();
      }
    }
  }

  initialPref(bool isload) async {
    if (isload) {
      setState(() {
        isLoading = true;
      });
    }
    dynamic response =
        await apiValue.getExhibitorDetails(context, widget.exhibitorId);
    if (response != null) {
      setState(() {
        isLoading = false;
        exhibitorDetails = ExhibitorDetailsModel.fromJson(response);
        isFav = exhibitorDetails!.isFavourite.toString() == '1' ? true : false;
        isBooked = exhibitorDetails!.isBooked.toString() == '1' ? true : false;
        // if (exhibitorDetails != null && exhibitorDetails!.videoLink != '') {
        //   String videoURL = exhibitorDetails!.videoLink ?? '';
        //   _controllers = VideoPlayerController.networkUrl(Uri.parse(videoURL))
        //     ..initialize().then((value) {
        //       setState(() {});
        //     });
        // }
        if (exhibitorDetails != null &&
            exhibitorDetails!.videoLink != null &&
            exhibitorDetails!.videoLink!.isNotEmpty) {
          _controllers = VideoPlayerController.networkUrl(
              Uri.parse(exhibitorDetails!.videoLink!))
            ..initialize().then((_) {
              setState(() {
                _controllerInitialized = true;
              });
            });
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> downloadCatalogAndNotify(
  //     String url, BuildContext context) async {
  //   PermissionStatus status = await Permission.storage.request();

  //   if (Platform.isAndroid) {
  //     final androidInfo = await DeviceInfoPlugin().androidInfo;
  //     if (androidInfo.version.sdkInt >= 30) {
  //       status = await Permission.manageExternalStorage.request();
  //     }
  //   }

  //   if (status.isGranted) {
  //     String? path;
  //     final ProgressDialog pr = ProgressDialog(context: context);
  //     pr.show(
  //       max: 100,
  //       msg: 'Downloading, please wait...',
  //       msgMaxLines: 2,
  //       msgTextAlign: TextAlign.center,
  //       valueColor: Colors.black,
  //       progressValueColor: Colors.blue,
  //       hideValue: true,
  //     );

  //     if (Platform.isAndroid) {
  //       path = '/storage/emulated/0/Download';
  //     } else {
  //       path = (await getApplicationDocumentsDirectory()).path;
  //     }

  //     if (path != null) {
  //       try {
  //         String fileName = url.split('/').last;
  //         String savePath = '$path/$fileName';
  //         await Dio().download(
  //           url,
  //           savePath,
  //           onReceiveProgress: (received, total) async {
  //             if (total != -1) {
  //               int progress = (((received / total) * 100).toInt());
  //               pr.update(value: progress);
  //               if (progress == 100) {
  //                 await Future.delayed(
  //                     Duration(milliseconds: 50)); // Small delay
  //                 pr.close();
  //                 _showDownloadCompleteNotification(savePath);
  //                 await OpenFile.open(savePath);
  //               }
  //             }
  //           },
  //         );

  //         print("File downloaded to $savePath");
  //         pr.close();
  //         // _showDownloadCompleteNotification(savePath);
  //       } catch (e) {
  //         pr.close();
  //         print("Error during file download: $e");
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Error during download: $e')),
  //         );
  //       }
  //     } else {
  //       pr.close();
  //       print("Error: Unable to determine storage path.");
  //     }
  //   } else {
  //     print("Permission denied.");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Storage permission denied.')),
  //     );
  //   }
  // }
  Future<void> downloadCatalogAndNotify(
      String url, BuildContext context) async {
    PermissionStatus status = await Permission.storage.request();

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        status = await Permission.manageExternalStorage.request();
      }
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
      return;
    }

    String? path;
    if (Platform.isAndroid) {
      path = '/storage/emulated/0/Download';
    } else {
      path = (await getApplicationDocumentsDirectory()).path;
    }

    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine storage path.')),
      );
      return;
    }

    String fileName = url.split('/').last;
    String savePath = '$path/$fileName';

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CustomProgressDialog(),
    );

    try {
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          // You can log progress here if needed, but not shown in UI
        },
      );

      Navigator.of(context).pop(); // Close loading dialog
      // _showDownloadCompleteNotification(savePath);
      await OpenFile.open(savePath);
    } catch (e) {
      Navigator.of(context).pop(); // Close dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during download: $e')),
      );
    }
  }

  void _showDownloadCompleteNotification(String filePath) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'download_channel',
      'Download Notifications',
      channelDescription: 'Notifications for download status',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Download Complete',
      'Tap to open the file',
      platformDetails,
      payload: filePath,
    );
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification);
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    final String? payload = response.payload;

    if (payload != null) {
      final filePath = payload;

      final file = File(filePath);
      if (await file.exists()) {
        await OpenFile.open(filePath);
      }
    }
  }

  // bool isShowReminder(String dateValue) {
  //   final dateFormat = DateFormat('dd MMM yyyy');
  //   DateTime now = DateTime.now();
  //   String date = dateValue;
  //   String cleanedDate = date.replaceAll(RegExp(r'(st|nd|rd|th)'), '');
  //   DateTime parsedDate = dateFormat.parse(cleanedDate);
  //   return now.isBefore(parsedDate);
  // }

  bool isShowReminder(String? dateValue) {
    if (dateValue == null || dateValue.isEmpty) return false;

    try {
      final dateFormat = DateFormat('dd MMM yyyy');
      DateTime now = DateTime.now();
      String cleanedDate = dateValue.replaceAll(RegExp(r'(st|nd|rd|th)'), '');
      DateTime parsedDate = dateFormat.parse(cleanedDate);
      return now.isBefore(parsedDate);
    } catch (e) {
      print('Error parsing date: $e');
      return false;
    }
  }

  // Add pull-to-refresh handler
  Future<void> _onRefresh() async {
    await initialPref(true);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    List<String> meetingDates = exhibitorDetails?.meetingList?.map((meeting) {
          return DateFormatter.formatToDatabaseDate(meeting.meetingDate ?? '');
        }).toList() ??
        [];

    List<String> bookedDates = exhibitorDetails?.bookedDates ?? [];
    bool isLastBookedDatePast(String dateStr) {
      final lastDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      return lastDate.isBefore(DateTime(now.year, now.month, now.day));
    }

    bool shouldShowRequestMeeting = bookedDates.isNotEmpty &&
        !isLastBookedDatePast(bookedDates.last) &&
        bookedDates.any((date) => !meetingDates.contains(date));

    return BaseScreen(
      selectedIndex: 4,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(204, 232, 234, 0.96),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: cyangreen,
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    width: width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                                title: Text(
                                  widget.titleName,
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(20, width),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 10),
                              VisibilityDetector(
                                key: Key('video-player'),
                                onVisibilityChanged: (visibilityInfo) {
                                  if (visibilityInfo.visibleFraction == 0 &&
                                      _controllers != null &&
                                      _controllers!.value.isInitialized) {
                                    _controllers!.pause();
                                    setState(() {
                                      isPlayed = false;
                                    });
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      
                                      height: convertFigmaToUIWidth(200, width),
                                      width: width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_controllers == null ||
                                                !_controllers!
                                                    .value.isInitialized) {
                                              return;
                                            }
                                            setState(() {
                                              if (_controllers!
                                                  .value.isPlaying) {
                                                _controllers!.pause();
                                                isPlayed = false;
                                              } else {
                                                if (_controllers!
                                                        .value.position ==
                                                    _controllers!
                                                        .value.duration) {
                                                  _controllers!
                                                      .seekTo(Duration.zero);
                                                }
                                                _controllers!.play();
                                                isPlayed = true;
                                              }
                                            });
                                          },
                                          child: (isPlayed &&
                                                  _controllers != null &&
                                                  _controllers!
                                                      .value.isInitialized)
                                              ? SizedBox(
                                                  child: VideoPlayer(
                                                      _controllers!))
                                              : CachedNetworkImage(
                                                  imageUrl: exhibitorDetails
                                                          ?.imageLink ??
                                                      '',
                                                  width: width,
                                                  fit: BoxFit.contain,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    width: width,
                                                    
                                                    height:
                                                        convertFigmaToUIWidth(
                                                            20, width),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    child: Center(
                                                        child: Icon(
                                                            Icons.error_outline,
                                                            size:
                                                                convertFigmaToUIWidth(
                                                                    45,
                                                                    width))),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    if (!isPlayed &&
                                        exhibitorDetails != null &&
                                        exhibitorDetails!.videoLink != null &&
                                        exhibitorDetails!
                                            .videoLink!.isNotEmpty &&
                                        _controllers != null &&
                                        _controllers!.value.isInitialized)
                                      GestureDetector(
                                        onTap: () {
                                          if (_controllers == null ||
                                              !_controllers!
                                                  .value.isInitialized) {
                                            return;
                                          }
                                          setState(() {
                                            _controllers!.play();
                                            isPlayed = true;
                                          });
                                        },
                                        child: Container(
                                          // height: 40,
                                          // width: 40,
                                          height:
                                              convertFigmaToUIWidth(40, width),
                                          width:
                                              convertFigmaToUIWidth(40, width),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(0, 0, 0, 0.6),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                          child: Icon(
                                            Icons.play_arrow,
                                            // size: 20,
                                            size: convertFigmaToUIWidth(
                                                20, width),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (constant.userType != constant.exhibitorUser) 
                                    Positioned(
                                      // right: 15,
                                      // top: 15,
                                      right: convertFigmaToUIWidth(15, width),
                                      top: convertFigmaToUIWidth(15, width),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (!isFav) {
                                            await apiValue
                                                .addExhibitorFavourite(
                                                    context, widget.exhibitorId)
                                                .then((value) {
                                              showToast(
                                                  '${exhibitorDetails!.name} added to Favourite');
                                              initialPref(false);
                                            });
                                          } else {
                                            await apiValue
                                                .removeExhibitorFavourite(
                                                    context, widget.exhibitorId)
                                                .then((value) {
                                              showToast(
                                                  '${exhibitorDetails!.name} removed from Favourite');
                                              initialPref(false);
                                            });
                                          }
                                        },
                                        child: Container(
                                          // height: 32,
                                          // width: 32,
                                          height:
                                              convertFigmaToUIWidth(32, width),
                                          width:
                                              convertFigmaToUIWidth(32, width),
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            // size: 13,
                                            size: convertFigmaToUIWidth(
                                                13, width),
                                            color: isFav
                                                ? Color.fromRGBO(
                                                    255, 174, 176, 1)
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // title and location section

                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 11),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                exhibitorDetails!.name ?? '',
                                                style: TextStyle(
                                                    fontSize:
                                                        convertFigmaToUIWidth(
                                                            20, width),
                                                    color: Color.fromRGBO(
                                                        244, 244, 244, 1),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Text(
                                                exhibitorDetails!.category ??
                                                    '',
                                                style: TextStyle(
                                                    fontSize:
                                                        convertFigmaToUIWidth(
                                                            14, width),
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                    height: 1.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () => sendingMails(
                                                    exhibitorDetails!.email ??
                                                        ''),
                                                child: Container(
                                                  height: convertFigmaToUIWidth(
                                                      30, width),
                                                  width: convertFigmaToUIWidth(
                                                      30, width),
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: white,
                                                          width: 1),
                                                      shape: BoxShape.circle),
                                                  child: Center(
                                                      child: Icon(
                                                    CupertinoIcons.mail,
                                                    color: Colors.white,
                                                    size: convertFigmaToUIWidth(
                                                        14, width),
                                                  )),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: convertFigmaToUIWidth(
                                                      10, width)),
                                              // circleButton(
                                              //   image: whatsappIcon,
                                              //   w: width,
                                              //   onPress: () {
                                              //     String message =
                                              //         "*${widget.titleName}*\n\n"
                                              //         "🎟 Get your tickets here: 👇\n"
                                              //         "🔗 https://api.whatsapp.com/send/?phone=${exhibitorDetails!.whatsapp_no ?? ''}&text=Hy&type=phone_number&app_absent=0'";

                                              //     Share.share(
                                              //       message,
                                              //     );
                                              //   },
                                              // ),

                                              circleButton(
                                                  image: whatsappIcon,
                                                  w: width,
                                                  onPress: () => openWhatsApp(
                                                      exhibitorDetails!
                                                          .whatsapp_no)),
                                              SizedBox(
                                                  width: convertFigmaToUIWidth(
                                                      10, width)),
                                              circleButton(
                                                image: instaIcon,
                                                w: width,
                                                // onPress: () {
                                                //   String message =
                                                //       "*${widget.titleName}*\n\n"
                                                //       "🎟 Get your tickets here: 👇\n"
                                                //       "🔗 ${exhibitorDetails!.instagram_link}";

                                                //   Share.share(
                                                //     message,
                                                //   );
                                                // },

                                                // onPress: () => sharingOnTap(
                                                //     "${exhibitorDetails!.instagram_link}"),

                                                onPress: () => openInstagram(
                                                    exhibitorDetails!
                                                        .instagram_link),
                                              ),
                                              SizedBox(
                                                  width: convertFigmaToUIWidth(
                                                      10, width)),
                                              circleButton(
                                                image: sendIcon,
                                                w: width,
                                                onPress: () {
                                                  String message =
                                                      // "*${widget.titleName}*\n"
                                                      // "🎟 Get your tickets here: 👇\n "
                                                      "Visit ${widget.titleName} at ${widget.showName}:\n"
                                                      "${ticketsUrlForShow(widget.exhibitionId)}";

                                                  shareTextFrom(context, message,
                                                      subject: exhibitorDetails!
                                                          .name);
                                                },
                                              ),
                                              SizedBox(
                                                  width: convertFigmaToUIWidth(
                                                      5, width)),
                                              PopupMenuButton<String>(
                                                offset: Offset(-7, 30),
                                                color: Colors.white,
                                                elevation: 3,
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        convertFigmaToUIWidth(
                                                                200, width) ??
                                                            200,
                                                    minWidth:
                                                        convertFigmaToUIWidth(
                                                                200, width) ??
                                                            200),
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                  _buildPopupMenuItem(
                                                      'Whatsapp',
                                                      'whatsapp',
                                                      context),
                                                  _buildPopupMenuDivider(),
                                                  _buildPopupMenuItem(
                                                      'Instagram',
                                                      'insta',
                                                      context),
                                                  _buildPopupMenuDivider(),
                                                  _buildPopupMenuItem('Offers',
                                                      'offers', context),
                                                  _buildPopupMenuDivider(),
                                                  if (exhibitorDetails!
                                                              .pdfLink !=
                                                          null &&
                                                      exhibitorDetails!
                                                              .pdfLink !=
                                                          '')
                                                    _buildPopupMenuItem(
                                                        'Download catalogue',
                                                        'catalogue',
                                                        context),
                                                  if (exhibitorDetails!
                                                              .pdfLink !=
                                                          null &&
                                                      exhibitorDetails!
                                                              .pdfLink !=
                                                          '')
                                                    _buildPopupMenuDivider(),
                                                  _buildPopupMenuItem('Share',
                                                      'share', context),
                                                  if (constant.userType !=
                                                      constant.exhibitorUser)
                                                    _buildPopupMenuDivider(),
                                                  if (constant.userType !=
                                                          constant
                                                              .exhibitorUser &&
                                                      !isFav)
                                                    _buildPopupMenuItem(
                                                        'Add to favorites',
                                                        'fav',
                                                        context),
                                                  if (constant.userType !=
                                                          constant
                                                              .exhibitorUser &&
                                                      !isFav)
                                                    _buildPopupMenuDivider(),
                                                  if (constant.userType !=
                                                          constant
                                                              .exhibitorUser &&
                                                      exhibitorDetails!
                                                              .isMeetingRequested
                                                              .toString() ==
                                                          '1' &&
                                                      isShowReminder(
                                                          exhibitorDetails
                                                                  ?.meetingDate ??
                                                              ''))
                                                    _buildPopupMenuItem(
                                                        'Set reminder notifications',
                                                        'reminder',
                                                        context),
                                                  if (constant.userType !=
                                                          constant
                                                              .exhibitorUser &&
                                                      exhibitorDetails!
                                                              .isMeetingRequested
                                                              .toString() ==
                                                          '1' &&
                                                      isShowReminder(
                                                          exhibitorDetails
                                                                  ?.meetingDate ??
                                                              ''))
                                                    _buildPopupMenuDivider(),
                                                  // if (constant.userType !=
                                                  //         constant
                                                  //             .exhibitorUser &&
                                                  //     exhibitorDetails!
                                                  //             .isMeetingRequested
                                                  //             .toString() !=
                                                  //         '1')
                                                  //   _buildPopupMenuItem(
                                                  //       'Request meeting',
                                                  //       'meeting',
                                                  //       context),

                                                  if (constant.userType !=
                                                          constant
                                                              .exhibitorUser &&
                                                      exhibitorDetails!
                                                              .isMeetingRequested
                                                              .toString() !=
                                                          '1' &&
                                                      shouldShowRequestMeeting)
                                                    _buildPopupMenuItem(
                                                        'Request meeting',
                                                        'meeting',
                                                        context),

                                                  // if (constant.userType != constant.exhibitorUser && exhibitorDetails!.isMeetingRequested.toString() != '1') _buildPopupMenuDivider(),
                                                  // if (constant.userType != constant.exhibitorUser) _buildPopupMenuItem('Feedback', 'feedback', context),
                                                ],
                                                onSelected:
                                                    (String value) async {
                                                  if (value == "whatsapp") {
                                                    openWhatsApp(
                                                        exhibitorDetails!
                                                            .whatsapp_no);
                                                  } else if (value == "insta") {
                                                    openInstagram(
                                                        exhibitorDetails!
                                                            .instagram_link);
                                                  } else if (value ==
                                                      "offers") {
                                                    Navigator.push<void>(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                OffersScreen(
                                                                    exhibitorId:
                                                                        widget
                                                                            .exhibitorId,
                                                                            titleName: widget.showName,
                                                                            exhibitorName: widget.titleName,
                                                                            exhibitionId: widget.exhibitionId,)));
                                                  } else if (value ==
                                                      "catalogue") {
                                                    // downloadCatalogAndNotify(
                                                    //     exhibitorDetails?.pdfLink ??
                                                    //         '');
                                                    downloadCatalogAndNotify(
                                                        exhibitorDetails
                                                                ?.pdfLink ??
                                                            '',
                                                        context);
                                                  } else if (value == "share") {
                                                    // Share.share(
                                                    //     'https://www.expogeeks.co.uk/tickets.php?organizerId=Mg==',
                                                    //     subject:
                                                    //         exhibitorDetails!
                                                    //             .name);
                                                String message =
                                                      // "*${widget.titleName}*\n"
                                                      // "🎟 Get your tickets here: 👇\n "
                                                      "Visit ${widget.titleName} at ${widget.showName}:\n"
                                                      "${ticketsUrlForShow(widget.exhibitionId)}";

                                                  shareTextFrom(context, message,
                                                      subject: exhibitorDetails!
                                                          .name);

                                                    // Share.share(
                                                    //     'https://www.expogeeks.co.uk/tickets.php?organizerId=Mg==',
                                                    //     subject:
                                                    //         exhibitorDetails!
                                                    //             .name);
                                                  } else if (value == "fav") {
                                                    if (!isFav) {
                                                      await apiValue
                                                          .addExhibitorFavourite(
                                                              context,
                                                              widget
                                                                  .exhibitorId)
                                                          .then((value) {
                                                        showToast(
                                                            '${exhibitorDetails!.name} added to Favourite');
                                                        initialPref(false);
                                                      });
                                                    }
                                                  } else if (value ==
                                                      "reminder") {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        String cleanedDate =
                                                            exhibitorDetails!
                                                                .meetingDate!
                                                                .replaceAll(
                                                                    RegExp(
                                                                        r'(st|nd|rd|th)'),
                                                                    '');

                                                        final dateFormat =
                                                            DateFormat(
                                                                'dd MMM yyyy');
                                                        DateTime parsedDate =
                                                            dateFormat.parse(
                                                                cleanedDate);
                                                        return ReminderAlertBoxDialog(
                                                          eventDate: parsedDate,
                                                          eventId: widget
                                                              .exhibitorId,
                                                          eventName:
                                                              exhibitorDetails!
                                                                      .name ??
                                                                  '',
                                                          isMeeting: true,
                                                        );
                                                      },
                                                    );
                                                  } else if (value ==
                                                      "meeting") {
                                                    Navigator.push<void>(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                RequestMeetingScreen(
                                                                  exhibitorId:
                                                                      widget
                                                                          .exhibitorId,
                                                                  bookedDates:
                                                                      exhibitorDetails!
                                                                              .bookedDates ??
                                                                          [],
                                                                  meetingList:
                                                                      exhibitorDetails!
                                                                              .meetingList ??
                                                                          [],
                                                                  meetingTimes: exhibitorDetails!
                                                                      .meetingList!
                                                                      .map((meeting) =>
                                                                          meeting
                                                                              .meetingTime ??
                                                                          '')
                                                                      .toList(),
                                                                  meetingDate: exhibitorDetails!
                                                                      .meetingList!
                                                                      .map((meeting) =>
                                                                          meeting
                                                                              .meetingDate ??
                                                                          '')
                                                                      .toList(),
                                                                )));
                                                  }
                                                },
                                                surfaceTintColor: Colors.white,
                                                child: Icon(
                                                  Icons.more_vert_rounded,
                                                  color: Colors.white,
                                                  size: convertFigmaToUIWidth(
                                                      28, width),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            convertFigmaToUIWidth(15, width)),
                                    roundedIconFilledButton(context,
                                        // text1: exhibitorDetails!.mobile ?? '',
                                        text1:
                                            '${exhibitorDetails!.country_code} ${exhibitorDetails!.mobile ?? ''}',
                                        text2: exhibitorDetails!.website ?? '',
                                        w: width),
                                    // SizedBox(height: 5),
                                    SizedBox(
                                        height:
                                            convertFigmaToUIWidth(5, width)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                         
                          children: [
                            
                            SizedBox(height: convertFigmaToUIWidth(25, width)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 34),
                              child: Center(
                                child: Text(
                                  exhibitorDetails!.description ?? '',
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize:
                                          convertFigmaToUIWidth(14, width),
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),

                            SizedBox(height: convertFigmaToUIWidth(40, width)),

                            if (exhibitorDetails!.isMeetingRequested
                                    .toString() ==
                                '1')
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    exhibitorDetails!.meetingList?.length ?? 0,
                                itemBuilder: (context, index) {
                                  Meeting meeting =
                                      exhibitorDetails!.meetingList![index];
                                  return Container(
                                    
                                    height: convertFigmaToUIWidth(70, width),
                                    width: double.infinity,
                                   
                                    margin: EdgeInsets.only(
                                      bottom: convertFigmaToUIWidth(
                                              16,
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) ??
                                          16,
                                    ),

                                    decoration: BoxDecoration(color: cyangreen),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: meeting.meetingStatus ==
                                                      'Accepted'
                                                  ? 'Meeting booked for\n'
                                                  : meeting.meetingStatus ==
                                                          'Rejected'
                                                      ? 'Meeting request rejected for\n'
                                                      : 'Meeting requested on\n',
                                              style: TextStyle(
                                                height: 1.5,
                                                fontSize: convertFigmaToUIWidth(
                                                    12, width),
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  "${meeting.meetingDate} at ${meeting.meetingTime}",
                                              style: TextStyle(
                                                height: 1.5,
                                                fontSize: convertFigmaToUIWidth(
                                                    12, width),
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            SizedBox(height: convertFigmaToUIWidth(40, width)),
                            if (exhibitorDetails!.notBookedDates != null &&
                                    exhibitorDetails!
                                        .notBookedDates!.isNotEmpty ||
                                shouldShowRequestMeeting)
                              constant.userType == constant.exhibitorUser
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 34,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (exhibitorDetails?.isBooked ==
                                              "true") {
                                            Navigator.push<void>(
                                                context,
                                                MaterialPageRoute<void>(
                                                    builder: (BuildContext context) => RequestMeetingScreen(
                                                        exhibitorId:
                                                            widget.exhibitorId,
                                                        bookedDates: exhibitorDetails!
                                                                .bookedDates ??
                                                            [],
                                                        meetingList: exhibitorDetails!
                                                                .meetingList ??
                                                            [],
                                                        meetingTimes: exhibitorDetails!
                                                            .meetingList!
                                                            .map((meeting) =>
                                                                meeting.meetingTime ??
                                                                '')
                                                            .toList(),
                                                        meetingDate: exhibitorDetails!
                                                            .meetingList!
                                                            .map((meeting) => meeting.meetingDate ?? '')
                                                            .toList()))).then((value) => initialPref(true));
                                          } else {
                                            showToast(
                                                'Book a ticket to request meeting');
                                          }
                                        },
                                        child: Visibility(
                                          visible: shouldShowRequestMeeting,
                                          child: Container(
                                            
                                            height: convertFigmaToUIWidth(
                                                60, width),
                                            alignment: Alignment.center,
                                            width: width,
                                            decoration: BoxDecoration(
                                                color: cyangreen,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: Text(
                                              "Request Meeting",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      convertFigmaToUIWidth(
                                                          16, width)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            
                            
                            SizedBox(
                              height: convertFigmaToUIWidth(
                                      140, MediaQuery.of(context).size.width) ??
                                  140,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget roundedIconFilledButton(context, {text1, text2, w}) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 5,
        children: [
          InkWell(
            onTap: () => makingPhoneCall(text1),
            child: Text(
              text1,
              style: TextStyle(
                  height: 1.5,
                  fontSize: convertFigmaToUIWidth(12, w),
                  // fontSize: convertFigmaToUIWidth(16, width) ?? 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0.2),
            child: Text(
              "|",
              style: TextStyle(
                  fontSize: convertFigmaToUIWidth(12, w),
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.5),
            ),
          ),
          InkWell(
            onTap: () => sharingOnTap(text2),
            child: Text(
              text2,
              style: TextStyle(
                  fontSize: convertFigmaToUIWidth(12, w),
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  circleButton({image, onPress, w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: convertFigmaToUIWidth(30, w),
        width: convertFigmaToUIWidth(30, w),
        padding: EdgeInsets.all(
          image == whatsappIcon
              ? 3
              : image == instaIcon
                  ? 5
                  : 3,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: white, width: 1), shape: BoxShape.circle),
        child: Image(image: AssetImage(image)),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String title, String value, BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return PopupMenuItem<String>(
      height: 10,
      value: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value == "whatsapp") SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              height: 1.5,
              // fontSize: 12,
              fontSize: convertFigmaToUIWidth(12, width),
              color: Color.fromRGBO(85, 85, 85, 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          constant.userType == constant.exhibitorUser
              ? (value != "share")
                  ? SizedBox()
                  : SizedBox(height: 10)
              : (value != "meeting")
                  ? SizedBox()
                  : SizedBox(height: 10),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuDivider() {
    return PopupMenuItem<String>(
      enabled: false,
      onTap: null,
      value: null,
      height: 1.5,
      child: Divider(color: Colors.grey, thickness: 0.2),
    );
  }
}
