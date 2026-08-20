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
                      exhibitionId: scannedCategoryList[0].exhibitionId,
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

  /// convertFigmaToUIWidth is nullable at every call site; this keeps the
  /// layout code free of `?? n` noise by falling back to the figma value.
  double _sc(double figmaValue, double screenWidth) =>
      convertFigmaToUIWidth(figmaValue, screenWidth) ?? figmaValue;

  Widget categoryBuilder() {
    var w = MediaQuery.of(context).size.width;

    List<ScannedCategoryListModel> listToShow =
        _isSearching ? searchResult : scannedCategoryList;

    if (listToShow.isEmpty) {
      // Scrollable empty state, so pull-to-refresh is still available to a
      // visitor who scanned a badge and came straight back to this tab.
      return RefreshIndicator(
        color: cyangreen,
        onRefresh: () async {
          initialPref();
        },
        child: emptyStateBuilder(w),
      );
    }

    // Grouped by show, the way the meetings list groups by date: the show name
    // heads a section and the categories scanned at that show sit under it, so
    // a visitor attending several shows can tell identically named categories
    // apart without reading a caption on every tile.
    Map<String, List<ScannedCategoryListModel>> groupedByShow = {};
    for (var item in listToShow) {
      // Keyed on the id so two shows sharing a name stay separate; the name is
      // recovered from the first item of the group when the header is drawn.
      String key = '${item.exhibitionId ?? ''}|${item.exhibitionName ?? ''}';
      groupedByShow.putIfAbsent(key, () => []).add(item);
    }

    List<MapEntry<String, List<ScannedCategoryListModel>>> sections =
        groupedByShow.entries.toList();

    return RefreshIndicator(
      color: cyangreen,
      onRefresh: () async {
        initialPref();
      },
      child: SingleChildScrollView(
        // Always scrollable so pull-to-refresh still works when the single
        // show on file does not fill the screen.
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          // Bottom room clears the floating bottom nav bar.
          padding: EdgeInsets.only(top: _sc(6, w), bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(sections.length, (i) {
              return showSectionBuilder(sections[i].value, w);
            }),
          ),
        ),
      ),
    );
  }

  /// One show = one card: its name heads the card and the categories scanned
  /// at that show sit inside it, so the grouping is visible as a boundary and
  /// not just as a run of tiles under a line of text.
  Widget showSectionBuilder(List<ScannedCategoryListModel> list, double w) {
    String showName = list.first.exhibitionName ?? '';

    return Container(
      margin: EdgeInsets.fromLTRB(_sc(16, w), _sc(14, w), _sc(16, w), 0),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(_sc(22, w)),
        boxShadow: [
          BoxShadow(
            color: cyangreen.withOpacity(0.07),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                _sc(16, w), _sc(16, w), _sc(16, w), _sc(14, w)),
            child: Row(
              children: [
                Container(
                  height: _sc(36, w),
                  width: _sc(36, w),
                  decoration: BoxDecoration(
                    color: cyangreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_sc(11, w)),
                  ),
                  child: Icon(Icons.storefront_outlined,
                      size: _sc(19, w), color: cyangreen),
                ),
                SizedBox(width: _sc(12, w)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showName.isEmpty ? 'Other Shows' : showName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            height: 1.25,
                            letterSpacing: 0.1,
                            color: brownText,
                            fontSize: _sc(14, w),
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: _sc(3, w)),
                      Text(
                        list.length == 1
                            ? '1 category scanned'
                            : '${list.length} categories scanned',
                        style: TextStyle(
                            height: 1.2,
                            color: textColor.withOpacity(0.6),
                            fontSize: _sc(11, w),
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Hairline under the header, indented to the text column so it reads
          // as a divider inside the card rather than a second card edge.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _sc(16, w)),
            child: Container(height: 1, color: cyangreen.withOpacity(0.08)),
          ),
          categoryGridBuilder(list, w),
        ],
      ),
    );
  }

  Widget categoryGridBuilder(List<ScannedCategoryListModel> list, double w) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
          _sc(12, w), _sc(16, w), _sc(12, w), _sc(18, w)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: _sc(8, w),
          mainAxisSpacing: _sc(14, w),
          // Circle + gap + two lines of label: sized so a one-line and a
          // two-line category still top-align across the row.
          mainAxisExtent: _sc(136, w)),
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return categoryTileBuilder(list[index], w);
      },
    );
  }

  Widget categoryTileBuilder(ScannedCategoryListModel item, double w) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_sc(14, w)),
        onTap: () {
          Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => CategoriesItemsListScreen(
                        isFromScan: false,
                        title: item.categoryName ?? '',
                        isScannedExhibitor: true,
                        categoryId: item.id ?? '',
                        showDate: '',
                        isAfterScanExhibitortorId:
                            widget.isAfterScanExhibitortorId,
                        exhibitionId: item.exhibitionId,
                      )));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: _sc(4, w)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: _sc(78, w),
                width: _sc(78, w),
                padding: EdgeInsets.all(_sc(13, w)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: white,
                  border: Border.all(color: LightPinkShade, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: LightPinkShade.withOpacity(0.25),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                // ClipOval, not the old part-rounded ClipRRect: a square-ish
                // logo was being clipped flat at the bottom inside a circle.
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: item.imageLink ?? '',
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        height: _sc(16, w),
                        width: _sc(16, w),
                        child: CircularProgressIndicator(
                            strokeWidth: 1.6, color: LightPinkShade),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                        Icons.image_not_supported_outlined,
                        size: _sc(22, w),
                        color: LightPinkShade),
                  ),
                ),
              ),
              SizedBox(height: _sc(9, w)),
              Text(
                item.categoryName ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    height: 1.25,
                    letterSpacing: 0.1,
                    fontSize: _sc(11.5, w),
                    color: textColor,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emptyStateBuilder(double w) {
    // Two different empty cases read very differently to a visitor: an empty
    // search is a dead end to back out of, no scans at all is an invitation.
    bool isSearchEmpty = _isSearching;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: _sc(88, w),
                width: _sc(88, w),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: white.withOpacity(0.7)),
                child: Icon(
                    isSearchEmpty
                        ? Icons.search_off_rounded
                        : Icons.qr_code_scanner_rounded,
                    size: _sc(40, w),
                    color: cyangreen.withOpacity(0.55)),
              ),
              SizedBox(height: _sc(18, w)),
              Text(
                isSearchEmpty ? 'No categories found' : 'Nothing scanned yet',
                style: TextStyle(
                    fontSize: _sc(16, w),
                    color: brownText,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: _sc(6, w)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _sc(50, w)),
                child: Text(
                  isSearchEmpty
                      ? 'Try a different category name.'
                      : 'Scan an exhibitor badge and they will appear here, grouped by show.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      height: 1.45,
                      fontSize: _sc(12, w),
                      color: textColor.withOpacity(0.65),
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
