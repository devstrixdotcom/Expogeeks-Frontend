import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

PreferredSizeWidget appBarWithSearchField(
  BuildContext context,
  controller,
  String hintText,
  String title,
  bool isBackButton,
  onChanged, {
  bool isHomePage = false,
  bool isAutoFocus = false,
  bool isExhibitorFeedbackListScreenafterScan = false,
}) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  Size size = MediaQuery.of(context).size;
  return AppBar(
    scrolledUnderElevation: 0,
    elevation: 0,
    // shadowColor: Colors.transparent,
    // backgroundColor: Colors.transparent,
    backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    automaticallyImplyLeading: false,
    leading: isHomePage
        ? SizedBox()
        : isBackButton
            ? InkWell(
                onTap: () {
                  SystemNavigator.pop();
                },
                child: Icon(Icons.arrow_back, color: Colors.white))
            : isExhibitorFeedbackListScreenafterScan
                ? InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/menu');
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  )
                : InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
    title: Text(title,
        style: TextStyle(
            fontSize: convertFigmaToUIWidth(20, width),
            fontWeight: FontWeight.w700,
            color: Colors.white)),
    flexibleSpace: Container(
        decoration: BoxDecoration(
            color: cyangreen,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)))),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(convertFigmaToUIWidth(60, width) ?? 60),
      child: Container(
        width: width,
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
        decoration: BoxDecoration(
            color: cyangreen,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        child: TextField(
          autofocus: isAutoFocus,
          onChanged: onChanged,
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: Colors.white,
          style: TextStyle(height: 1.5, fontSize: 13, color: Colors.white),
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Color.fromRGBO(255, 255, 255, 0.1),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white, width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white, width: 1)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white, width: 1)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white, width: 1)),
            isDense: true,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            constraints:
                BoxConstraints(maxHeight:
                convertFigmaToUIWidth(40, width) ?? 40,
                
                minWidth: width),
            labelText: hintText,
            labelStyle: TextStyle(
                color: Colors.white,
                fontSize: convertFigmaToUIWidth(12, width), 
                fontWeight: FontWeight.w300),
            suffixIcon:
                Icon(Icons.search, color: Colors.white, 
                
                size:
                convertFigmaToUIWidth(20, width)                
                ),
          ),
        ),
      ),
    ),
  );
}

PreferredSizeWidget normalAppBarBuilder(String title, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  Size size = MediaQuery.of(context).size;
  return AppBar(
    scrolledUnderElevation: 0,
    elevation: 0,
    shadowColor: Colors.transparent,
    // backgroundColor: Colors.transparent, // Make AppBar transparent
    backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    title: Text(title,
        style: TextStyle(
            fontSize: convertFigmaToUIWidth(20, width),
            fontWeight: FontWeight.w700,
            color: Colors.white)),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: cyangreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
    ),
    bottom:
        PreferredSize(preferredSize: Size.fromHeight(10), child: SizedBox()),
  );
}
