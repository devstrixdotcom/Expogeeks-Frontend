import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/models/scanned_category_list_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/menuScreens/visitor/menu_fav_and_scanned_exhibitor.dart';
import 'package:flutter/material.dart';

import '../../../utils/helper_functions.dart';

// ignore: must_be_immutable
class ScannedExhibitorsScreen extends StatefulWidget {
  bool isAfterScan;
  String? isAfterScanExhibitortorId;

  ScannedExhibitorsScreen(
      {super.key,
      required this.isAfterScan,
      required this.isAfterScanExhibitortorId});

  @override
  State<ScannedExhibitorsScreen> createState() =>
      _ScannedExhibitorsScreenState();
}

class _ScannedExhibitorsScreenState extends State<ScannedExhibitorsScreen> {
  TextEditingController _searchController = TextEditingController();
  List<ScannedCategoryListModel> scannedCategoryList = [];
  List<ScannedCategoryListModel> searchResult = [];
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
    dynamic response = await apiValue.getScannedCategoryList(context);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        if (tempList.isNotEmpty) {
          scannedCategoryList = tempList
              .map((i) => ScannedCategoryListModel.fromJson(i))
              .toList();
          print(scannedCategoryList.length);
        }

        ///
        else {
          showToast('No data available');
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ///
      showToast('Failed to fetch data. Please try again later.');
    }

    // if (widget.isAfterScan) {
    //   Navigator.push<void>(
    //       context,
    //       MaterialPageRoute<void>(
    //           builder: (BuildContext context) => CategoriesItemsListScreen(
    //                 isFromScan: true,
    //                 title: scannedCategoryList[0].categoryName ?? '',
    //                 isScannedExhibitor: true,
    //                 categoryId: scannedCategoryList[0].id ?? '',
    //                 showDate: '',
    //                 isAfterScanExhibitortorId: widget.isAfterScanExhibitortorId,
    //               )));
    // }
    // ///
    // else {
    //   showToast('No scanned categories available.');
    // }

    if (scannedCategoryList.isNotEmpty) {
      if (widget.isAfterScan) {
        Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => CategoriesItemsListScreen(
                      isFromScan: true,
                      title: scannedCategoryList[0].categoryName ?? '',
                      isScannedExhibitor: true,
                      categoryId: scannedCategoryList[0].id ?? '',
                      showDate: '',
                      isAfterScanExhibitortorId:
                          widget.isAfterScanExhibitortorId,
                    )));
      }
    } else {
      showToast('No scanned categories available.');
    }
  }

  void searchCustomerList(String text) {
    setState(() {
      searchResult = scannedCategoryList
          .where((item) => item.categoryName
              .toString()
              .toLowerCase()
              .contains(text.trim().toLowerCase()))
          .toList();
    });
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
        appBar: appBarWithSearchField(context, _searchController,
            'Search by category', "Scanned Exhibitor", false, (value) {
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
              : categoryBuilder(),
          // backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget categoryBuilder() {
    var w = MediaQuery.of(context).size.width;

    List<ScannedCategoryListModel> listToShow =
        _isSearching ? searchResult : scannedCategoryList;

    if (listToShow.isEmpty) {
      return Center(
        child: Text(
          "No categories found",
          style: TextStyle(
            fontSize: convertFigmaToUIWidth(16, w),
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        initialPref();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 25,
              mainAxisSpacing: 20,
              mainAxisExtent: 150),
          itemCount:
              _isSearching ? searchResult.length : scannedCategoryList.length,
          itemBuilder: (BuildContext context, int index) {
            ScannedCategoryListModel scannedCategoryListItem =
                _isSearching ? searchResult[index] : scannedCategoryList[index];
        
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                CategoriesItemsListScreen(
                                  isFromScan: false,
                                  title:
                                      scannedCategoryListItem.categoryName ?? '',
                                  isScannedExhibitor: true,
                                  categoryId: scannedCategoryListItem.id ?? '',
                                  showDate: '',
                                  isAfterScanExhibitortorId:
                                      widget.isAfterScanExhibitortorId,
                                )));
                  },
                  child: Container(
                    height: convertFigmaToUIWidth(100, w),
                    width: convertFigmaToUIWidth(100, w),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 3),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Color.fromRGBO(255, 174, 176, 1), width: 1.5)),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                        child: CachedNetworkImage(
                            imageUrl: scannedCategoryListItem.imageLink ?? ''),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: convertFigmaToUIWidth(10, w)),
                Text(
                  scannedCategoryListItem.categoryName ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: convertFigmaToUIWidth(12, w),
                      fontWeight: FontWeight.w400),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
