import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/models/exhibitor_list_model.dart';
import 'package:event_pro/models/floor_room_model.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/view/home/exhibitorDetail/exhibitor_details.dart';
import 'package:event_pro/view/home/showDetailTabs/exhibitor_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// ignore: must_be_immutable
class FloorPlanScreen extends StatefulWidget {
  String organizationId;
  String redirectLink;
  // String showDate;
  bool isBooked;

  FloorPlanScreen({
    super.key,
    required this.isBooked,
    required this.redirectLink,
    required this.organizationId,
    // required this.showDate,
  });

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  List<FloorPlanModel> floorPlanListItems = [];
  List<ExhibitorListModel> exhibitorList = [];
  // List<OrganizerCategoryListModel> exhibitorCategoryList = [];
  ScrollController _scrollController = ScrollController();
  PhotoViewController _photoViewController = PhotoViewController();

  bool isLoading = true;
  // uday here
  // double _scale = 0.1;
  double _scale = 0.10;
  String initialFloorPlan = '';
  int index = 0;
  String floorPlanName = '';

  void _zoomIn() {
    setState(() {
      // _scale *= 1.3;
      _scale = (_scale * 1.5).clamp(0, 4.0);
      _photoViewController.scale = _scale;
      print(_scale);
    });
  }

  void _zoomOut() {
    setState(() {
      // _scale /= 1.3;
      _scale = (_scale / 1.5).clamp(0, 4); // Limit zoom to 1x
      _photoViewController.scale = _scale;
      print(_scale);
    });
  }

  var inputBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: Colors.white),
  );

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    setState(() {
      isLoading = true;
    });
    dynamic response =
        await apiValue.getOrganizerFloorPlans(context, widget.organizationId);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        floorPlanListItems =
            tempList.map((i) => FloorPlanModel.fromJson(i)).toList();
        if (floorPlanListItems.isNotEmpty) {
          floorPlanName = floorPlanListItems[index].floorName ?? '';
          initialFloorPlan = floorPlanListItems[index].imageLink ?? '';
        }
        print(floorPlanListItems.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }

    setState(() {
      isLoading = true;
    });
    dynamic exhibitorListResponse = await apiValue.getOrganizerExhibitorList(
        context, widget.organizationId, '');
    if (exhibitorListResponse != null) {
      setState(() {
        isLoading = false;
        var tempList = exhibitorListResponse as List;
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
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          shadowColor: Colors.transparent,
          // backgroundColor: Colors.transparent,
          backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (floorPlanListItems.length > 1)
                  InkWell(
                    onTap: () {
                      print(index.toString());
                      if (index != 0) {
                        print('tap');
                        setState(() {
                          index--;
                          floorPlanName =
                              floorPlanListItems[index].floorName ?? '';
                          initialFloorPlan =
                              floorPlanListItems[index].imageLink ?? '';
                          _scale = 0.1;
                        });
                      }
                    },
                    child: SizedBox(
                        width: convertFigmaToUIWidth(20, width),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: convertFigmaToUIWidth(20, width))),
                  ),
                Text(floorPlanName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: convertFigmaToUIWidth(20, width),
                        fontWeight: FontWeight.w500)),
                SizedBox(width: convertFigmaToUIWidth(15, width)),
                if (floorPlanListItems.length > 1)
                  InkWell(
                    onTap: () {
                      print(index.toString());
                      if (index != floorPlanListItems.length - 1) {
                        print('tap');
                        setState(() {
                          index++;
                          floorPlanName =
                              floorPlanListItems[index].floorName ?? '';
                          initialFloorPlan =
                              floorPlanListItems[index].imageLink ?? '';
                          _scale = 0.1;
                        });
                      }
                    },
                    child: SizedBox(
                        width: 20,
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: convertFigmaToUIWidth(20, width))),
                  ),
                SizedBox(width: 30),
              ],
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: cyangreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(convertFigmaToUIWidth(60, width) ?? 40),
            child: Container(
              width: width,
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
              decoration: BoxDecoration(
                color: cyangreen,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: Container(
                height: convertFigmaToUIWidth(40, width),
                width: width,
                padding: EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(30),
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ExhibitorListingScreen(
                          organizationId: widget.organizationId,
                          // showDate: widget.showDate,
                          catId: '',
                          isBooked: widget.isBooked,
                          title: 'Exhibitor',
                          isAutoFocus: true,
                        ),
                      ),
                    );
                  },
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.white,
                  style:
                      TextStyle(height: 1.5, fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    hintText: 'Find Exhibitor',
                    hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: convertFigmaToUIWidth(12, width),
                        fontWeight: FontWeight.w300),
                    suffixIcon:
                        Icon(Icons.search, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });
            initialPref();
          },
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : Container(
                  color: Color.fromRGBO(204, 232, 234, 0.7),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // This part will stay fixed (the floor plan image and zoom controls)
                        Column(
                          children: [
                            SizedBox(
                              height: convertFigmaToUIWidth(
                                      24, MediaQuery.of(context).size.width) ??
                                  24,
                            ),
                            Container(
                              height: convertFigmaToUIWidth(308, width),
                              width: width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                child: PhotoView(
                                  controller: _photoViewController,
                                  imageProvider: CachedNetworkImageProvider(
                                      initialFloorPlan),
                                  minScale: PhotoViewComputedScale.contained,
                                  maxScale: PhotoViewComputedScale.covered * 4,
                                  backgroundDecoration:
                                      BoxDecoration(color: Colors.white),
                                  enableRotation: true,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: convertFigmaToUIWidth(
                                      20, MediaQuery.of(context).size.width) ??
                                  20,
                            ),
                            Container(
                              width: convertFigmaToUIWidth(100, width),
                              height: convertFigmaToUIWidth(49, width),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromARGB(255, 169, 165, 165)
                                          .withOpacity(0.4),
                                      blurRadius: 20.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(0.0, 0.0))
                                ],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _zoomOut();
                                    },
                                    child: Icon(Icons.remove,
                                        size: convertFigmaToUIWidth(25, width),
                                        color: cyangreen),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _zoomIn();
                                    },
                                    child: Icon(Icons.add,
                                        size: convertFigmaToUIWidth(25, width),
                                        color: cyangreen),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: convertFigmaToUIWidth(
                                      36, MediaQuery.of(context).size.width) ??
                                  36,
                            ),
                          ],
                        ),

                        // This part will be scrollable (the tab bar and content)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  // height: 42,
                                  height: convertFigmaToUIWidth(42, width),
                                  margin: const EdgeInsets.only(
                                      left: 18, right: 18),
                                  decoration: BoxDecoration(
                                      color: lightpink.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(25)),
                                  child: TabBar(
                                    splashFactory: NoSplash.splashFactory,
                                    splashBorderRadius:
                                        BorderRadius.circular(30),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicatorWeight: 0.1,
                                    indicator: BoxDecoration(
                                        color: lightpink,
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    // labelColor: Color.fromRGBO(100, 76, 76, 1),
                                    // unselectedLabelColor:
                                    //     Color.fromRGBO(100, 76, 76, 1),
                                    labelStyle: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(12, width),
                                      fontFamily: 'Roboto',
                                      color: Color.fromRGBO(100, 76, 76, 1),
                                    ),

                                    // 👇 Font size for unselected tabs
                                    unselectedLabelStyle: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(14, width),
                                      fontFamily: 'Roboto',
                                      color: Color.fromRGBO(100, 76, 76, 1),
                                    ),
                                    dividerColor: Colors.transparent,
                                    tabs: [
                                      Tab(text: 'COMPANY'),
                                      Tab(text: 'CATEGORY')
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: convertFigmaToUIWidth(20,
                                          MediaQuery.of(context).size.width) ??
                                      20,
                                ),
                                Container(
                                  height: convertFigmaToUIWidth(280, width),
                                  child: TabBarView(
                                    // physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      // COMPANY
                                      ListView.builder(
                                        itemCount: exhibitorList.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.only(
                                          bottom: convertFigmaToUIWidth(
                                                  40, width) ??
                                              40,
                                        ),
                                        controller: _scrollController,
                                        physics: BouncingScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push<void>(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ExhibitorDetailsScreen(
                                                    exhibitorId:
                                                        exhibitorList[index]
                                                                .id ??
                                                            '',
                                                    titleName:
                                                        exhibitorList[index]
                                                                .name ??
                                                            '',
                                                    // showDate: widget.showDate,
                                                    isBooked: widget.isBooked,
                                                    exhibitionId:
                                                        widget.organizationId,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 30,
                                                  right: 20,
                                                  top: 10,
                                                  bottom: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Align(
                                                      // alignment: Alignment.center,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          textAlign:
                                                              TextAlign.left,
                                                          exhibitorList[index]
                                                                  .name ??
                                                              '',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  convertFigmaToUIWidth(
                                                                      12, width),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      100,
                                                                      76,
                                                                      76,
                                                                      1))),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      // alignment: Alignment.center,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          "   Stand no. ${exhibitorList[index].stallNo}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  convertFigmaToUIWidth(
                                                                      12, width),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      100,
                                                                      76,
                                                                      76,
                                                                      1))),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Align(
                                                    // alignment: Alignment.center,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        "${exhibitorList[index].category ?? ''}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            fontSize:
                                                                convertFigmaToUIWidth(
                                                                    12, width),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Color.fromRGBO(
                                                                    100,
                                                                    76,
                                                                    76,
                                                                    1))),
                                                  )),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // CATEGORY
                                      ListView.builder(
                                        itemCount: exhibitorList.length,
                                        shrinkWrap: true,
                                        controller: _scrollController,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          List<ExhibitorListModel> ListItems =
                                              exhibitorList;
                                          ListItems.sort((a, b) => a.category
                                              .toString()
                                              .toLowerCase()
                                              .compareTo(b.category
                                                  .toString()
                                                  .toLowerCase()));

                                          return Padding(
                                            padding: EdgeInsets.only(
                                                left: 30,
                                                right: 20,
                                                top: 10,
                                                bottom: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push<void>(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ExhibitorListingScreen(
                                                            organizationId: widget
                                                                .organizationId,
                                                            catId: ListItems[
                                                                        index]
                                                                    .categoryId ??
                                                                '',
                                                            isBooked:
                                                                widget.isBooked,
                                                            title: ListItems[
                                                                        index]
                                                                    .category ??
                                                                '',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          ListItems[index]
                                                                  .category ??
                                                              '',
                                                          textAlign: TextAlign
                                                              .left,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  convertFigmaToUIWidth(
                                                                      12,
                                                                      width),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      100,
                                                                      76,
                                                                      76,
                                                                      1))),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push<void>(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ExhibitorDetailsScreen(
                                                            exhibitorId:
                                                                ListItems[index]
                                                                        .id ??
                                                                    '',
                                                            titleName:
                                                                ListItems[index]
                                                                        .name ??
                                                                    '',
                                                            isBooked:
                                                                widget.isBooked,
                                                            exhibitionId: widget
                                                                .organizationId,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          "${ListItems[index].name ?? ''}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  convertFigmaToUIWidth(
                                                                      12, width),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      100,
                                                                      76,
                                                                      76,
                                                                      1))),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        "   Stand no. ${ListItems[index].stallNo}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            fontSize:
                                                                convertFigmaToUIWidth(
                                                                    12, width),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Color.fromRGBO(
                                                                    100,
                                                                    76,
                                                                    76,
                                                                    1))),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
