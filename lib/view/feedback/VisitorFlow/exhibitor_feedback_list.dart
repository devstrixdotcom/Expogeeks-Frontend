import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/exhibitor_feedback_from_visitor_model.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/view/feedback/VisitorFlow/exhibitor_feedback_details.dart';
import 'package:flutter/material.dart';

class ExhibitorFeedbackListScreen extends StatefulWidget {
  ExhibitorFeedbackListScreen({super.key});

  @override
  State<ExhibitorFeedbackListScreen> createState() =>
      _ExhibitorFeedbackListScreenState();
}

class _ExhibitorFeedbackListScreenState
    extends State<ExhibitorFeedbackListScreen> {
  TextEditingController _searchController = TextEditingController();

  List<ExhibitorFeedbackFromVisitorModel> searchResult = [];
  List<ExhibitorFeedbackFromVisitorModel> feedbackList = [];
  bool _isSearching = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    dynamic response = await apiValue.getVisitorFeedback(context);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        feedbackList = tempList
            .map((i) => ExhibitorFeedbackFromVisitorModel.fromJson(i))
            .toList();
        print(feedbackList.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // initialPref() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   feedbackList = await getFeedbackData();
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  void searchCustomerList(String text) {
    setState(() {
      searchResult = feedbackList
          .where((item) => item.exhibitorName
              .toString()
              .toLowerCase()
              .contains(text.trim().toLowerCase()))
          .toList();
    });
  }

  // Future<List<ExhibitorFeedback>> getFeedbackData() async {
  //   var feedbackBox = Hive.box('exhibitorFeedback');
  //   List<ExhibitorFeedback> temp = feedbackBox.values.toList().cast<ExhibitorFeedback>();
  //   List<ExhibitorFeedback> filteredList = temp.where((element) => element.userId.toString() == constant.phoneValue).toList();
  //   return filteredList;
  // }

// PopScope(
//   canPop: false,
// )

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Navigate to MenuScreen when back button is pressed
        print("hello");
        Navigator.pushReplacementNamed(
            context, '/menu'); // Replace with your MenuScreen route
        return true; // Prevent default back navigation
      },
      child: BaseScreen(
        selectedIndex: 4,
        onItemSelected: (index) {
          print("back button pressed");
          Navigator.pushNamed(context, getRouteForIndex(index));
          // Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Scaffold(
          appBar: appBarWithSearchField(
              context, _searchController, 'Search feedbacks', 'Feedback', false,
              isExhibitorFeedbackListScreenafterScan: true, (value) {
            if (_searchController.text.isEmpty) {
              setState(() {
                _isSearching = false;
              });
            } else {
              setState(() {
                _isSearching = true;
                searchCustomerList(_searchController.text.trim());
              });
            }
          }),
          body: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Color.fromRGBO(204, 232, 234, 0.7),
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: cyangreen))
                : RefreshIndicator(
                    onRefresh: () async {
                      initialPref();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          
                          SizedBox(height: convertFigmaToUIWidth(30, width)),
                          ListView.separated(
                            itemCount: _isSearching
                                ? searchResult.length
                                : feedbackList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(height: convertFigmaToUIWidth(12, width));
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return listItemsBuilder(
                                  context,
                                  _isSearching
                                      ? searchResult[index]
                                      : feedbackList[index]);
                            },
                          ),
                          
                          SizedBox(height: convertFigmaToUIWidth(200, width),)
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget listItemsBuilder(
      BuildContext context, ExhibitorFeedbackFromVisitorModel item) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewExhibitorFeedbackDetailsScreen(feedbackData: item)));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            //
            Container(
              width: width,
              height: convertFigmaToUIWidth(200, width),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
                child: CachedNetworkImage(
                  imageUrl: item.imageLink ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                      width: width,
                      height: convertFigmaToUIWidth(200, width),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          color: Colors.grey.shade300),
                      child:
                          Center(child: Icon(Icons.error_outline, size: 45))),
                ),
              ),
            ),
            //
            Container(
              width: width,
              padding:
                  EdgeInsets.only(left: 20, right: 10, top: 15, bottom: 20),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 174, 176, 0.2),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.exhibitorName ?? '-',
                          style: TextStyle(
                              height: 1.5,
                              fontSize: convertFigmaToUIWidth(16, width),
                              color: Color.fromRGBO(100, 76, 76, 1),
                              fontWeight: FontWeight.w600)),
                      Text(item.exhibitorCategory ?? '',
                          style: TextStyle(
                              height: 1.5,
                              fontSize: convertFigmaToUIWidth(14, width),
                              color: Color.fromRGBO(100, 76, 76, 1),
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  circleButton(image: sendIcon, w: width)
                  // circleButton(
                  //   image: sendIcon,
                  //   w: width,
                  //   onPress: () {
                  //     String message = "🎟 Get your tickets here: 👇\n"
                  //         "🔗 https://www.expogeeks.co.uk/tickets.php?organizerId=Mg==";

                  //     Share.share(message, subject: "Get your tickets here");
                  //   },
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  circleButton({image, onPress, w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
         height: convertFigmaToUIWidth(30, w),
        width: convertFigmaToUIWidth(30, w),
        padding: EdgeInsets.all(convertFigmaToUIWidth(6, w) ?? 6),
        decoration: BoxDecoration(
            border: Border.all(color: white, width: 1), shape: BoxShape.circle),
        child: Image(image: AssetImage(image)),
      ),
    );
  }
}
