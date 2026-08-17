import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/data/remote/get_user_data.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:flutter/material.dart';

class VisitorBadgeScreen extends StatefulWidget {
  VisitorBadgeScreen({super.key});

  @override
  State<VisitorBadgeScreen> createState() => _VisitorBadgeScreenState();
}

class _VisitorBadgeScreenState extends State<VisitorBadgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    debugPrint("Tickets:- ${constant.ticketArr}");
    // Call the async function without awaiting it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPref();
    });
  }

  Future<void> initPref() async {
    await GetUserData().getUserDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;

    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 1,
      child: WillPopScope(
        onWillPop: () async {
          // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          // return false; // prevent default pop
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Colors.transparent,
            backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            scrolledUnderElevation: 0,
            elevation: 0,
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, '/home', (route) => false);
                },
                child: Icon(Icons.arrow_back, color: Colors.white)),
            title: Text("My Badge",
                style: TextStyle(
                    fontSize: convertFigmaToUIWidth(20, width),
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            flexibleSpace: Container(
              height: convertFigmaToUIWidth(200, width) ?? 200,
              decoration: BoxDecoration(
                color: cyangreen,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
              ),
            ),
            bottom: PreferredSize(
              preferredSize:
                  Size.fromHeight(convertFigmaToUIWidth(350, width) ?? 350),
              child: Container(
                height: convertFigmaToUIWidth(350, width) ?? 350,
                width: size.width,
                color: Colors.transparent,
                child: Column(
                  // alignment: Alignment.topCenter,
                  children: [
                    getCircularImageWidget(
                        convertFigmaToUIWidth(230, width) ?? 230,
                        constant.imageLinkValue,
                        white,
                        cyangreen,
                        55,
                        getNameInitials(constant.nameValue)),
                    // SizedBox(height: convertFigmaToUIWidth(16, width)),
                    Spacer(),
                    // Name and Details
                    Column(
                      children: [
                        Text(
                          constant.nameValue,
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(25, width),
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(85, 85, 85, 1)),
                        ),
                        SizedBox(height: convertFigmaToUIWidth(10, width)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            constant.weddingRoleValue.toString() == 'null' ||
                                    constant.weddingRoleValue == ''
                                ? Text(
                                    "",
                                    style: TextStyle(
                                        fontSize: convertFigmaToUIWidth(15, width),
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromRGBO(2, 141, 148, 1)),
                                  )
                                : Text(
                                    "${constant.weddingRoleValue} | ",
                                    style: TextStyle(
                                        fontSize: convertFigmaToUIWidth(15, width),
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromRGBO(2, 141, 148, 1)),
                                  ),
                            Text(
                              DateFormatter.formatDayWithSuffix(
                                          constant.expectedDateValue) ==
                                      ''
                                  ? ''
                                  : DateFormatter.formatDayWithSuffix(
                                      constant.expectedDateValue),
                              style: TextStyle(
                                  fontSize: convertFigmaToUIWidth(15, width),
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(85, 85, 85, 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(204, 232, 234, 0.7),
            ),
            child: Column(
              children: [
                SizedBox(height: convertFigmaToUIWidth(10, width)),
                Container(
                  height: convertFigmaToUIWidth(42, width),
                  margin: const EdgeInsets.only(left: 18, right: 18),
                  decoration: BoxDecoration(
                    color: lightpink.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    splashFactory: NoSplash.splashFactory,
                    splashBorderRadius: BorderRadius.circular(30),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 0.1,
                    indicator: BoxDecoration(
                      color: lightpink,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Color.fromRGBO(100, 76, 76, 1),
                    unselectedLabelColor: Color.fromRGBO(100, 76, 76, 1),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'Badge'),
                      Tab(text: 'Ticket'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Badge Tab Content
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: convertFigmaToUIWidth(15, width)),
                            Container(
                              width: convertFigmaToUIWidth(237, width),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              child: CachedNetworkImage(
                                imageUrl: constant.qrCodeValue,
                                errorWidget: (context, url, error) => Container(
                                  height: convertFigmaToUIWidth(20, width),
                                  width: convertFigmaToUIWidth(20, width),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade300),
                                  child: Center(
                                      child:
                                          Icon(Icons.error_outline, size: 45)),
                                ),
                              ),
                            ),
                            SizedBox(height: convertFigmaToUIWidth(40, width)),
                            Container(
                              height: convertFigmaToUIWidth(42, width),
                              width: size.width,
                              color: cyangreen,
                              child: Center(
                                  child: Text('Visitor',
                                      style: TextStyle(
                                         
                                          fontSize:
                                              convertFigmaToUIWidth(19, width),
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                            ),
                            SizedBox(height: convertFigmaToUIWidth(100, width)),
                          ],
                        ),
                      ),

                      
                      // Ticket Tab Content
                      constant.ticketArr.isEmpty
                          ? Center(
                              child: Text(
                                'No tickets available',
                                style: TextStyle(
                                  fontSize: convertFigmaToUIWidth(15, width),
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(85, 85, 85, 1),
                                ),
                              ),
                            )
                          : ListView.separated(
                              

                              separatorBuilder: (context, index) => SizedBox(
                                  height: convertFigmaToUIWidth(10, width)),
                              padding: EdgeInsets.only(
                                  top: 15,
                                  bottom: 100), // Increased bottom padding
                              itemCount: constant.ticketArr.length + 1,
                              itemBuilder: (ctx, index) {
                                if (index == constant.ticketArr.length) {
                                  return SizedBox(
                                      height: convertFigmaToUIWidth(
                                          80, width)); // Keep existing spacer
                                }

                                final ticket = constant.ticketArr[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  child: Column(
                                    children: [
                                      // Display showName and showDate
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            ticket['showName'] ??
                                                'No Show Name',
                                            style: TextStyle(
                                                fontSize: convertFigmaToUIWidth(
                                                  15, width
                                                ),
                                                fontWeight: FontWeight.w600,
                                                color: Color.fromRGBO(
                                                    85, 85, 85, 1)),
                                          ),
                                          SizedBox(
                                              height: convertFigmaToUIWidth(
                                                  5, width)),
                                          Text(
                                            DateFormatter.formatDayWithSuffix(
                                                ticket['showDate']
                                                        ?.toString() ??
                                                    ''),
                                            style: TextStyle(
                                              fontSize: convertFigmaToUIWidth(
                                                  15, width
                                                ),
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  Color.fromRGBO(85, 85, 85, 1),
                                            ),
                                          ),
                                          // A visitor who bought several tickets
                                          // for one show gets one card per ticket,
                                          // each with its own QR - without this
                                          // label the cards look identical and
                                          // there's no way to tell how many they
                                          // hold or which one has been scanned.
                                          if ((int.tryParse(ticket['ticketCount']
                                                      ?.toString() ??
                                                  '1') ??
                                              1) >
                                              1) ...[
                                            SizedBox(
                                                height: convertFigmaToUIWidth(
                                                    5, width)),
                                            Text(
                                              'Ticket ${ticket['ticketNo'] ?? 1} of ${ticket['ticketCount']}',
                                              style: TextStyle(
                                                fontSize: convertFigmaToUIWidth(
                                                    13, width),
                                                fontWeight: FontWeight.w600,
                                                color: Color.fromRGBO(
                                                    136, 136, 136, 1),
                                              ),
                                            ),
                                          ],
                                          // A buyer sees every ticket on their
                                          // order, including the ones issued to
                                          // the other people they booked for.
                                          // Name the holder on EVERY card so a
                                          // buyer of 2 sees their own name on
                                          // one and the co-visitor they entered
                                          // at purchase on the other, and knows
                                          // which QR to hand to whom.
                                          if ((ticket['ticketHolder']
                                                      ?.toString() ??
                                                  '')
                                              .isNotEmpty) ...[
                                            SizedBox(
                                                height: convertFigmaToUIWidth(
                                                    5, width)),
                                            Text(
                                              'For ${ticket['ticketHolder']}',
                                              style: TextStyle(
                                                fontSize: convertFigmaToUIWidth(
                                                    13, width),
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromRGBO(
                                                    136, 136, 136, 1),
                                              ),
                                            ),
                                          ],
                                          SizedBox(
                                              height: convertFigmaToUIWidth(
                                                  15, width)),
                                        ],
                                      ),
                                      // Display ticketQR image
                                      Center(
                                        child: Container(
                                          width: convertFigmaToUIWidth(237, width),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: ticket['ticketQR'],
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              width: convertFigmaToUIWidth(5, width),
                                              height: convertFigmaToUIWidth(
                                                  20, width),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.grey.shade300,
                                              ),
                                              child: Center(
                                                child: Icon(Icons.error_outline,
                                                    size: convertFigmaToUIWidth(
                                                        45, width)),
                                              ),
                                            ),
                                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
