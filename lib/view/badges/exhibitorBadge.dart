import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:flutter/material.dart';

class ExhibitorBadgeScreen extends StatefulWidget {
  ExhibitorBadgeScreen({super.key});

  @override
  State<ExhibitorBadgeScreen> createState() => _ExhibitorBadgeScreenState();
}

class _ExhibitorBadgeScreenState extends State<ExhibitorBadgeScreen> {
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
            // backgroundColor: Colors.transparent,
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
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
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
                  Size.fromHeight(convertFigmaToUIWidth(260, width) ?? 260),
              child: Container(
                height: convertFigmaToUIWidth(260, width),

                // width: size.width,
                width: convertFigmaToUIWidth(width, width),
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      child: getCircularImageWidget(
                        convertFigmaToUIWidth(200, width) ?? 200,
                        constant.circularImageLinkValue,
                        white,
                        cyangreen,
                        55,
                        getNameInitials(constant.exhibitorCompanyName),
                      ),
                    ),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          constant.exhibitorCompanyName,
                          style: TextStyle(
                              
                              fontSize: convertFigmaToUIWidth(21, width),
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(2, 141, 148, 1)),
                        ),
                        // SizedBox(height: 7),
                        SizedBox(height: convertFigmaToUIWidth(7, width)),
                        Text(
                          constant.exhibitorCategory,
                          style: TextStyle(
                              
                              fontSize: convertFigmaToUIWidth(17, width),
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(85, 85, 85, 1)),
                        ),
                        
                        SizedBox(height: convertFigmaToUIWidth(10, width)),
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
                                  child: Icon(Icons.error_outline, size: 45)),
                            ),
                          ),
                        ),
                        SizedBox(height: convertFigmaToUIWidth(10, width)),
                        Text(
                          constant.nameValue,
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(19, width),
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(85, 85, 85, 1)),
                        ),
                        SizedBox(height: convertFigmaToUIWidth(30, width)),
                        Container(
                          height: convertFigmaToUIWidth(42, width),
                          width: size.width,
                          color: cyangreen,
                          child: Center(
                              child: Text('Exhibitor',
                                  style: TextStyle(
                                     
                                      fontSize:
                                          convertFigmaToUIWidth(19, width),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white))),
                        ),
                        // SizedBox(height: 100),
                        SizedBox(height: convertFigmaToUIWidth(100, width)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
