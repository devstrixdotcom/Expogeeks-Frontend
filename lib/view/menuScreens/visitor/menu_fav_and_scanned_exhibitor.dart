import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/category_exhibitor_list_model.dart';
import 'package:event_pro/models/exhibitor_feedback_from_visitor_model.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/view/home/exhibitorDetail/exhibitor_details.dart';
import 'package:event_pro/view/feedback/VisitorFlow/exhibitor_feedback_details.dart';
import 'package:event_pro/view/feedback/VisitorFlow/feedback_for_exhibitor.dart';
import 'package:flutter/material.dart';
import 'package:event_pro/utils/share_helper.dart';

// ignore: must_be_immutable
class CategoriesItemsListScreen extends StatefulWidget {
  bool isFromScan;
  String title;
  bool isScannedExhibitor;
  String? isAfterScanExhibitortorId;
  String categoryId;
  String showDate;

  /// Show the category belongs to, returned by GetFavouriteCategoryList.php /
  /// GetScannedCategoryList.php. Used to build the shared ticket link.
  String? exhibitionId;

  CategoriesItemsListScreen({
    super.key,
    required this.isFromScan,
    required this.title,
    required this.isScannedExhibitor,
    required this.categoryId,
    required this.showDate,
    required this.isAfterScanExhibitortorId,
    this.exhibitionId,
  });

  @override
  State<CategoriesItemsListScreen> createState() =>
      _CategoriesItemsListScreenState();
}

class _CategoriesItemsListScreenState extends State<CategoriesItemsListScreen> {
  TextEditingController _searchController = TextEditingController();

  var inputBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: Colors.white),
  );

  List<CategoryExhibitorListModel> exhibitorList = [];
  List<CategoryExhibitorListModel> searchResult = [];
  List<ExhibitorFeedbackFromVisitorModel> alreadyDoneFeedbackExhibitorList = [];
  bool _isSearching = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    setState(() {
      isLoading = true;
    });

    if (widget.isScannedExhibitor) {
      dynamic response =
          await apiValue.getScannedExhibitorList(context, widget.categoryId);

      if (response != null) {
        setState(() {
          isLoading = false;
          var tempList = response as List;
          exhibitorList = tempList
              .map((i) => CategoryExhibitorListModel.fromJson(i))
              .toList();
          print(exhibitorList.length);
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }

      dynamic feedBackResponse = await apiValue.getVisitorFeedback(context);
      // Guard the feedback response, not the exhibitor one: when the feedback
      // call fails it returns null, and casting that to List throws.
      if (feedBackResponse != null) {
        setState(() {
          var tempList = feedBackResponse as List;
          alreadyDoneFeedbackExhibitorList = tempList
              .map((i) => ExhibitorFeedbackFromVisitorModel.fromJson(i))
              .toList();
          print(alreadyDoneFeedbackExhibitorList.length);
        });
      }

      if (widget.isFromScan) {
        bool isFeedbackGiven = false;
        bool isCorrectScannedVisitor = false;
        String? isCorrectScannedVisitorId;
        ExhibitorFeedbackFromVisitorModel? feedback;
        CategoryExhibitorListModel? selectedExhibitor;

        for (var scannedExhibitor in exhibitorList) {
          if (widget.isAfterScanExhibitortorId ==
              scannedExhibitor.exhibitorId) {
            isCorrectScannedVisitorId = scannedExhibitor.exhibitorId;
            isCorrectScannedVisitor = true;
            selectedExhibitor = scannedExhibitor;
            break;
          }
        }

        if (isCorrectScannedVisitor && isCorrectScannedVisitorId != null) {
          isFeedbackGiven = alreadyDoneFeedbackExhibitorList.any((element) {
            if (element.exhibitorId == isCorrectScannedVisitorId) {
              feedback = element;
              return true;
            } else {
              return false;
            }
          });

          if (isFeedbackGiven) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewExhibitorFeedbackDetailsScreen(
                        feedbackData:
                            feedback ?? ExhibitorFeedbackFromVisitorModel())));
          } else {
            if (isCorrectScannedVisitorId != '' &&
                isCorrectScannedVisitorId.toString() != 'null') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FeedbackForExhibitor(
                            category: widget.title,
                            exhibitorId: isCorrectScannedVisitorId ?? '',
                            image: selectedExhibitor?.imageLink ?? '',
                            circularImage:
                                selectedExhibitor?.circularImageLink ?? '',
                            name: selectedExhibitor?.name ?? '',
                            email: selectedExhibitor?.email ?? '',
                            insta: selectedExhibitor?.instagramLink ?? '',
                            countryCode: selectedExhibitor?.countryCode ?? '',
                            phone: selectedExhibitor?.mobile ?? '',
                            exhibitionName: selectedExhibitor?.exhibitionName ?? '',
                          )));
            } else {
              showToast('Error');
            }
          }
        }

        // bool isFeedbackGiven = false;
        // ExhibitorFeedbackFromVisitorModel? feedback;

        // isFeedbackGiven = alreadyDoneFeedbackExhibitorList.any((element) {
        //   if (element.exhibitorId == exhibitorList[0].id) {
        //     feedback = element;
        //     return true;
        //   } else {
        //     return false;
        //   }
        // });

        // if (isFeedbackGiven) {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => ViewExhibitorFeedbackDetailsScreen(feedbackData: feedback ?? ExhibitorFeedbackFromVisitorModel())));
        // } else {
        //   if (exhibitorList[0].id.toString() != '' && exhibitorList[0].id.toString() != 'null') {
        //     Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForExhibitor(category: widget.title, exhibitorId: exhibitorList[0].id ?? '', image: exhibitorList[0].imageLink ?? '', circularImage: exhibitorList[0].circularImageLink ?? '', name: exhibitorList[0].name ?? '', email: exhibitorList[0].email ?? '', insta: exhibitorList[0].instagramLink ?? '', phone: exhibitorList[0].mobile ?? '')));
        //   } else {
        //     showToast('Error');
        //   }
        // }
      }
    } else {
      dynamic response =
          await apiValue.getFavouriteExhibitorList(context, widget.categoryId);
      if (response != null) {
        setState(() {
          isLoading = false;
          var tempList = response as List;
          exhibitorList = tempList
              .map((i) => CategoryExhibitorListModel.fromJson(i))
              .toList();
          print(exhibitorList.length);
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }

    // if (widget.isScannedExhibitor) {
    // localSavedExhibitorList = await getFeedbackData();
    //   if (widget.isFromScan) {
    //     bool isFeedbackGiven = false;
    //     ExhibitorFeedback? feedback;
    //     isFeedbackGiven = localSavedExhibitorList.any((element) {
    //       if (element.exhibitorId == exhibitorList[0].id) {
    //         feedback = element;
    //         return true;
    //       } else {
    //         return false;
    //       }
    //     });
    //     if (isFeedbackGiven) {
    //       Navigator.push(context, MaterialPageRoute(builder: (context) => ViewExhibitorFeedbackDetailsScreen(feedbackData: feedback ?? ExhibitorFeedback())));
    //     } else {
    //       if (exhibitorList[0].id.toString() != '' && exhibitorList[0].id.toString() != 'null') {
    //         Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForExhibitor(category: widget.title, exhibitorId: exhibitorList[0].id ?? '', image: exhibitorList[0].imageLink ?? '', circularImage: exhibitorList[0].circularImageLink ?? '', name: exhibitorList[0].name ?? '', email: exhibitorList[0].email ?? '', insta: exhibitorList[0].instagramLink ?? '', phone: exhibitorList[0].mobile ?? '')));
    //       } else {
    //         showToast('Error');
    //       }
    //     }
    //   }
    // }
  }

  void searchCustomerList(String text) {
    setState(() {
      searchResult = exhibitorList
          .where((item) => item.name
              .toString()
              .toLowerCase()
              .contains(text.trim().toLowerCase()))
          .toList();
    });
  }

  // Future<List<ExhibitorFeedback>> getFeedbackData() async {
  //   var feedbackBox = Hive.box('exhibitorFeedback');
  //   List<ExhibitorFeedback> temp = feedbackBox.values.toList().cast<ExhibitorFeedback>();
  //   print('---------------------');
  //   print(temp.length);
  //   List<ExhibitorFeedback> filteredList = temp.where((element) => element.userId.toString() == constant.phoneValue).toList();
  //   print(filteredList.length);
  //   print('---------------------');
  //   return filteredList;
  // }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BaseScreen(
      selectedIndex: 4,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: Scaffold(
        appBar: appBarWithSearchField(context, _searchController,
            'Search by Company', widget.title, false, (value) {
        
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
                  child: ListView.separated(
                    itemCount: _isSearching
                        ? searchResult.length
                        : exhibitorList.length,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: convertFigmaToUIWidth(12, width));
                    },
                    itemBuilder: (BuildContext context, int index) {
                      bool isFeedbackGiven = false;
                      ExhibitorFeedbackFromVisitorModel? feedback;

                      if (widget.isScannedExhibitor) {
                        if (_isSearching) {
                          isFeedbackGiven =
                              alreadyDoneFeedbackExhibitorList.any((element) {
                            if (element.exhibitorId ==
                                searchResult[index].exhibitorId) {
                              feedback = element;
                              return true;
                            } else {
                              return false;
                            }
                          });
                        } else {
                          isFeedbackGiven =
                              alreadyDoneFeedbackExhibitorList.any((element) {
                            if (element.exhibitorId ==
                                exhibitorList[index].exhibitorId) {
                              feedback = element;
                              return true;
                            } else {
                              return false;
                            }
                          });
                        }
                      }

                      return listItemsBuilder(
                          context,
                          _isSearching
                              ? searchResult[index]
                              : exhibitorList[index],
                          isFeedbackGiven,
                          feedback,
                          index);
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget listItemsBuilder(
      BuildContext context,
      CategoryExhibitorListModel item,
      bool isFeedbackGiven,
      ExhibitorFeedbackFromVisitorModel? feedback,
      int ind) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: widget.isScannedExhibitor
          ? () async {
              print(isFeedbackGiven);
              if (isFeedbackGiven) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ViewExhibitorFeedbackDetailsScreen(
                                feedbackData: feedback ??
                                    ExhibitorFeedbackFromVisitorModel())));
              } else {
                if (item.id.toString() != '' && item.id.toString() != 'null') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeedbackForExhibitor(
                              category: widget.title,
                              exhibitorId: item.id ?? '',
                              image: item.imageLink ?? '',
                              circularImage: item.circularImageLink ?? '',
                              name: item.name ?? '',
                              email: item.email ?? '',
                              insta: item.instagramLink ?? '',
                              countryCode: item.countryCode ?? '',
                              phone: item.mobile ?? '',
                              exhibitionName:  item.exhibitionName ?? '',
                              )));
                } else {
                  showToast('Error');
                }
              }
            }
          : () async {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => ExhibitorDetailsScreen(
                    titleName: item.name ?? '',
                    exhibitorId: item.id ?? '1',
                    // showDate: widget.showDate, // here
                    isBooked: false,
                    showName: item.exhibitionName,
                    exhibitionId: item.exhibitionId ?? widget.exhibitionId,
                  ),
                ),
              );
            },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            left: 15,
            right: 15,
            top: ind == 0 ? 20 : 0,
            bottom:
                (_isSearching ? searchResult.length : exhibitorList.length) -
                            1 ==
                        ind
                    ? 120
                    : 0),
        child: Column(
          children: [
            //
            Container(
              width: width,
              
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
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  errorWidget: (context, url, error) => Container(
                    width: width,
                   
                    height: convertFigmaToUIWidth(20, width),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Colors.grey.shade300),
                    child: Center(child: Icon(Icons.error_outline, size: 45)),
                  ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                height: 1.5,
                                fontSize: convertFigmaToUIWidth(14, width),
                                color: Color.fromRGBO(100, 76, 76, 1),
                                fontWeight: FontWeight.w600)),
                        Text(widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                height: 1.5,
                                fontSize: convertFigmaToUIWidth(12, width),
                                color: Color.fromRGBO(100, 76, 76, 1),
                                fontWeight: FontWeight.w400)),
                        // Which show this exhibitor was scanned at - the card
                        // named the category only, so a visitor with several
                        // shows could not tell them apart. It reads as a chip
                        // rather than a third line of text, so the booth name
                        // and category keep their place in the hierarchy.
                        if ((item.exhibitionName ?? '').isNotEmpty) ...[
                          SizedBox(
                              height: convertFigmaToUIWidth(8, width) ?? 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  convertFigmaToUIWidth(10, width) ?? 10,
                              vertical: convertFigmaToUIWidth(5, width) ?? 5,
                            ),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_outlined,
                                    size: convertFigmaToUIWidth(12, width),
                                    color: cyangreen),
                                SizedBox(
                                    width:
                                        convertFigmaToUIWidth(5, width) ?? 5),
                                Flexible(
                                  child: Text(item.exhibitionName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          height: 1.1,
                                          fontSize:
                                              convertFigmaToUIWidth(11, width),
                                          letterSpacing: 0.2,
                                          color: cyangreen,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // The Builder gives the share sheet a context that resolves to
                  // the button's own RenderBox. Without it the surrounding
                  // context comes from the ListView itemBuilder, whose render
                  // object is the sliver — no usable anchor, and iOS then
                  // refuses to present the sheet.
                  Builder(
                    builder: (BuildContext buttonContext) => circleButton(
                        image: sendIcon,
                        onPress: () {
                          // This screen only knows the category, not the show, so
                          // there is no exhibition id to build a tickets.php link
                          // from — ticketsUrlForShow falls back to the site home.
                          String message = "${widget.title}\n"
                              "Get your tickets here:\n"
                              "${ticketsUrlForShow(widget.exhibitionId)}";

                          shareTextFrom(buttonContext, message,
                              subject: widget.title);
                        }),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  circleButton({image, onPress}) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onPress,
      child: Container(
        // height: 32,
        // width: 32,
        height: convertFigmaToUIWidth(32, width),
        width: convertFigmaToUIWidth(32, width),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
            border: Border.all(color: brownText, width: 1),
            shape: BoxShape.circle),
        child: Image(image: AssetImage(image), color: brownText),
      ),
    );
  }
}
