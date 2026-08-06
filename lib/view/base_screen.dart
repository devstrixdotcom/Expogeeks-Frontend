
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/view/menuScreens/common/my_profile.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class BaseScreen extends StatefulWidget {
  final int selectedIndex;
  final Widget child;
  final ValueChanged<int> onItemSelected;

  BaseScreen(
      {required this.selectedIndex,
      required this.child,
      required this.onItemSelected});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  Color DarkGreen = Color(0xff028D94);
  Color lightGreen = Color.fromRGBO(204, 232, 234, 1);
  Color mainColor = Color.fromRGBO(204, 232, 234, 0.7);
  String selectedValue = '';
  bool isShowMenu = false;
  double myBadgeIconScale = 1;
  double scanerIconScale = 1;

  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex == 3) {
      isShowMenu = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;

    ///
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    TextStyle navBarLabelStyle0 = TextStyle(
        color: Color(0xff028D94),
        fontSize: convertFigmaToUIWidth(12, width),
        fontWeight: (widget.selectedIndex == 0 && !isShowMenu)
            ? FontWeight.bold
            : FontWeight.normal);
    TextStyle navBarLabelStyle1 = TextStyle(
        color: Color(0xff028D94),
        fontSize: convertFigmaToUIWidth(12, width),
        fontWeight: (widget.selectedIndex == 1 && !isShowMenu)
            ? FontWeight.bold
            : FontWeight.normal);
    TextStyle navBarLabelStyle2 = TextStyle(
        color: Color(0xff028D94),
        fontSize: convertFigmaToUIWidth(12, width),
        fontWeight: (widget.selectedIndex == 2 && !isShowMenu)
            ? FontWeight.bold
            : FontWeight.normal);
    TextStyle navBarLabelStyle3 = TextStyle(
        color: Color(0xff028D94),
        fontSize: convertFigmaToUIWidth(12, width),
        fontWeight: (isShowMenu) ? FontWeight.bold : FontWeight.normal);

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            widget.child,
            isKeyboardVisible
                ? SizedBox()
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: convertFigmaToUIWidth(86, width) ?? 0,
                      width: width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              if (constant.nameValue == '') {
                                showToast('Please add name');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MyProfileScreen()));
                                return;
                              }
                              if (widget.selectedIndex != 0) {
                                print("------------");
                                setState(() {
                                  isShowMenu = false;
                                  widget.onItemSelected(0);
                                });
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_filled,
                                  color: DarkGreen,
                                  size: convertFigmaToUIWidth(30, width) ?? 0,
                                ),
                                Text("Home", style: navBarLabelStyle0),
                                (widget.selectedIndex == 0 && !isShowMenu)
                                    ? SizedBox(
                                        // height: 10,
                                        // width: 10,
                                        height:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                        width:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                        child: Divider(
                                            color: DarkGreen, thickness: 2))
                                    : SizedBox(
                                        height:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                        width:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                      ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (constant.nameValue == '') {
                                    showToast('Please add name');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyProfileScreen()));
                                    return;
                                  }
                                  if (widget.selectedIndex != 1) {
                                    setState(() {
                                      myBadgeIconScale = 1.0;
                                      widget.onItemSelected(1);
                                      isShowMenu = false;
                                    });
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_filled,
                                      color: Colors.transparent,
                                      size:
                                          convertFigmaToUIWidth(30, width) ?? 0,
                                    ),
                                    Text("My Badge", style: navBarLabelStyle1),
                                    (widget.selectedIndex == 1 && !isShowMenu)
                                        ? SizedBox(
                                            // height: 10,
                                            // width: 10,
                                            height: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                            width: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                            child: Divider(
                                                color: DarkGreen, thickness: 2))
                                        : SizedBox(
                                            height: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                            width: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                          ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: convertFigmaToUIWidth(20, width) ?? 0,
                              ),
                              InkWell(
                                onTap: () {
                                  if (constant.nameValue == '') {
                                    showToast('Please add name');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyProfileScreen()));
                                    return;
                                  }
                                  if (widget.selectedIndex != 2) {
                                    setState(() {
                                      scanerIconScale = 1.0;
                                      widget.onItemSelected(2);
                                      isShowMenu = false;
                                    });
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_filled,
                                      color: Colors.transparent,
                                      size:
                                          convertFigmaToUIWidth(30, width) ?? 0,
                                    ),
                                    Text("Scan QR", style: navBarLabelStyle2),
                                    (widget.selectedIndex == 2 && !isShowMenu)
                                        ? SizedBox(
                                            // height: 10,
                                            // width: 10,
                                            height: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                            width: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                            child: Divider(
                                                color: DarkGreen, thickness: 2))
                                        : SizedBox(
                                            height: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                            width: convertFigmaToUIWidth(
                                                    10, width) ??
                                                0,
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isShowMenu = false;
                                widget.onItemSelected(3);
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu,
                                  color: DarkGreen,
                                  size: convertFigmaToUIWidth(30, width) ?? 0,
                                ),
                                Text("Menu", style: navBarLabelStyle3),
                                (widget.selectedIndex == 3)
                                    ? SizedBox(
                                        // height: 10,
                                        // width: 10,
                                        height:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                        width:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                        child: Divider(
                                            color: DarkGreen, thickness: 2))
                                    : SizedBox(
                                        height:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                        width:
                                            convertFigmaToUIWidth(10, width) ??
                                                0,
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
        floatingActionButton: isKeyboardVisible
            ? SizedBox() // When the keyboard is visible, show an empty SizedBox
            : Container(
                margin: EdgeInsets.only(
                  bottom: Platform.isIOS
                      ? convertFigmaToUIWidth(86, width)! -( convertFigmaToUIWidth(47, width)!/2)-10
                      : (convertFigmaToUIWidth(55, width) ?? 0),
                ),

                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    // color: Color.fromRGBO(204, 232, 234, 1),
                    color: Color.fromRGBO(204, 232, 234, 1),
                    borderRadius: BorderRadius.circular(30)),

                child: Container(
                  height: convertFigmaToUIWidth(47, width) ?? 0,
                  width: convertFigmaToUIWidth(176, width) ?? 0,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTapDown: (_) {
                          setState(() {
                            myBadgeIconScale = 0.95;
                          });
                        },
                        onTapUp: (_) {
                          if (constant.nameValue == '') {
                            showToast('Please add name');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyProfileScreen()));
                            return;
                          }
                          if (widget.selectedIndex != 1) {
                            setState(() {
                              myBadgeIconScale = 1.0;
                              widget.onItemSelected(1);
                              isShowMenu = false;
                            });
                          }
                        },
                        onTapCancel: () {
                          setState(() {
                            myBadgeIconScale = 1.0;
                          });
                        },
                        onTap: () {},
                        child: AnimatedScale(
                          scale: myBadgeIconScale,
                          duration: Duration(milliseconds: 10),
                          child: Container(
                            height: convertFigmaToUIWidth(47, width) ?? 0,
                            width: convertFigmaToUIWidth(86, width) ?? 0,

                            decoration: BoxDecoration(
                                color: Color(0xff028D94),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    topLeft: Radius.circular(30))),
                            padding: EdgeInsets.symmetric(
                              horizontal: convertFigmaToUIWidth(16, width) ?? 0,
                              vertical: convertFigmaToUIWidth(7, width) ?? 0,
                            ),
                            child: Image(
                                image: AssetImage(scannedIcon),
                                fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      VerticalDivider(
                          color: Colors.white, thickness: 0.5, width: 0.5),
                      InkWell(
                        onTapDown: (_) {
                          setState(() {
                            scanerIconScale = 0.95;
                          });
                        },
                        onTapUp: (_) {
                          if (constant.nameValue == '') {
                            showToast('Please add name');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyProfileScreen()));
                            return;
                          }
                          if (widget.selectedIndex != 2) {
                            setState(() {
                              scanerIconScale = 1.0;
                              widget.onItemSelected(2);
                              isShowMenu = false;
                            });
                          }
                        },
                        onTapCancel: () {
                          setState(() {
                            scanerIconScale = 1.0;
                          });
                        },
                        onTap: () {},
                        child: AnimatedScale(
                          scale: scanerIconScale,
                          duration: Duration(milliseconds: 10),
                          child: Container(
                            height: convertFigmaToUIWidth(47, width) ?? 0,
                            width: convertFigmaToUIWidth(86, width) ?? 0,
                            decoration: BoxDecoration(
                                color: Color(0xff028D94),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(30),
                                    topRight: Radius.circular(30))),
                            padding: EdgeInsets.symmetric(
                              horizontal: convertFigmaToUIWidth(17, width) ?? 0,
                              vertical: convertFigmaToUIWidth(9, width) ?? 0,
                            ),
                            child: Image(
                                image: AssetImage(scannerIcon),
                                fit: BoxFit.contain),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
