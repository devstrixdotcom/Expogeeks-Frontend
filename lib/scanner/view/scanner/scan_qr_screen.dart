// import 'dart:convert';

// import 'package:event_pro/scanner/data/remote/api_value.dart';
// import 'package:event_pro/scanner/utils/helper_functions.dart';
// import 'package:event_pro/scanner/view/base_screen.dart';
// import 'package:event_pro/scanner/utils/basic_route.dart';
// import 'package:event_pro/scanner/utils/color.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gif/gif.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// import '../../models/scanned_category_list_model.dart';
// import '../../utils/images.dart';

// class ScanQRScreen extends StatefulWidget {
//   final String exhibitionId;
//   ScanQRScreen({required this.exhibitionId});
//   @override
//   _ScanQRScreenState createState() => _ScanQRScreenState();
// }

// showExitApp(context) {
//   showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           //title: Text("Alert!"),
//           content: Text('Are you sure you want to exit the app?'),
//           actions: <Widget>[
//             TextButton(
//                 child: Text('Cancel',
//                     style: TextStyle(height: 1.5, color: cyangreen)),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 }),
//             TextButton(
//                 child: Text('Yes',
//                     style: TextStyle(height: 1.5, color: cyangreen)),
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   SystemNavigator.pop();
//                 })
//           ],
//         );
//       });
// }

// Future<bool> onWillPop(BuildContext context) {
//   showExitApp(context);
//   return Future.value(true);
// }

// class _ScanQRScreenState extends State<ScanQRScreen>
//     with TickerProviderStateMixin {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   late QRViewController controller;
//   bool isLoading = true;
//   List<ScannedCategoryListModel> scannedCategoryList = [];
//   Set<String> scannedCodes = {};
//   String? lastScannedCode;
//   late GifController _gifController;

//   @override
//   void initState() {
//     super.initState();
//     _gifController = GifController(vsync: this); // Initialize GifController
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       debugPrint("Raw Scan Data: ${scanData.code}");

//       if (scanData.code != null && scanData.code!.isNotEmpty) {
//         String txnId;
//         try {
//           txnId = decodeBase64(scanData.code!);
//           debugPrint("txnId Decoded Base64 Data txnId: $txnId");
//         } catch (e) {
//           debugPrint("Error decoding Base64: $e");
//           showToast('Invalid QR Code');
//           await controller.pauseCamera();
//           await Future.delayed(Duration(seconds: 2));
//           await controller.resumeCamera();
//           return;
//         }

//         String exhibitionId = widget.exhibitionId;
//         debugPrint("Decoded Data: $txnId");
//         debugPrint("Exhibition ID: $exhibitionId");

//         // if (!_isValidTxnId(txnId)) {
//         //   debugPrint('Validation failed for txnId: $txnId');
//         //   showToast('Not valid Transaction ID');
//         //   await controller.pauseCamera();
//         //   await Future.delayed(Duration(seconds: 2));
//         //   await controller.resumeCamera();
//         //   return;
//         // }
//         // Check if txnId is not empty
//         if (!_isValidTxnId(txnId)) {
//           debugPrint('Invalid txnId: $txnId');
//           showToast('Invalid Transaction ID');
//           await controller.pauseCamera();
//           await Future.delayed(Duration(seconds: 2));
//           await controller.resumeCamera();
//           return;
//         }
//         await controller.pauseCamera();

//         // API Call
//         dynamic result = await apiValue.updateExhibitionAttendance(
//             context, exhibitionId, txnId);

//         if (result != null) {
//           if (result['status'] == 'true' &&
//               result['title'] == 'Success' &&
//               result['message'] == "Attendance marked successfully") {
//             debugPrint("SUCCESS Response");
//             await showCustomDialogFirst(context);
//             controller.resumeCamera();
//             return;
//           } else if (result['status'] == 'false' &&
//               result['title'] == 'Error' &&
//               result['message'] ==
//                   "Attendance already marked for this visitor") {
//             debugPrint("UNSUCCESS Response");
//             await showCustomDialogSecond(
//                 context, "This visitor has already been scanned 🙂");
//             controller.resumeCamera();
//             return;
//           } else {
//             debugPrint("INVALID Response");
//             await showCustomDialogSecond(context, "Invalid QR Code");
//             controller.resumeCamera();
//             return;
//           }
//         } else {
//           showToast('Invalid QR code or attendance update failed');
//           await Future.delayed(Duration(seconds: 2));
//           await controller.resumeCamera();
//         }
//       }
//     });
//   }

//   /// First Dialogue Box
//   Future<void> showCustomDialogFirst(BuildContext context) async {
//     void listener() {
//       if (_gifController.status == AnimationStatus.completed) {
//         Navigator.of(context).pop();
//         Navigator.pop(context, true);
//       }
//     }

//     _gifController.addListener(listener);

//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 10,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Gif(
//                   image: AssetImage(checkmarkGif),
//                   controller: _gifController,
//                   autostart: Autostart.no,
//                   onFetchCompleted: () async {
//                     if (mounted) {
//                       _gifController.reset();
//                       await Future.delayed(Duration(milliseconds: 500));
//                       if (mounted) {
//                         _gifController.forward();
//                       }
//                     }
//                   },
//                   placeholder: (context) => const Text('Loading...'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ).then((_) {
//       if (_gifController.isAnimating ||
//           _gifController.status != AnimationStatus.dismissed) {
//         _gifController.removeListener(listener);
//         _gifController.reset();
//       }
//     });
//   }

//   /// Second Dialogue Box
//   Future<void> showCustomDialogSecond(BuildContext context, String message) {
//     Future.delayed(Duration(seconds: 3), () {
//       Navigator.of(context).pop();
//       Navigator.pop(context, true);
//     });

//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 10,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       message,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: MediaQuery.of(context).size.width * 0.04,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // bool _isValidTxnId(String txnId) {
//   //   // Allow both formats: "EXPGK-12345" and "12345"
//   //   RegExp regExp = RegExp(r'^(EXPGK-)?\d+$');
//   //   return regExp.hasMatch(txnId);
//   // }

//   bool _isValidTxnId(String txnId) {
//     // Allow any non-empty string as a valid txnId
//     return txnId.isNotEmpty;
//   }

//   String decodeBase64(String input) {
//     try {
//       return utf8.decode(base64.decode(input));
//     } catch (e) {
//       throw FormatException('Invalid Base64 string');
//     }
//   }

//   @override
//   void dispose() {
//     scannedCodes.clear();
//     controller.dispose();
//     _gifController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return BaseScreen(
//       onItemSelected: (index) {
//         controller.pauseCamera();
//         Navigator.pushNamed(context, getRouteForIndex(index));
//       },
//       selectedIndex: 2,
//       child: WillPopScope(
//         onWillPop: () => onWillPop(context),
//         child: Scaffold(
//           appBar: AppBar(
//             scrolledUnderElevation: 0,
//             elevation: 0,
//             shadowColor: Colors.transparent,
//             backgroundColor: Colors.transparent,
//             centerTitle: true,
//             iconTheme: IconThemeData(color: Colors.white),
//             leading: InkWell(
//                 onTap: () {
//                   Navigator.pop(context, true);
//                 },
//                 child: Icon(Icons.arrow_back, color: Colors.white)),
//             title: Text("Scan QR",
//                 style: TextStyle(
//                     height: 1.5,
//                     fontSize: size.width * 0.05,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white)),
//             flexibleSpace: Container(
//               decoration: BoxDecoration(
//                   color: cyangreen,
//                   borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(30),
//                       bottomRight: Radius.circular(30))),
//             ),
//             bottom: PreferredSize(
//                 preferredSize: Size.fromHeight(10), child: SizedBox()),
//           ),
//           body: Container(
//             height: size.height,
//             width: size.width,
//             color: Colors.white,
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 SizedBox(height: 100),
//                 Center(
//                   child: Container(
//                     height: 300,
//                     width: 300,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         QRView(
//                           key: qrKey,
//                           onQRViewCreated: _onQRViewCreated,
//                           overlay: QrScannerOverlayShape(
//                             borderColor: cyangreen,
//                             borderRadius: 10,
//                             borderLength: 30,
//                             borderWidth: 10,
//                             cutOutSize: 250,
//                           ),
//                         ),
//                         ScanningOverlay(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           backgroundColor: Colors.white,
//         ),
//       ),
//     );
//   }
// }

// class ScanningOverlay extends StatefulWidget {
//   @override
//   _ScanningOverlayState createState() => _ScanningOverlayState();
// }

// class _ScanningOverlayState extends State<ScanningOverlay>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(seconds: 2),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 250).animate(_animationController)
//       ..addListener(() {
//         setState(() {});
//       })
//       ..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           _animationController.reverse();
//         } else if (status == AnimationStatus.dismissed) {
//           _animationController.forward();
//         }
//       });
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: _animation.value,
//       child: Container(
//         width: 250,
//         height: 2,
//         color: cyangreen,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }




//////////////////////////////////////////////////////////////////////////////




// import 'dart:convert';
// import 'package:event_pro/scanner/data/remote/api_value.dart';
// import 'package:event_pro/scanner/utils/helper_functions.dart';
// import 'package:event_pro/scanner/view/base_screen.dart';
// import 'package:event_pro/scanner/utils/basic_route.dart';
// import 'package:event_pro/scanner/utils/color.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gif/gif.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // Import mobile_scanner

// import '../../models/scanned_category_list_model.dart';
// import '../../utils/images.dart';

// class ScanQRScreen extends StatefulWidget {
//   final String exhibitionId;
//   ScanQRScreen({required this.exhibitionId});
//   @override
//   _ScanQRScreenState createState() => _ScanQRScreenState();
// }

// showExitApp(context) {
//   showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           //title: Text("Alert!"),
//           content: Text('Are you sure you want to exit the app?'),
//           actions: <Widget>[
//             TextButton(
//                 child: Text('Cancel',
//                     style: TextStyle(height: 1.5, color: cyangreen)),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 }),
//             TextButton(
//                 child: Text('Yes',
//                     style: TextStyle(height: 1.5, color: cyangreen)),
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   SystemNavigator.pop();
//                 })
//           ],
//         );
//       });
// }

// Future<bool> onWillPop(BuildContext context) {
//   showExitApp(context);
//   return Future.value(true);
// }

// class _ScanQRScreenState extends State<ScanQRScreen>
//     with TickerProviderStateMixin {
//   // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR'); // Not needed for mobile_scanner
//   late MobileScannerController controller; // Use MobileScannerController
//   bool isLoading = true;
//   List<ScannedCategoryListModel> scannedCategoryList = [];
//   Set<String> scannedCodes = {};
//   String? lastScannedCode;
//   late GifController _gifController;

//   @override
//   void initState() {
//     super.initState();
//     _gifController = GifController(vsync: this); // Initialize GifController
//     controller = MobileScannerController(); // Initialize MobileScannerController
//   }

//   // Changed method signature to match mobile_scanner's onDetect
//   void _onQRViewCreated(BarcodeCapture capture) async {
//     final List<Barcode> barcodes = capture.barcodes;
//     // For simplicity, we'll process the first barcode detected
//     if (barcodes.isNotEmpty) {
//       final scanDataCode = barcodes.first.rawValue;

//       debugPrint("Raw Scan Data: $scanDataCode");

//       if (scanDataCode != null && scanDataCode.isNotEmpty) {
//         String txnId;
//         try {
//           txnId = decodeBase64(scanDataCode);
//           debugPrint("txnId Decoded Base64 Data txnId: $txnId");
//         } catch (e) {
//           debugPrint("Error decoding Base64: $e");
//           showToast('Invalid QR Code');
//           await controller.stop(); // Use controller.stop()
//           await Future.delayed(Duration(seconds: 2));
//           await controller.start(); // Use controller.start()
//           return;
//         }

//         String exhibitionId = widget.exhibitionId;
//         debugPrint("Decoded Data: $txnId");
//         debugPrint("Exhibition ID: $exhibitionId");

//         if (!_isValidTxnId(txnId)) {
//           debugPrint('Invalid txnId: $txnId');
//           showToast('Invalid Transaction ID');
//           await controller.stop();
//           await Future.delayed(Duration(seconds: 2));
//           await controller.start();
//           return;
//         }
//         await controller.stop(); // Use controller.stop()

//         // API Call
//         dynamic result = await apiValue.updateExhibitionAttendance(
//             context, exhibitionId, txnId);

//         if (result != null) {
//           if (result['status'] == 'true' &&
//               result['title'] == 'Success' &&
//               result['message'] == "Attendance marked successfully") {
//             debugPrint("SUCCESS Response");
//             await showCustomDialogFirst(context);
//             controller.start(); // Use controller.start()
//             return;
//           } else if (result['status'] == 'false' &&
//               result['title'] == 'Error' &&
//               result['message'] == "Attendance already marked for this visitor") {
//             debugPrint("UNSUCCESS Response");
//             await showCustomDialogSecond(
//                 context, "This visitor has already been scanned 🙂");
//             controller.start(); // Use controller.start()
//             return;
//           } else {
//             debugPrint("INVALID Response");
//             await showCustomDialogSecond(context, "Invalid QR Code");
//             controller.start(); // Use controller.start()
//             return;
//           }
//         } else {
//           showToast('Invalid QR code or attendance update failed');
//           await Future.delayed(Duration(seconds: 2));
//           await controller.start(); // Use controller.start()
//         }
//       }
//     }
//   }

//   /// First Dialogue Box
//   Future<void> showCustomDialogFirst(BuildContext context) async {
//     void listener() {
//       if (_gifController.status == AnimationStatus.completed) {
//         Navigator.of(context).pop();
//         Navigator.pop(context, true);
//       }
//     }

//     _gifController.addListener(listener);

//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 10,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Gif(
//                   image: AssetImage(checkmarkGif),
//                   controller: _gifController,
//                   autostart: Autostart.no,
//                   onFetchCompleted: () async {
//                     if (mounted) {
//                       _gifController.reset();
//                       await Future.delayed(Duration(milliseconds: 500));
//                       if (mounted) {
//                         _gifController.forward();
//                       }
//                     }
//                   },
//                   placeholder: (context) => const Text('Loading...'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ).then((_) {
//       if (_gifController.isAnimating ||
//           _gifController.status != AnimationStatus.dismissed) {
//         _gifController.removeListener(listener);
//         _gifController.reset();
//       }
//     });
//   }

//   /// Second Dialogue Box
//   Future<void> showCustomDialogSecond(BuildContext context, String message) {
//     Future.delayed(Duration(seconds: 3), () {
//       Navigator.of(context).pop();
//       Navigator.pop(context, true);
//     });

//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 10,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       message,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: MediaQuery.of(context).size.width * 0.04,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   bool _isValidTxnId(String txnId) {
//     // Allow any non-empty string as a valid txnId
//     return txnId.isNotEmpty;
//   }

//   String decodeBase64(String input) {
//     try {
//       return utf8.decode(base64.decode(input));
//     } catch (e) {
//       throw FormatException('Invalid Base64 string');
//     }
//   }

//   @override
//   void dispose() {
//     scannedCodes.clear();
//     controller.dispose(); // Dispose the mobile_scanner controller
//     _gifController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return BaseScreen(
//       onItemSelected: (index) {
//         controller.stop(); // Use controller.stop()
//         Navigator.pushNamed(context, getRouteForIndex(index));
//       },
//       selectedIndex: 2,
//       child: WillPopScope(
//         onWillPop: () => onWillPop(context),
//         child: Scaffold(
//           appBar: AppBar(
//             scrolledUnderElevation: 0,
//             elevation: 0,
//             shadowColor: Colors.transparent,
//             backgroundColor: Colors.transparent,
//             centerTitle: true,
//             iconTheme: IconThemeData(color: Colors.white),
//             leading: InkWell(
//                 onTap: () {
//                   Navigator.pop(context, true);
//                 },
//                 child: Icon(Icons.arrow_back, color: Colors.white)),
//             title: Text("Scan QR",
//                 style: TextStyle(
//                     height: 1.5,
//                     fontSize: size.width * 0.05,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white)),
//             flexibleSpace: Container(
//               decoration: BoxDecoration(
//                   color: cyangreen,
//                   borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(30),
//                       bottomRight: Radius.circular(30))),
//             ),
//             bottom: PreferredSize(
//                 preferredSize: Size.fromHeight(10), child: SizedBox()),
//           ),
//           body: Container(
//             height: size.height,
//             width: size.width,
//             color: Colors.white,
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 SizedBox(height: 100),
//                 Center(
//                   child: Container(
//                     height: 300,
//                     width: 300,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         MobileScanner( // Replaced QRView with MobileScanner
//                           controller: controller, // Pass the controller
//                           onDetect: _onQRViewCreated, // Use onDetect
//                           // mobile_scanner does not have a direct 'overlay' property like qr_code_scanner.
//                           // The overlay will be drawn on top of the MobileScanner widget using a Stack.
//                           // The `QrScannerOverlayShape` is also not directly transferable.
//                           // We'll keep your custom `ScanningOverlay` for the visual effect.
//                         ),
//                         // The ScanningOverlay remains as a custom overlay on top of MobileScanner
//                         ScanningOverlay(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           backgroundColor: Colors.white,
//         ),
//       ),
//     );
//   }
// }

// class ScanningOverlay extends StatefulWidget {
//   @override
//   _ScanningOverlayState createState() => _ScanningOverlayState();
// }

// class _ScanningOverlayState extends State<ScanningOverlay>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(seconds: 2),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 250).animate(_animationController)
//       ..addListener(() {
//         setState(() {});
//       })
//       ..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           _animationController.reverse();
//         } else if (status == AnimationStatus.dismissed) {
//           _animationController.forward();
//         }
//       });
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: _animation.value,
//       child: Container(
//         width: 250,
//         height: 2,
//         color: cyangreen,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }



//////////////////////////////////////////////////////////////////////////////



import 'dart:convert';

import 'package:event_pro/scanner/data/remote/api_value.dart';
import 'package:event_pro/scanner/utils/helper_functions.dart';
import 'package:event_pro/scanner/view/base_screen.dart';
import 'package:event_pro/scanner/utils/basic_route.dart';
import 'package:event_pro/scanner/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gif/gif.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/scanned_category_list_model.dart';
import '../../utils/images.dart';

class ScanQRScreen extends StatefulWidget {
  final String exhibitionId;
  ScanQRScreen({required this.exhibitionId});
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

showExitApp(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text("Alert!"),
          content: Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel',
                    style: TextStyle(height: 1.5, color: cyangreen)),
                onPressed: () {
                  Navigator.pop(context);
                }),
            TextButton(
                child: Text('Yes',
                    style: TextStyle(height: 1.5, color: cyangreen)),
                onPressed: () async {
                  Navigator.pop(context);
                  SystemNavigator.pop();
                })
          ],
        );
      });
}

Future<bool> onWillPop(BuildContext context) {
  showExitApp(context);
  return Future.value(true);
}

class _ScanQRScreenState extends State<ScanQRScreen>
    with TickerProviderStateMixin {
  late MobileScannerController controller;
  bool isLoading = true;
  List<ScannedCategoryListModel> scannedCategoryList = [];
  Set<String> scannedCodes = {};
  String? lastScannedCode;

  /// True while a detection is being submitted. Without it, mobile_scanner can
  /// deliver several frames before `controller.stop()` takes effect and each
  /// one fires UpdateExhibitionAttendance.
  bool isProcessing = false;

  /// When the last detection finished, used with [lastScannedCode].
  DateTime? lastScanFinishedAt;

  /// How long the same badge is ignored after it has been submitted. The badge
  /// is normally still in front of the camera while the result dialog is up,
  /// and `controller.start()` resets `DetectionSpeed.noDuplicates`, so without
  /// this the same visitor is submitted twice — the second call comes back
  /// "Attendance already marked", which showed "already been scanned"
  /// immediately after a successful first-ever scan.
  static const Duration sameCodeCooldown = Duration(seconds: 3);

  late GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    // One submission at a time; frames keep arriving until stop() takes effect.
    if (isProcessing) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;

    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;

      debugPrint("Raw Scan Data: $code");

      if (code != null && code.isNotEmpty) {
        if (code == lastScannedCode &&
            lastScanFinishedAt != null &&
            DateTime.now().difference(lastScanFinishedAt!) < sameCodeCooldown) {
          debugPrint("Ignoring re-detection of the badge just scanned");
          return;
        }

        isProcessing = true;
        lastScannedCode = code;
        try {
          await _submitScannedCode(code);
        } finally {
          lastScanFinishedAt = DateTime.now();
          isProcessing = false;
        }
      }
    }
  }

  Future<void> _submitScannedCode(String code) async {
    String txnId;
    try {
      txnId = decodeBase64(code);
      debugPrint("txnId Decoded Base64 Data txnId: $txnId");
    } catch (e) {
      debugPrint("Error decoding Base64: $e");
      showToast('Invalid QR Code');
      await controller.stop();
      await Future.delayed(Duration(seconds: 2));
      await controller.start();
      return;
    }

    String exhibitionId = widget.exhibitionId;
    debugPrint("Decoded Data: $txnId");
    debugPrint("Exhibition ID: $exhibitionId");

    // Check if txnId is not empty
    if (!_isValidTxnId(txnId)) {
      debugPrint('Invalid txnId: $txnId');
      showToast('Invalid Transaction ID');
      await controller.stop();
      await Future.delayed(Duration(seconds: 2));
      await controller.start();
      return;
    }
    
    await controller.stop();

    // API Call
    dynamic result = await apiValue.updateExhibitionAttendance(
        context, exhibitionId, txnId);

    if (result != null) {
      if (result['status'] == 'true' &&
          result['title'] == 'Success' &&
          result['message'] == "Attendance marked successfully") {
        debugPrint("SUCCESS Response");
        await showCustomDialogFirst(context);
        controller.start();
        return;
      } else if (result['status'] == 'false' &&
          result['title'] == 'Error' &&
          result['message'] ==
              "Attendance already marked for this visitor") {
        debugPrint("UNSUCCESS Response");
        await showCustomDialogSecond(
            context, "This visitor has already been scanned 🙂");
        controller.start();
        return;
      } else {
        debugPrint("INVALID Response");
        await showCustomDialogSecond(context, "Invalid QR Code");
        controller.start();
        return;
      }
    } else {
      showToast('Invalid QR code or attendance update failed');
      await Future.delayed(Duration(seconds: 2));
      await controller.start();
    }
  }

  /// First Dialogue Box
  Future<void> showCustomDialogFirst(BuildContext context) async {
    void listener() {
      if (_gifController.status == AnimationStatus.completed) {
        Navigator.of(context).pop();
        Navigator.pop(context, true);
      }
    }

    _gifController.addListener(listener);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Gif(
                  image: AssetImage(checkmarkGif),
                  controller: _gifController,
                  autostart: Autostart.no,
                  onFetchCompleted: () async {
                    if (mounted) {
                      _gifController.reset();
                      await Future.delayed(Duration(milliseconds: 500));
                      if (mounted) {
                        _gifController.forward();
                      }
                    }
                  },
                  placeholder: (context) => const Text('Loading...'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (_gifController.isAnimating ||
          _gifController.status != AnimationStatus.dismissed) {
        _gifController.removeListener(listener);
        _gifController.reset();
      }
    });
  }

  /// Second Dialogue Box
  Future<void> showCustomDialogSecond(BuildContext context, String message) {
    var width = MediaQuery.of(context).size.width;
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop();
      Navigator.pop(context, true);
    });

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: convertFigmaToUIWidth(16, width),
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isValidTxnId(String txnId) {
    // Allow any non-empty string as a valid txnId
    return txnId.isNotEmpty;
  }

  String decodeBase64(String input) {
    try {
      return utf8.decode(base64.decode(input));
    } catch (e) {
      throw FormatException('Invalid Base64 string');
    }
  }

  @override
  void dispose() {
    scannedCodes.clear();
    controller.dispose();
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    return BaseScreen(
      onItemSelected: (index) {
        controller.stop();
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 2,
      child: WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: Icon(Icons.arrow_back, color: Colors.white)),
            title: Text("Scan QR",
                style: TextStyle(
                    fontSize: convertFigmaToUIWidth(20, width),
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  color: cyangreen,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(convertFigmaToUIWidth(10, width) ?? 10),
                child: SizedBox()),
          ),
          body: Container(
            height: size.height,
            width: size.width,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: convertFigmaToUIWidth(100, width),),
                Center(
                  child: Container(
                    height: convertFigmaToUIWidth(300, width),
                    width: convertFigmaToUIWidth(300, width),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: controller,
                          onDetect: _onDetect,
                          
                        ),
                        _buildOverlay(),
                        ScanningOverlay(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: QrScannerOverlayPainter(
          borderColor: cyangreen,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 2,
          cutOutSize: 250,
        ),
      ),
    );
  }
}

class ScanningOverlay extends StatefulWidget {
  @override
  _ScanningOverlayState createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<ScanningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 35, end: 250).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Positioned(
      top: _animation.value,
      child: Container(
        width: convertFigmaToUIWidth(250, width),
        height: convertFigmaToUIWidth(2, width),
        color: cyangreen,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Custom overlay painter for mobile_scanner to match qr_code_scanner UI
class QrScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayPainter({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw dark overlay with cutout
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)));

    canvas.drawPath(path, backgroundPaint);

    // Draw corner borders exactly like qr_code_scanner
    final borderPath = Path();

    // Top left corner
    borderPath.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    borderPath.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    borderPath.quadraticBezierTo(cutOutRect.left, cutOutRect.top, cutOutRect.left + borderRadius, cutOutRect.top);
    borderPath.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top right corner
    borderPath.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    borderPath.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    borderPath.quadraticBezierTo(cutOutRect.right, cutOutRect.top, cutOutRect.right, cutOutRect.top + borderRadius);
    borderPath.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom right corner
    borderPath.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    borderPath.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    borderPath.quadraticBezierTo(cutOutRect.right, cutOutRect.bottom, cutOutRect.right - borderRadius, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom left corner
    borderPath.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    borderPath.quadraticBezierTo(cutOutRect.left, cutOutRect.bottom, cutOutRect.left, cutOutRect.bottom - borderRadius);
    borderPath.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}