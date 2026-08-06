
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/models/fav_category_list_model.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/menuScreens/visitor/menu_fav_and_scanned_exhibitor.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  TextEditingController _searchController = TextEditingController();
  List<FavCategoryListModel> favCategoryList = [];
  List<FavCategoryListModel> searchResult = [];
  bool _isSearching = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    dynamic response = await apiValue.getFavouriteCategoryList(context);
    if (response != null && response is List && response.isNotEmpty) {
      setState(() {
        isLoading = false;
        favCategoryList =
            response.map((i) => FavCategoryListModel.fromJson(i)).toList();
        print(favCategoryList.length);
        print(favCategoryList[0].categoryName);
      });
    } else {
      setState(() {
        isLoading = false;
        favCategoryList = [];
      });
      print("No favorite categories found.");
    }
  }

  void searchCustomerList(String text) {
    setState(() {
      searchResult = favCategoryList.where((item) {
        bool matchesCategory = item.categoryName
                ?.toLowerCase()
                .contains(text.trim().toLowerCase()) ??
            false;

        bool matchesExhibitor = item.exhibitors!.any((exhibitor) =>
            exhibitor.name?.toLowerCase().contains(text.trim().toLowerCase()) ??
            false);
        return matchesCategory || matchesExhibitor;
      }).toList();
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
        appBar: appBarWithSearchField(
            context, _searchController, 'Search  category', "Favorites", false,
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
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Color.fromRGBO(204, 232, 234, 0.7),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : categoryBuilder(),
        ),
      ),
    );
  }

  Widget categoryBuilder() {
    var w = MediaQuery.of(context).size.width;
    if ((favCategoryList.isEmpty && !_isSearching) ||
        (searchResult.isEmpty && _isSearching)) {
      return SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _isSearching
                  ? "No matching favorites found!"
                  : "No favorite categories added yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  // fontSize: 16,
                  fontSize: convertFigmaToUIWidth(16, w),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        initialPref();
      },
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 25,
            mainAxisSpacing: 20,
            mainAxisExtent: 155),
        itemCount: _isSearching ? searchResult.length : favCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          FavCategoryListModel favCategoryListItem =
              _isSearching ? searchResult[index] : favCategoryList[index];

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
                                title: favCategoryListItem.categoryName ?? '',
                                isScannedExhibitor: false,
                                categoryId: favCategoryListItem.id ?? '',
                                showDate: '',
                                isAfterScanExhibitortorId: '',
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
                          imageUrl: favCategoryListItem.imageLink ?? ''),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 10),
              SizedBox(height: convertFigmaToUIWidth(10, w),),
              Text(
                favCategoryListItem.categoryName ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                    height: 1.5,
                    fontSize: convertFigmaToUIWidth(14, w),
                    fontWeight: FontWeight.w400,
                    

                    ),
              )
            ],
          );
        },
      ),
    );
  }
}
