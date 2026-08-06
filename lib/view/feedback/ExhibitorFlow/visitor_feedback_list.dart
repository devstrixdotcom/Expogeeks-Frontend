import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/visitor_feedback_from_exhibitor_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:event_pro/view/feedback/ExhibitorFlow/visitor_feedback_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuBarItems {
  static List Exibitors = ["Budget", "Interest Level", "Date of event"];
}

class FeedbackListScreens extends StatefulWidget {
  FeedbackListScreens({super.key});
  @override
  State<FeedbackListScreens> createState() => _FeedbackListScreensState();
}

class _FeedbackListScreensState extends State<FeedbackListScreens> {
  List<VisitorFeedbackFromExhibitorModel> feedbackList = [];
  bool isLoading = true;
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    // Exhibitor login exhibitor check visitors feedback details
    dynamic response = await apiValue.getExhibitorVistorFeedback(context);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        feedbackList = tempList
            .map((i) => VisitorFeedbackFromExhibitorModel.fromJson(i))
            .toList();
        print(feedbackList.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void sortScannedVisitorList(String criterion) {
    setState(() {
      if (criterion == 'budget') {
        // Sort by Budget (High to Low)
        feedbackList.sort((a, b) {
          int budgetA = _parseBudget(a.estimatedBudget ?? '');
          int budgetB = _parseBudget(b.estimatedBudget ?? '');
          return budgetB.compareTo(budgetA); // High to Low
        });
      } else if (criterion == 'level') {
        // Sort by Interest Level (High to Low)
        feedbackList.sort((a, b) {
          int levelA = int.tryParse(a.interestLevel ?? '0') ?? 0;
          int levelB = int.tryParse(b.interestLevel ?? '0') ?? 0;
          return levelB.compareTo(levelA); // High to Low
        });
      } else if (criterion == 'date') {
        // Sort by Date (Low to High)
        feedbackList.sort((a, b) {
          DateTime dateA = _parseDate(a.expectedDate ?? '');
          DateTime dateB = _parseDate(b.expectedDate ?? '');
          return dateA.compareTo(dateB); // Low to High
        });
      }
    });
  }

// Helper method to parse budget strings like "30,000 - 40,000"
  int _parseBudget(String budget) {
    try {
      // Extract the first part of the budget range (e.g., "30,000" from "30,000 - 40,000")
      String budgetValue = budget.split('-')[0].trim().replaceAll(',', '');
      return int.tryParse(budgetValue) ?? 0;
    } catch (e) {
      print('Error parsing budget: $e');
      return 0;
    }
  }

  DateTime _parseDate(String date) {
    try {
      // Remove suffixes like "th", "st", "nd", "rd" from the day
      String cleanedDate = date.replaceAll(RegExp(r'(st|nd|rd|th)'), '').trim();
      // Parse the cleaned date string (e.g., "28 Mar 2025")
      return DateFormat('d MMM yyyy').parse(cleanedDate);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime(0); // Return a default date if parsing fails
    }
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
                iconTheme: IconThemeData(color: Colors.white),
                scrolledUnderElevation: 0,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'Visitor Feedback',
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
                        _buildPopupMenuItem(
                            'Interest Level', 'level', context, selectedValue),
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

              // 👇 Circular Badge Overlapping the Bottom of AppBar
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
                      feedbackList.length.toString(),
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
          height: size.height,
          width: size.width,
          color: Color.fromRGBO(204, 232, 234, 0.7),
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : RefreshIndicator(
                  onRefresh: () async {
                    initialPref();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60,bottom:80),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: feedbackList.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                            height: convertFigmaToUIWidth(14, width));
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return scannedVistorsMethod(
                            index, size, feedbackList[index]);
                      },
                    ),
                  ),
                ),
        ),
        // backgroundColor: Colors.white,
        // backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
      ),
    );
  }

  Widget scannedVistorsMethod(
      int ind, Size size, VisitorFeedbackFromExhibitorModel feedbackItem) {
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding:
          EdgeInsets.only(bottom: ind == feedbackList.length - 1 ? 120 : 0),
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
                    Text("${feedbackItem.name.toString()}",
                        style: TextStyle(
                            
                            fontSize: convertFigmaToUIWidth(13, width),
                            fontWeight: FontWeight.w700,
                            color: brownText)),
                    RichText(
                      text: TextSpan(
                        children: [
                          if (feedbackItem.weddingRole != '')
                            TextSpan(
                                text: ' | ',
                                style: TextStyle(
                                    
                                    fontSize: convertFigmaToUIWidth(13, width),
                                    fontWeight: FontWeight.w700,
                                    color: brownText)),
                          TextSpan(
                              text: feedbackItem.weddingRole,
                              style: TextStyle(
                                  
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
                              // feedbackItem.mobile ?? '0'
                              '${feedbackItem.countryCode ?? '0'}${feedbackItem.mobile ?? '0'}',
                            )),
                    SizedBox(width: convertFigmaToUIWidth(5, width)),
                    circleButton(
                        image: mailIcon,
                        w: size.width,
                        onPress: () => sendingMails(feedbackItem.email ?? '')),
                    SizedBox(width: convertFigmaToUIWidth(5, width)),
                    circleButton(
                        image: whatsappIcon,
                        w: size.width,
                        onPress: () => sharingOnTap(
                            'https://api.whatsapp.com/send/?phone=${feedbackItem.mobile}&type=phone_number&app_absent=0')),
                  ],
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewFeedbackDetailsScreen(
                          feedbackData: feedbackItem)));
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
                      feedbackItem.userImageLink ?? '',
                      Color.fromRGBO(255, 194, 194, 1),
                      Colors.white,
                      25,
                      getNameInitials(feedbackItem.name.toString()),
                      borderColor: Colors.white),
                  SizedBox(width: convertFigmaToUIWidth(25.8, width)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Wedding Date: ",
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(85, 85, 85, 1)),
                              ),
                              TextSpan(
                                
                                text: DateFormatter.formatDayWithSuffix(
                                    feedbackItem.expectedDate ?? ''),
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(10, width),
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
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(85, 85, 85, 1)),
                              ),
                              TextSpan(
                                text: '£' +
                                    feedbackItem.estimatedBudget.toString(),
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(10, width),
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
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(85, 85, 85, 1)),
                              ),
                              TextSpan(
                                text: feedbackItem.interestLevel.toString(),
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(10, width),
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(85, 85, 85, 1)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: convertFigmaToUIWidth(6, width)),
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Notes: ",
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(85, 85, 85, 1)),
                              ),
                              TextSpan(
                                text: feedbackItem.additionalInfo.toString(),
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(10, width),
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
                                text: "CTA: ",
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(85, 85, 85, 1)),
                              ),
                              TextSpan(
                                text: feedbackItem.callToAction.toString(),
                                style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(10, width),
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(85, 85, 85, 1)),
                              ),
                            ],
                          ),
                        ),
                      ],
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
      height: convertFigmaToUIWidth(30, width) ?? 30,
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
          (value != "date")
              ? SizedBox()
              : SizedBox(height: convertFigmaToUIWidth(10, width)),
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
        width: convertFigmaToUIWidth(380, w),
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
                      fontSize: convertFigmaToUIWidth(17, w),
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

  //
}
