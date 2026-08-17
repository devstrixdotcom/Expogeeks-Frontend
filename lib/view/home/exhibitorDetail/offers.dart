import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/offers_model.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:event_pro/utils/share_helper.dart';

import '../../../utils/helper_functions.dart';

// ignore: must_be_immutable
class OffersScreen extends StatefulWidget {
  String exhibitorId;
  String? titleName;
  String? exhibitorName;

  /// Exhibition (show) id used to build the shared ticket link; see
  /// [ExhibitorDetailsScreen.exhibitionId].
  String? exhibitionId;
  OffersScreen(
      {super.key,
      required this.exhibitorId,
      this.titleName,
      this.exhibitorName,
      this.exhibitionId});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  TextEditingController _searchController = TextEditingController();
  List<OfferModels> offersList = [];
  List<OfferModels> searchResult = [];
  bool _isSearching = false;
  bool isLoading = true;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    dynamic response =
        await apiValue.getExhibitorOfferList(context, widget.exhibitorId);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        offersList = tempList.map((i) => OfferModels.fromJson(i)).toList();
        print(offersList.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchCustomerList(String text) {
    setState(() {
      searchResult = offersList
          .where((item) => item.description
              .toString()
              .toLowerCase()
              .contains(text.trim().toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return BaseScreen(
      selectedIndex: 4,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: Scaffold(
        appBar: appBarWithSearchField(
            context, _searchController, 'Search Offers', "Offers", false,
            (value) {
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
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Color.fromRGBO(204, 232, 234, 0.7),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                isLoading = true;
              });
              initState();
            },
            child: searchResult.isEmpty && offersList.isEmpty
                ? Center(child: Text('No offers found!'))
                : ListView.separated(
                    itemCount:
                        _isSearching ? searchResult.length : offersList.length,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: convertFigmaToUIWidth(12, width));
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return listItemsBuilder(context, index);
                    },
                  ),
          ),
        ),
        // backgroundColor: Colors.white,
        backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
      ),
    );
  }

  Widget listItemsBuilder(BuildContext context, int i) {
    var width = MediaQuery.of(context).size.width;

    OfferModels offersListItem = _isSearching ? searchResult[i] : offersList[i];

    return Padding(
      padding: EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: (_isSearching ? searchResult.length : offersList.length) == i
              ? 120
              : 0,
          top: i == 0 ? 20 : 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            //
            Container(
              decoration: BoxDecoration(
                  color: lightpink,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Validity : ",
                              style: TextStyle(
                                  height: 1.5,
                                  fontSize: convertFigmaToUIWidth(10, width),
                                  fontWeight: FontWeight.w700,
                                  color: brownText)),
                          Text(
                            offersListItem.validity ?? '',
                            style: TextStyle(
                                height: 1.5,
                                fontSize: convertFigmaToUIWidth(10, width),
                                color: brownText,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    circleButton(
                      image: sendIcon,
                      w: width,
                      onPress: () {
                        String message = "*To Get Offer Visit ${widget.exhibitorName} at ${widget.titleName}*\n"
                            "Get your tickets here:\n"
                            "${ticketsUrlForShow(widget.exhibitionId)}";

                        shareTextFrom(context, message,
                            subject: offersListItem.description);
                      },
                    ),
                  ],
                ),
              ),
            ),

            //
            Container(
              // height: convertFigmaToUIWidth(140, width),
              width: width,
              decoration: BoxDecoration(
                  color: faintPink,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // height: convertFigmaToUIWidth(140, width),
                    // width: convertFigmaToUIWidth(120, width),
                    decoration: BoxDecoration(
                        color: lightpink,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: offersListItem.imageLink ?? '',
                        height: convertFigmaToUIWidth(99, width),
                        width: convertFigmaToUIWidth(101, width),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: convertFigmaToUIWidth(120, width),
                          height: convertFigmaToUIWidth(150, width),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300),
                          child: Center(
                              child: Icon(Icons.error_outline, size: 35)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: convertFigmaToUIWidth(10, width)),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: convertFigmaToUIWidth(6, width) ?? 3, right: 30),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Text(
                                offersListItem.description ?? '',
                                overflow: TextOverflow.clip,
                                maxLines: currentIndex != i ? 4 : 7,
                                style: TextStyle(
                                    height: 1.5,
                                    fontSize:
                                        convertFigmaToUIWidth(12, width) ?? 10,
                                    color: Color.fromRGBO(50, 50, 50, 1),
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                        maxLines: 4,
                      ),
                    ),
                  )
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
