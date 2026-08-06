// import 'package:event_pro/data/local/contants.dart';
// import 'package:event_pro/view/base_screen.dart';
// import 'package:event_pro/view/badges/exhibitorBadge.dart';
// import 'package:event_pro/view/home/home_screen.dart';
// import 'package:event_pro/view/badges/visitor_badge_screen.dart';
// import 'package:event_pro/view/badges/scan_qr_screen.dart';
// import 'package:event_pro/view/menuScreens/menu_screen.dart';
// import 'package:flutter/material.dart';

// class DashboardScreen extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;

//   void _onItemSelected(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     switch (index) {
//       case 0:
//         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//         break;
//       case 1:
//         if (constant.userType == constant.exhibitorUser) {
//           Navigator.pushNamed(context, '/exhibitorBadge');
//         } else {
//           Navigator.pushNamed(context, '/myBadge');
//         }
//         break;
//       case 2:
//         Navigator.pushNamed(context, '/scanQR');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/menu');
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BaseScreen(
//       selectedIndex: _selectedIndex,
//       child: _getChild(),
//       onItemSelected: _onItemSelected,
//     );
//   }

//   Widget _getChild() {
//     switch (_selectedIndex) {
//       case 0:
//         return HomeScreen();
//       case 1:
//         return constant.userType == constant.exhibitorUser ? ExhibitorBadgeScreen() : VisitorBadgeScreen();
//       case 2:
//         return ScanQRScreen();
//       case 3:
//         return MenuScreen();
//       default:
//         return HomeScreen();
//     }
//   }
// }
