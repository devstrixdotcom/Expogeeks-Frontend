import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/models/organization_list_item_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/home_card_details.dart';
import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:event_pro/view/home/showDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/helper_functions.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<OrganizationListItems> showsListItems = [];
  List<OrganizationListItems> searchResult = [];
  bool _isSearching = false;
  bool isLoading = true;
  String type = '';

  var inputBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: Colors.white),
  );

  Future<bool> onWillPop(BuildContext context) {
    showExitApp(context);
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    initialPref('');
  }

  initialPref(String typePara) async {
    dynamic response = await apiValue.getOrganizersList(context, typePara);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        showsListItems =
            tempList.map((i) => OrganizationListItems.fromJson(i)).toList();
        print(showsListItems.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  void searchCustomerList(String text) {
    setState(() {
      final query = text.trim().toLowerCase();
      searchResult = showsListItems.where((item) {
        final showName = item.showName?.toLowerCase() ?? '';
        final location = item.location?.toLowerCase() ?? '';
        return showName.contains(query) || location.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    

    return BaseScreen(
      selectedIndex: 0,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Scaffold(
          // backgroundColor: Colors.transparent,
          appBar: appBarWithSearchField(
            context,
            _searchController,
            'Find Shows',
            "Explore",
            true,
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
            },
            isHomePage: true,
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(204, 232, 234, 0.7),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: width,
                        margin: EdgeInsets.only(left: 15, right: 15, top: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          ],
                        ),
                      ),
                      

                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              isLoading = true;
                            });
                            initialPref('');
                          },
                          child: showsListItems.isEmpty
                              ? Center(
                                  child: Text(
                                    // "No Events Available",
                                    _getEmptyMessage(type),
                                    style: TextStyle(
                                      // fontSize: 18,
                                      fontSize:
                                          convertFigmaToUIWidth(18, width),
                                      color: cyangreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                padding: EdgeInsets.only(bottom: convertFigmaToUIWidth(30, width) ?? 30),
                                  shrinkWrap: true,
                                  itemCount: _isSearching
                                      ? searchResult.length
                                      : showsListItems.length,
                                  itemBuilder: (context, index) {
                                    OrganizationListItems showsListValues =
                                        _isSearching
                                            ? searchResult[index]
                                            : showsListItems[index];

                                    List<OrganizationListItems> list =
                                        _isSearching
                                            ? searchResult
                                            : showsListItems;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        top: index == 0
                                            ? convertFigmaToUIWidth(
                                                    10,
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) ??
                                                10
                                            : 0,
                                        bottom: index == list.length - 1
                                            ? convertFigmaToUIWidth(
                                                    86,
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) ??
                                                86
                                            : 0,
                                      ),
                                      child: ShowsDetailsCard(
                                        showName:
                                            showsListValues.showName ?? '',
                                        address: showsListValues.location ?? '',
                                        date: showsListValues
                                                    .dateList!.length ==
                                                1
                                            ? showsListValues.showStartDate ??
                                                ''
                                            : showsListValues.dateList == null
                                                ? showsListValues
                                                        .showStartDate ??
                                                    ''
                                                : "${showsListValues.dateList![0].showDate ?? ''} - ${showsListValues.dateList![showsListValues.dateList!.length - 1].showDate}",
                                        // : "${DateFormatter.formatDayWithSuffix(showsListValues.dateList![0].showDate ?? '')} - ${DateFormatter.formatDayWithSuffix(showsListValues.dateList![showsListValues.dateList!.length - 1].showDate ?? '')}",
                                        img: showsListValues.imageLink ?? '',
                                        isBooked:
                                            showsListValues.isBooked == 'false'
                                                ? false
                                                : true,
                                        onpressed: () {
                                          Navigator.push<void>(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (BuildContext context) =>
                                                  ShowDetails(
                                                startDate: showsListValues
                                                            .dateList ==
                                                        null
                                                    ? showsListValues
                                                            .showStartDate ??
                                                        ''
                                                    : showsListValues
                                                            .dateList![0]
                                                            .showDate ??
                                                        '',
                                                startTime: showsListValues
                                                            .dateList ==
                                                        null
                                                    ? ''
                                                    : "${showsListValues.dateList![0].startTime ?? ''} - ${showsListValues.dateList![0].endTime ?? ''}",
                                                endDate: showsListValues
                                                            .dateList!.length ==
                                                        1
                                                    ? ''
                                                    : showsListValues
                                                                .dateList ==
                                                            null
                                                        ? ''
                                                        : showsListValues
                                                                .dateList![showsListValues
                                                                        .dateList!
                                                                        .length -
                                                                    1]
                                                                .showDate ??
                                                            '',
                                                endTime: showsListValues
                                                            .dateList!.length ==
                                                        1
                                                    ? ''
                                                    : showsListValues
                                                                .dateList ==
                                                            null
                                                        ? ''
                                                        : "${showsListValues.dateList![showsListValues.dateList!.length - 1].startTime ?? ''} - ${showsListValues.dateList![showsListValues.dateList!.length - 1].endTime ?? ''}",
                                                organizationId:
                                                    showsListValues.id ?? '',
                                                titleName:
                                                    showsListValues.showName ??
                                                        '',
                                                isbooked:
                                                    showsListValues.isBooked ==
                                                            'false'
                                                        ? false
                                                        : true,
                                              ),
                                            ),
                                          ).then((value) {
                                            initialPref('');
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
        ),
      ),
    );
  }

  showExitApp(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Are you sure you want to exit the app?'),
            actions: <Widget>[
              
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(cyangreen)),
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(cyangreen)),
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.of(context).pop();
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        });
  }

  String _getEmptyMessage(String type) {
    switch (type) {
      case 'exhibition':
        return 'No Events Available';
      case 'music':
        return 'No Events Available';
      case 'event':
        return 'No Events Available';
      case 'blog':
        return 'No Blog Available';
      default:
        return 'No Events Available';
    }
  }
}
