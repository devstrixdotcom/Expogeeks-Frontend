import 'package:flutter/material.dart';

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
    return Scaffold(
      body: widget.child,
    );
  }
}
