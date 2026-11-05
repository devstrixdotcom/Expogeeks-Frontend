import 'package:event_pro/scanner/data/remote/api_value.dart';
import 'package:event_pro/scanner/view/base_screen.dart';
import 'package:event_pro/scanner/utils/basic_route.dart';
import 'package:event_pro/scanner/utils/color.dart';
import 'package:flutter/material.dart';

import '../../models/visitor_listItem.dart';
import '../../utils/images.dart';
import 'scan_qr_screen.dart';

class ScannedVisitorsScreen extends StatefulWidget {
  final String exhibitionId;
  final String showName;
  ScannedVisitorsScreen({
    super.key,
    required this.exhibitionId,
    required this.showName,
  });

  @override
  State<ScannedVisitorsScreen> createState() => _ScannedVisitorsScreenState();
}

class _ScannedVisitorsScreenState extends State<ScannedVisitorsScreen> {
  List<VisitorListItem> showsListItems = [];
  bool isLoading = true;

  Future<bool> onWillPop(BuildContext context) async {
    await fetchScannedList();
    return true;
  }

  @override
  void initState() {
    super.initState();
    fetchScannedList();
  }

  Future<void> fetchScannedList() async {
    setState(() {
      isLoading = true;
    });

    dynamic response = await apiValue.getExhibitionAttendanceList(
      context,
      widget.exhibitionId,
    );

    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        showsListItems =
            tempList.map((i) => VisitorListItem.fromJson(i)).toList();
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void refreshScannedList() {
    fetchScannedList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
            title: Text('Scanned Visitors'),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            scrolledUnderElevation: 0,
            elevation: 0,
            flexibleSpace: Container(
              height: size.height * 0.21,
              decoration: BoxDecoration(
                color: cyangreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          body:
              isLoading
                  ? Center(child: CircularProgressIndicator(color: cyangreen))
                  : Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(
                          convertFigmaWidthToUI(20, width) ?? 20,
                          
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: convertFigmaWidthToUI(220, width),
                              child: Text(
                                widget.showName,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis, // Adds ... if text exceeds 2 lines
                                style: TextStyle(
                                  fontSize:
                                      convertFigmaWidthToUI(18, width) ?? 18,
                                  fontWeight: FontWeight.bold,
                                  color: cyangreen,
                                ),
                              ),
                            ),
                            Text(
                              // "Total: 2000",
                              "Total Visitors: ${showsListItems.length.toString()}",
                              style: TextStyle(
                                fontSize:
                                    convertFigmaWidthToUI(18, width) ?? 18,
                                fontWeight: FontWeight.bold,
                                color: cyangreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: showsListItems.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: white,
                              margin: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left side - Text content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            showsListItems[index].name,
                                            style: TextStyle(
                                              height: 1.5,
                                              color: textColor,
                                              fontSize:
                                                  convertFigmaWidthToUI(
                                                    18,
                                                    width,
                                                  ) ??
                                                  18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: convertFigmaWidthToUI(
                                              8,
                                              width,
                                            ),
                                          ),
                                          Text(
                                            showsListItems[index].email,
                                            style: TextStyle(
                                              height: 1.5,
                                              color: textColor.withOpacity(0.8),
                                              fontSize:
                                                  convertFigmaWidthToUI(
                                                    16,
                                                    width,
                                                  ) ??
                                                  16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            height: convertFigmaWidthToUI(
                                              8,
                                              width,
                                            ),
                                          ),
                                          // display email and mobile in single Text
                                          Text(
                                            showsListItems[index].countryCode +
                                                " " +
                                                showsListItems[index].mobile,
                                            //  showsListItems[index].mobile,
                                            style: TextStyle(
                                              height: 1.5,
                                              color: textColor.withOpacity(0.8),
                                              fontSize:
                                                  convertFigmaWidthToUI(
                                                    16,
                                                    width,
                                                  ) ??
                                                  16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right side - QR code
                                    Container(
                                      margin: EdgeInsets.only(left: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.network(
                                        showsListItems[index].qrCode,
                                        width: convertFigmaWidthToUI(
                                          100,
                                          width,
                                        ),
                                        height: convertFigmaWidthToUI(
                                          100,
                                          width,
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ScanQRScreen(exhibitionId: widget.exhibitionId),
                ),
              ).then((shouldRefresh) {
                if (shouldRefresh != null && shouldRefresh) {
                  setState(() {
                    // fetchScannedList();
                    refreshScannedList();
                  });
                }
              });
            },
            backgroundColor: cyangreen,
            child: Image.asset(
              scannerIcon,
              height: convertFigmaWidthToUI(24, width),
              width: convertFigmaWidthToUI(24, width),
            ),
          ),
          // backgroundColor: Colors.white,
          backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
        ),
      ),
    );
  }
}
