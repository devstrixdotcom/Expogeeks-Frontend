import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/exhibitor_list_model.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/view/home/exhibitorDetail/exhibitor_details.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class ExhibitorListingScreen extends StatefulWidget {
  String organizationId;
  // String showDate;
  String catId;
  bool isBooked;
  String title;
  bool isAutoFocus;
  String showName;
  ExhibitorListingScreen({
    super.key,
    required this.isBooked,
    required this.organizationId,
    // required this.showDate,
    required this.catId,
    required this.title,
    this.isAutoFocus = false,
    this.showName = '',
  });

  @override
  State<ExhibitorListingScreen> createState() => _ExhibitorListingScreenState();
}

class _ExhibitorListingScreenState extends State<ExhibitorListingScreen> {
  // bool isBooked = false;
  // Set<int> slectedIndex = {};
  TextEditingController _searchController = TextEditingController();
  List<ExhibitorListModel> exhibitorList = [];
  List<ExhibitorListModel> searchResult = [];
  bool _isSearching = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialPref(true);
  }

  initialPref(bool isload) async {
    if (isload) {
      setState(() {
        isLoading = true;
      });
    }
    dynamic response = await apiValue.getOrganizerExhibitorList(
        context, widget.organizationId, widget.catId);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        exhibitorList =
            tempList.map((i) => ExhibitorListModel.fromJson(i)).toList();
        print(exhibitorList.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // void searchCustomerList(String text) {
  //   setState(() {
  //     searchResult = exhibitorList
  //         .where((item) => item.name
  //             .toString()
  //             .toLowerCase()
  //             .contains(text.trim().toLowerCase()))
  //         .toList();
  //   });
  // }
  void searchCustomerList(String text) {
    String query = text.trim().toLowerCase();

    setState(() {
      searchResult = exhibitorList.where((item) {
        final name = item.name?.toLowerCase() ?? "";
        final category = item.category?.toLowerCase() ?? "";

        return name.contains(query) || category.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return BaseScreen(
      selectedIndex: 4,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: Scaffold(
        appBar: appBarWithSearchField(
            context, _searchController, 'Find Exhibitor', widget.title, false,
            isAutoFocus: widget.isAutoFocus, (value) {
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
          color: Color.fromRGBO(204, 232, 234, 0.7),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : RefreshIndicator(
                  onRefresh: () async {
                    initialPref(true);
                  },
                  child: ListView.separated(
                    itemCount: _isSearching
                        ? searchResult.length
                        : exhibitorList.length,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 14);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return listItemsBuilder(context, index);
                    },
                  ),
                ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget listItemsBuilder(BuildContext context, int i) {
    var width = MediaQuery.of(context).size.width;
    // var height = MediaQuery.of(context).size.height;
    List<ExhibitorListModel> listValue =
        _isSearching ? searchResult : exhibitorList;

    bool isFav = listValue[i].isFavourite.toString() == '1' ? true : false;

    return StatefulBuilder(
      builder: (BuildContext context, setState) {
        return GestureDetector(
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => ExhibitorDetailsScreen(
                  exhibitorId: listValue[i].id ?? '',
                  titleName: listValue[i].name ?? '',
                  isBooked: widget.isBooked,
                  showName: widget.showName,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: listValue.length - 1 == i ? 100 : 0,
                top: i == 0 ? 20 : 0),
            child: Column(
              children: [
                Stack(
                  children: [
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
                          imageUrl: listValue[i].imageLink ?? '',
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                          errorWidget: (context, url, error) => Container(
                            width: width,
                            height: convertFigmaToUIWidth(200, width),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20)),
                                color: Colors.grey.shade300),
                            child: Center(
                                child: Icon(Icons.error_outline, size: 45)),
                          ),
                        ),
                      ),
                    ),
                    // Fav
                    if (constant.userType != constant.exhibitorUser)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () async {
                            if (!isFav) {
                              await apiValue
                                  .addExhibitorFavourite(
                                      context, listValue[i].id ?? '')
                                  .then((value) {
                                showToast(
                                    '${listValue[i].name} added to Favourite');
                                initialPref(false);
                              });
                            } else {
                              await apiValue
                                  .removeExhibitorFavourite(
                                      context, listValue[i].id ?? '')
                                  .then((value) {
                                showToast(
                                    '${listValue[i].name} removed from Favourite');
                                initialPref(false);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(6),
                            // height: 32,
                            height: convertFigmaToUIWidth(32, width),
                            // width: 32,
                            width: convertFigmaToUIWidth(32, width),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18)),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              // size: 13,
                              size: convertFigmaToUIWidth(13, width),
                              color: isFav
                                  ? Color.fromRGBO(255, 174, 176, 1)
                                  : Colors.black,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                //
                Container(
                  width: width,
                  padding:
                      EdgeInsets.only(left: 20, right: 10, top: 15, bottom: 10),
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
                          Text(listValue[i].name ?? '',
                              style: TextStyle(
                                  height: 1.5,
                                  fontSize: convertFigmaToUIWidth(14, width),
                                  color: Color.fromRGBO(100, 76, 76, 1),
                                  fontWeight: FontWeight.w600)),
                          Text(listValue[i].category ?? '',
                              style: TextStyle(
                                  height: 1.5,
                                  fontSize: convertFigmaToUIWidth(10, width),
                                  color: Color.fromRGBO(100, 76, 76, 1),
                                  fontWeight: FontWeight.w400)),
                          Text("Stand No. ${listValue[i].stallNo ?? ''}",
                              style: TextStyle(
                                  height: 1.5,
                                  fontSize: convertFigmaToUIWidth(10, width),
                                  color: Color.fromRGBO(100, 76, 76, 1),
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      Row(
                        children: [
                          if (constant.userType == constant.exhibitorUser)
                            Container(
                              width: convertFigmaToUIWidth(80, width),
                              height: convertFigmaToUIWidth(25, width),
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                  child: Text("More info",
                                      style: TextStyle(
                                          height: 1.5,
                                          fontSize:
                                              convertFigmaToUIWidth(10, width),
                                          fontWeight: FontWeight.w600,
                                          color: brownText))),
                            ),
                          // circleButton(
                          //     image: sendIcon,
                          //     onPress: () {
                          //       Share.share(
                          //         'https://www.expogeeks.co.uk/tickets.php?organizerId=Mg==',
                          //         subject: listValue[i].name,
                          //       );
                          //     })
                          circleButton(
                            image: sendIcon,
                            w: width,
                            onPress: () {
                              // String message = "*${widget.title}*\n"
                              //     "🎟 Get your tickets here: 👇\n"
                              //     "🔗 https://www.expogeeks.co.uk/tickets.php?organizerId=Mg==";
                              debugPrint(
                                  "listValue name: ${listValue[i].name ?? ''}");
                              String message =
                                  "Visit ${listValue[i].name ?? ''} at ${widget.showName}:\n"
                                  "https://www.expogeeks.co.uk/tickets.php?organizerId=Mg==";

                              Share.share(message, subject: listValue[i].name);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  circleButton({image, onPress, w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
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
