import 'package:event_pro/scanner/data/local/shared_pref_helper.dart';
import 'package:event_pro/scanner/view/scanner/scanned_visitors_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/local/contants.dart';
import '../../data/remote/api_value.dart';
import '../../models/organization_list_item_model.dart';
import '../../sharedwidget/home_card_details.dart';
import '../../utils/basic_route.dart';
import '../../utils/color.dart';
import '../../utils/helper_functions.dart';
import 'package:event_pro/view/authScreen/login_screen.dart';
import '../base_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<OrganizationListItems> showsListItems = [];
  bool isLoading = true;

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
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    bool isLoggedIn = await SharedPreferencesHelper.getIsLoggedIn();

    if (!isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  initialPref(String typePara) async {
    dynamic response = await apiValue.getOrganizerExhibitionList(
      context,
      typePara,
    );
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

  @override
  Widget build(BuildContext context) {
    
    var width = MediaQuery.of(context).size.width;
    return BaseScreen(
      selectedIndex: 0,
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      child: WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Exhibitions'),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            scrolledUnderElevation: 0,
            elevation: 0,
            flexibleSpace: Container(
              height: convertFigmaToUIWidth(150, width),
              decoration: BoxDecoration(
                color: cyangreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: IconButton(
                  icon: Icon(
                    Icons.logout,
                    size: convertFigmaToUIWidth(24, width),
                  ),

                  onPressed: () {
                    // Show confirmation dialog on logout button tap
                    showDialog(
                      context: context,
                      builder: (context) {
                        // Define the "Yes" button
                        Widget yesButton = ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              cyangreen,
                            ),
                          ),
                          child: const Text("Yes"),
                          onPressed: () {
                            // Expire login session
                            SharedPreferencesHelper.clearShareCache();
                            constant.userToken = "";
                            constant.userId = "";
                            constant.nameValue = "";
                            constant.emailValue = "";
                            // Back to the login screen, clearing
                            // the scanner screens from the back stack.
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                        );

                        // Define the "Cancel" button
                        Widget cancelButton = ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              cyangreen,
                            ),
                          ),
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(
                              context,
                            ); // Close the dialog without action
                          },
                        );

                        // Return the AlertDialog
                        return AlertDialog(
                          title: Text("Logout!"),
                          content: Text(
                            "Are you sure you want to log out?",
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            cancelButton,
                            yesButton,
                          ], // Add buttons here
                          elevation: 5,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          body:
              isLoading
                  ? Center(child: CircularProgressIndicator(color: cyangreen))
                  : showsListItems.isEmpty
                  ? Center(
                    child: Text(
                      "Show is not available!",
                      style: TextStyle(
                        fontSize: convertFigmaToUIWidth(18, width),
                        color: cyangreen,
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              isLoading = true;
                            });
                            initialPref('');
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: showsListItems.length,
                            itemBuilder: (context, index) {
                              OrganizationListItems showsListValues =
                                  showsListItems[index];

                              List<OrganizationListItems> list = showsListItems;

                              return Padding(
                                padding: EdgeInsets.only(
                                  top: index == 0 ? convertFigmaToUIWidth(20, width) ?? 20 : 0,
                                  bottom:
                                      index == list.length - 1
                                          ? convertFigmaToUIWidth(20, width) ?? 20
                                          : 0,
                                ),
                                child: ShowsDetailsCard(
                                  showName: showsListValues.showName ?? '',
                                  address: showsListValues.location ?? '',
                                  date:
                                      showsListValues.dateList!.length == 1
                                          ? showsListValues.showStartDate ?? ''
                                          : showsListValues.dateList == null
                                          ? showsListValues.showStartDate ?? ''
                                          // : "${showsListValues.dateList![0].showDate ?? ''} - ${showsListValues.dateList![showsListValues.dateList!.length - 1].showDate ?? ''}",
                                          : "${DateFormatter.formatDayWithSuffix(showsListValues.dateList![0].showDate ?? '')} - ${DateFormatter.formatDayWithSuffix(showsListValues.dateList![showsListValues.dateList!.length - 1].showDate ?? '')}",
                                  img: showsListValues.imageLink ?? '',
                                  isBooked:
                                      showsListValues.isBooked == 'false'
                                          ? false
                                          : true,
                                  onpressed: () {
                                    // Here we pass the selected exhibition ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ScannedVisitorsScreen(
                                              exhibitionId:
                                                  showsListValues.id ?? '',
                                              showName:
                                                  showsListValues.showName ??
                                                  '',
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
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
                backgroundColor: MaterialStatePropertyAll(cyangreen),
              ),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(cyangreen),
              ),
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
