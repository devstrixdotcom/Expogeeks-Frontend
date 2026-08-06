import 'dart:io';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class ViewImageScreen extends StatelessWidget {
  final String path;
  ViewImageScreen({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("View Image", style: TextStyle(height: 1.5, 
        fontSize: 
        convertFigmaToUIWidth(20, width), 
        fontWeight: FontWeight.w600, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: cyangreen,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
        bottom: PreferredSize(preferredSize: Size.fromHeight(10), child: SizedBox()),
      ),
      body: Container(
        color: Color.fromRGBO(204, 232, 234, 0.7),
        child: Center(child: Image(image: FileImage(File(path)))),
      ),
    );
  }
}
