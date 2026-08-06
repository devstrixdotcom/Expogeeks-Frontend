import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/scanned_visitor_list_Model.dart';
import 'package:event_pro/models/visitor_feedback_from_exhibitor_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:event_pro/view/feedback/ExhibitorFlow/feedback_for_visitor.dart';
import 'package:event_pro/view/feedback/ExhibitorFlow/visitor_feedback_details.dart';
import 'package:flutter/material.dart';

class MenuBarItems {
  static List Exibitors = [
    "Budget",
    "Interest Level",
    "Date of event",
  ];
}

class ScaneedVistors extends StatefulWidget {
  bool isAfterScan;
  String? isAfterScanVisitorId;
  String? exhibitionId;
  ScaneedVistors(
      {super.key,
      required this.isAfterScan,
      this.isAfterScanVisitorId,
      this.exhibitionId});
  @override
  State<ScaneedVistors> createState() => _ScaneedVistorsState();
}

class _ScaneedVistorsState extends State<ScaneedVistors> {
  List<ScannedVisitorListModel> scannedVisitorList = [];
  List<VisitorFeedbackFromExhibitorModel> allreadyDoneFeedbackVisitorList = [];
  bool isLoading = true;
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    initialPref();

    debugPrint("isAfterScanexhibitionId ${widget.exhibitionId}");
  }

  initialPref() async {
    setState(() {
      isLoading = true;
    });
    dynamic response = await apiValue.getScannedVisitorList(context);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        scannedVisitorList =
            tempList.map((i) => ScannedVisitorListModel.fromJson(i)).toList();
        print(scannedVisitorList.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
    dynamic feedBackResponse = await apiValue.getExhibitorFeedback(context);
    if (response != null) {
      setState(() {
        var tempList = feedBackResponse as List;
        allreadyDoneFeedbackVisitorList = tempList
            .map((i) => VisitorFeedbackFromExhibitorModel.fromJson(i))
            .toList();
        print(allreadyDoneFeedbackVisitorList.length);
      });
    }
    if (widget.isAfterScan) {
      bool isFeedbackGiven = false;
      bool isCorrectScannedVisitor = false;
      String? isCorrectScannedVisitorId;
      VisitorFeedbackFromExhibitorModel? feedback;

      for (var scannedVisitor in scannedVisitorList) {
        if (widget.isAfterScanVisitorId == scannedVisitor.visitorId &&
            widget.exhibitionId == scannedVisitor.exhibitionId) {
          isCorrectScannedVisitorId = scannedVisitor.visitorId;
          isCorrectScannedVisitor = true;
          break;
        }
      }
      if (isCorrectScannedVisitor && isCorrectScannedVisitorId != null) {
        isFeedbackGiven = allreadyDoneFeedbackVisitorList.any((element) {
          if (element.visitorId == isCorrectScannedVisitorId &&
              element.exhibitionId == widget.exhibitionId) {
            feedback = element;
            return true;
          } else {
            return false;
          }
        });

        // HERE
        if (isFeedbackGiven) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewFeedbackDetailsScreen(
                      feedbackData:
                          feedback ?? VisitorFeedbackFromExhibitorModel())));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeedbackForVisitor(
                visitorData: scannedVisitorList.firstWhere(
                  (visitor) => visitor.visitorId == isCorrectScannedVisitorId,
                ),
                exhibitionId: widget.exhibitionId!,
              ),
            ),
          );
        }
      }
    }

    // if (widget.isAfterScan) {
    //   // 1. Find the scanned visitor
    //   final visitor = scannedVisitorList.firstWhere(
    //     (v) => v.visitorId == widget.isAfterScanVisitorId,
    //     orElse: () =>
    //         ScannedVisitorListModel(), // Return empty if visitor not found
    //   );

    //   if (visitor.visitorId != null) {
    //     // 2. Check if feedback exists for THIS visitor + CURRENT exhibition (using widget.exhibitionId)
    //     final existingFeedback = allreadyDoneFeedbackVisitorList.firstWhere(
    //       (feedback) =>
    //           feedback.visitorId == visitor.visitorId &&
    //           feedback.exhibitionId ==
    //               widget.exhibitionId, // Using widget's exhibitionId
    //       orElse: () =>
    //           VisitorFeedbackFromExhibitorModel(), // Empty if no feedback
    //     );

    //     if (existingFeedback.visitorId != null) {
    //       // Case 1: Feedback exists for this exact exhibition
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => ViewFeedbackDetailsScreen(
    //             feedbackData: existingFeedback,
    //           ),
    //         ),
    //       );
    //     } else {
    //       // Case 2: No feedback for this exhibition (new form)
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => FeedbackForVisitor(
    //             visitorData: visitor,
    //             exhibitionId: widget.exhibitionId!,
    //           ),
    //         ),
    //       );
    //     }
    //   }
    // }
  }

  void sortScannedVisitorList(String criterion) {
    setState(() {
      if (criterion == 'budget') {
        scannedVisitorList.sort((a, b) {
          int budgetA = 0;
          int budgetB = 0;
          try {
            budgetA = a.budget != null
                ? int.parse(a.budget.toString().contains('-')
                    ? a.budget
                        .toString()
                        .trim()
                        .split('-')[0]
                        .replaceAll(',', '')
                    : a.budget
                        .toString()
                        .trim()
                        .split(' ')[0]
                        .replaceAll(',', ''))
                : 0;
            budgetB = b.budget != null
                ? int.parse(b.budget.toString().contains('-')
                    ? b.budget
                        .toString()
                        .trim()
                        .split('-')[0]
                        .replaceAll(',', '')
                    : b.budget
                        .toString()
                        .trim()
                        .split(' ')[0]
                        .replaceAll(',', ''))
                : 0;
          } catch (e) {
            print('Error parsing budget: $e');
          }
          print('---------------------');
          print(budgetA);
          print(budgetB);
          return budgetB.compareTo(budgetA);
        });
      } else if (criterion == 'level') {
        scannedVisitorList.sort((a, b) {
          int levelA = 0;
          int levelB = 0;

          if (allreadyDoneFeedbackVisitorList.isNotEmpty) {
            allreadyDoneFeedbackVisitorList.any((element) {
              if (element.visitorId == a.visitorId) {
                levelA = int.parse(element.interestLevel ?? '0');
                return true;
              } else {
                return false;
              }
            });

            allreadyDoneFeedbackVisitorList.any((element) {
              if (element.visitorId == b.visitorId) {
                levelB = int.parse(element.interestLevel ?? '0');
                return true;
              } else {
                return false;
              }
            });
          }

          print('---------------------');
          print(levelA);
          print(levelB);
          return levelB.compareTo(levelA);
        });
      } else if (criterion == 'date') {
        scannedVisitorList.sort((a, b) {
          DateTime dateA;
          DateTime dateB;
          try {
            dateA = DateTime.parse(a.weddingDate ?? '');
            dateB = DateTime.parse(b.weddingDate ?? '');
          } catch (e) {
            print('Error parsing date: $e');
            return 0;
          }
          return dateA.compareTo(dateB);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Navigate to MenuScreen when back button is pressed
        print("hello");
        Navigator.pushReplacementNamed(
            context, '/menu'); // Replace with your MenuScreen route
        return true; // Prevent default back navigation
      },
      child: BaseScreen(
        // return BaseScreen(
        onItemSelected: (index) {
          Navigator.pushNamed(context, getRouteForIndex(index));
        },
        selectedIndex: 3,
        child: Scaffold(
          appBar: PreferredSize(
           preferredSize:
              Size.fromHeight(convertFigmaToUIWidth(110, width) ?? 110),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                AppBar(
                  shadowColor: Colors.transparent,
                  backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
                  centerTitle: true,
                  iconTheme: IconThemeData(color: Colors.white),
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  title: Text(
                    'Scanned Vistors',
                    style: TextStyle(
                      height: 1.5,
                      fontSize: convertFigmaToUIWidth(20, width),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        elevation: 3,
                        offset: Offset(-7, 30),
                        surfaceTintColor: Colors.white,
                        splashRadius: 0,
                        itemBuilder: (BuildContext context) => [
                          _buildPopupMenuItem(
                              'Budget', 'budget', context, selectedValue),
                          _buildPopupMenuDivider(),
                          _buildPopupMenuItem('Interest Level', 'level',
                              context, selectedValue),
                          _buildPopupMenuDivider(),
                          _buildPopupMenuItem(
                              'Date of event', 'date', context, selectedValue),
                        ],
                        onSelected: (String value) {
                          selectedValue = value;
                          sortScannedVisitorList(value);
                        },
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ],
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      color: cyangreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),

                /// 👇 Circular Badge Overlapping AppBar & Body
                Positioned(
                  
                  bottom: convertFigmaToUIWidth(-36, width) ?? 0,
                  child: Container(
                    height: convertFigmaToUIWidth(90, width),
                    width: convertFigmaToUIWidth(90, width),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: cyangreen,
                    ),
                    child: Center(
                      child: Text(
                        scannedVisitorList.length.toString(),
                        style: TextStyle(
                          fontSize: convertFigmaToUIWidth(20, width),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          body: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(204, 232, 234, 0.7),
            ),
            height: size.height,
            width: size.width,
            padding: EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: cyangreen))
                : RefreshIndicator(
                    onRefresh: () async {
                      initialPref();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 44),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: scannedVisitorList.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                              height: convertFigmaToUIWidth(10, width));
                        },
                        itemBuilder: (BuildContext context, int index) {
                          bool isFeedbackGiven = false;
                          VisitorFeedbackFromExhibitorModel? feedback;

                          isFeedbackGiven =
                              allreadyDoneFeedbackVisitorList.any((element) {
                            if (element.visitorId ==
                                    scannedVisitorList[index].visitorId &&
                                element.exhibitionId ==
                                    scannedVisitorList[index].exhibitionId) {
                              feedback = element;
                              return true;
                            } else {
                              return false;
                            }
                          });

                          return ScannedVistorsMethod(
                              index,
                              size,
                              scannedVisitorList[index],
                              isFeedbackGiven,
                              feedback);
                        },
                      ),
                    ),
                  ),
          ),
          // backgroundColor: Colors.white,
          // backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
        ),
      ),
    );
  }

  Widget ScannedVistorsMethod(
      int index,
      Size size,
      ScannedVisitorListModel scannedVisitoritem,
      bool isFeedbackGiven,
      VisitorFeedbackFromExhibitorModel? feedback) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
          bottom: index == scannedVisitorList.length - 1 ? 120 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 214, 215, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("${scannedVisitoritem.name.toString()}",
                        style: TextStyle(
                            height: 1.5,
                            // fontSize: 13,
                            fontSize: convertFigmaToUIWidth(13, width),
                            fontWeight: FontWeight.w700,
                            color: brownText)),
                    RichText(
                      text: TextSpan(
                        children: [
                          if (scannedVisitoritem.weddingRole != '')
                            TextSpan(
                                text: ' | ',
                                style: TextStyle(
                                    height: 1.5,
                                    // fontSize: 13,
                                    fontSize: convertFigmaToUIWidth(13, width),
                                    fontWeight: FontWeight.w700,
                                    color: brownText)),
                          TextSpan(
                              text: scannedVisitoritem.weddingRole.toString(),
                              style: TextStyle(
                                  height: 1.5,
                                  // fontSize: 13,
                                  fontSize: convertFigmaToUIWidth(13, width),
                                  fontWeight: FontWeight.w700,
                                  color: brownText)),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    circleButton(
                        image: callIcon,
                        w: size.width,
                        onPress: () => makingPhoneCall(
                              // scannedVisitoritem.mobile
                              '${scannedVisitoritem.countryCode}${scannedVisitoritem.mobile}',
                            )),
                    SizedBox(width: 5),
                    circleButton(
                        image: mailIcon,
                        w: size.width,
                        onPress: () =>
                            sendingMails(scannedVisitoritem.email ?? '')),
                    SizedBox(width: 5),
                    circleButton(
                        image: whatsappIcon,
                        w: size.width,
                        onPress: () => sharingOnTap(
                            'https://api.whatsapp.com/send/?phone=${scannedVisitoritem.mobile}&type=phone_number&app_absent=0')),
                  ],
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isFeedbackGiven) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewFeedbackDetailsScreen(
                            feedbackData: feedback ??
                                VisitorFeedbackFromExhibitorModel())));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FeedbackForVisitor(
                              visitorData: scannedVisitoritem,
                              // exhibitionId: widget.exhibitionId,
                              exhibitionId: widget.isAfterScan
                                  ? widget.exhibitionId
                                  : scannedVisitoritem.exhibitionId,
                            )));
                debugPrint("Feedback given ${scannedVisitoritem.exhibitionId}");
              }
            },
            child: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 239, 239, 1),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16))),
              child: Row(
                children: [
                  getCircularImageWidget(
                      80,
                      scannedVisitoritem.imageLink ?? '',
                      Color.fromRGBO(255, 194, 194, 1),
                      Colors.white,
                      25,
                      getNameInitials(scannedVisitoritem.name.toString()),
                      borderColor: Colors.white),
                  SizedBox(
                    width: convertFigmaToUIWidth(25, width),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Wedding date: ",
                                  style: TextStyle(
                                      height: 1.5,
                                      // fontSize: 12,
                                      fontSize:
                                          convertFigmaToUIWidth(12, width),
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                                TextSpan(
                                  // text: DateFormat('dd MMM yyyy').format(DateTime.parse(scannedVisitoritem.weddingDate ?? '')),
                                  text: DateFormatter.formatDayWithSuffix(
                                      scannedVisitoritem.weddingDate ?? ''),
                                  style: TextStyle(
                                      height: 1.5,
                                      // fontSize: 10,
                                      fontSize:
                                          convertFigmaToUIWidth(10, width),
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: convertFigmaToUIWidth(6, width)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Budget: ",
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(12, width),
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                                TextSpan(
                                  text: '£' +
                                      scannedVisitoritem.budget.toString(),
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(10, width),
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: convertFigmaToUIWidth(6, width)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Interest Level: ",
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(12, width),
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                                TextSpan(
                                  text: isFeedbackGiven
                                      ? feedback!.interestLevel.toString()
                                      : 'To be given',
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(10, width),
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: convertFigmaToUIWidth(6, width)),
                          RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Notes: ",
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(12, width),
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                                TextSpan(
                                  text: isFeedbackGiven
                                      ? feedback!.additionalInfo
                                      : 'To be given',
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(10, width),
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: convertFigmaToUIWidth(6, width)),
                          RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "CTA: ",
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(12, width),
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                                TextSpan(
                                  text: isFeedbackGiven
                                      ? feedback!.callToAction
                                      : 'To be given',
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(10, width),
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(85, 85, 85, 1)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
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
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            border: Border.all(color: brownText, width: 1),
            shape: BoxShape.circle),
        child: Image(image: AssetImage(image), color: brownText),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String title, String value, BuildContext context, String selectedValue) {
    var width = MediaQuery.of(context).size.width;
    return PopupMenuItem<String>(
      height: 30,
      value: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value == "budget") SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: convertFigmaToUIWidth(12, width),
              color: selectedValue == value
                  ? cyangreen
                  : Color.fromRGBO(85, 85, 85, 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          (value != "date") ? SizedBox() : SizedBox(height: 10),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuDivider() {
    return PopupMenuItem<String>(
        height: 10,
        enabled: false,
        onTap: null,
        value: null,
        child: Divider(color: Colors.grey, thickness: 0.2));
  }

  editDialog(double h, double w, String msg, context) {
    return Dialog(
      child: Container(
        width: convertFigmaToUIWidth(347, w),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: cyangreenLight, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('Message',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: convertFigmaToUIWidth(16, w),
                      fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(msg,
                  style: TextStyle(
                      height: 1.5, color: Color.fromRGBO(85, 85, 85, 1))),
            ),
          ],
        ),
      ),
    );
  }
}
