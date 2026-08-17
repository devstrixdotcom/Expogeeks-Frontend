import 'dart:convert';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/local/contants.dart';
import '../../models/exhibition_list_model.dart';
import '../../models/scanned_category_list_model.dart';
import '../../utils/helper_functions.dart';
import '../feedback/VisitorFlow/feedback_for_exhibitor.dart';
import '../menuScreens/exhibitor/scanned_visitors.dart';

class ScanQRScreen extends StatefulWidget {
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  late MobileScannerController controller;
  bool isLoading = true;
  List<ScannedCategoryListModel> scannedCategoryList = [];
  String userType = '';
  String decodedId = '';
  String? selectedExhibitionId; // Store selected exhibition ID
  List<ExhibitionModel> exhibitions = []; // Store exhibition list
  bool isDialgueOpen = false;
  bool isProcessing = false; // Add flag to prevent multiple scans

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    initialPref();
  }

  initialPref() async {
    debugPrint("dfdfdfd");
    setState(() {
      isLoading = true;
    });
    // Fetch exhibition list
    dynamic exhibitionResponse =
        await apiValue.getTeamMemberExhibitionlist(context);
    if (exhibitionResponse != null) {
      setState(() {
        exhibitions = (exhibitionResponse as List)
            .map((e) => ExhibitionModel.fromJson(e))
            .toList();
        if (exhibitions.isNotEmpty) {
          selectedExhibitionId = exhibitions.first.id; // Set default selection
        }
      });
    }
  }

  // Future<void> _showExhibitionSelectionDialog(String decodedId) async {
  //   if (exhibitions.isEmpty) {
  //     showToast('No exhibitions available');
  //     return;
  //   }
  //   String? selectedId = selectedExhibitionId;
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 'Select Exhibition',
  //                 style: TextStyle(
  //                     height: 1.5,
  //                     fontSize: 20,
  //                     color: cyangreen,
  //                     fontWeight: FontWeight.w600),
  //               ),
  //               SizedBox(height: 20),
  //               DropdownButtonFormField<String>(
  //                 value: selectedId,
  //                 items: exhibitions.map((exhibition) {
  //                   return DropdownMenuItem<String>(
  //                     value: exhibition.id,
  //                     child:
  //                         // Text(exhibition.exhibitionName!,),
  //                         Text(
  //                       exhibition.exhibitionName ?? "",
  //                       style: const TextStyle(
  //                         fontSize: 14,
  //                       ),
  //                       maxLines: 2, // allow up to 3 lines
  //                       overflow: TextOverflow.ellipsis, // show ... if too long
  //                       softWrap: true, // enable wrapping
  //                     ),
  //                   );
  //                 }).toList(),
  //                 onChanged: (String? newValue) {
  //                   setState(() {
  //                     selectedId = newValue;
  //                   });
  //                 },
  //                 decoration: InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   contentPadding: EdgeInsets.symmetric(horizontal: 10),
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   ElevatedButton(
  //                     style: ButtonStyle(
  //                         backgroundColor: MaterialStatePropertyAll(cyangreen)),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text("Cancel"),
  //                   ),
  //                   SizedBox(width: 10),
  //                   ElevatedButton(
  //                     style: ButtonStyle(
  //                         backgroundColor: MaterialStatePropertyAll(cyangreen)),
  //                     onPressed: () async {
  //                       if (selectedId != null) {
  //                         Navigator.pop(context);
  //                         _processVisitorScan(decodedId, selectedId!);
  //                       }
  //                     },
  //                     child: const Text("Ok"),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   ).then((value) {
  //     setState(() {
  //       isDialgueOpen = false;
  //     });
  //   });
  // }


  Future<void> _showExhibitionSelectionDialog(String decodedId) async {
  if (exhibitions.isEmpty) {
    showToast('No exhibitions available');
    return;
  }

  String? selectedId = selectedExhibitionId;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Exhibition',
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 20,
                    color: cyangreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// === FIXED DROPDOWN WITH PROPER SELECTED DISPLAY ===
              Container(
                constraints: BoxConstraints(
                  minHeight: 60, // Ensure minimum height for 2 lines
                ),
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedId,
                  
                  // FIX: Add selectedItemBuilder to handle selected value display
                  selectedItemBuilder: (BuildContext context) {
                    return exhibitions.map<Widget>((exhibition) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          exhibition.exhibitionName ?? "",
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      );
                    }).toList();
                  },
                  
                  items: exhibitions.map((exhibition) {
                    return DropdownMenuItem<String>(
                      value: exhibition.id,
                      child: Text(
                        exhibition.exhibitionName ?? "",
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    );
                  }).toList(),
                  
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedId = newValue;
                    });
                  },
                  
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(cyangreen),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(cyangreen),
                    ),
                    onPressed: () async {
                      if (selectedId != null) {
                        Navigator.pop(context);
                        _processVisitorScan(decodedId, selectedId!);
                      }
                    },
                    child: const Text("Ok"),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  ).then((value) {
    setState(() {
      isDialgueOpen = false;
    });
  });
}

  Future<void> _processVisitorScan(
      String decodedId, String exhibitionId) async {
    try {
      dynamic response = await apiValue.scanVisitor(
        context,
        decodedId,
        exhibitionId,
      );
      if (response != null) {
        if (response['status'] == 'false') {
          Navigator.of(context).pop();
          showCustomDialog(context, response['message']);
          // return manage navigation
          return;
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ScaneedVistors(
              isAfterScan: true,
              isAfterScanVisitorId: decodedId,
              exhibitionId: exhibitionId,
            ),
          ),
        );
      } else {
        debugPrint('ELSE Invalid QR code');
        Navigator.pop(context);
      }
    } finally {
      // _onBarcodeDetected sets isProcessing before opening the exhibition
      // dialog and returns without clearing it. Without this the flag stays
      // true once the user comes back to the scanner, so every later detection
      // is dropped and scanning silently stops working.
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _onBarcodeDetected(BarcodeCapture barcodeCapture) async {
    // Prevent multiple processing
    if (isProcessing) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null) return;

    setState(() {
      isProcessing = true;
    });

    print('-----------------------------response =========================');
    print(code);

    // Check if the scanned code is valid JSON
    if (!isValidJsonString(code)) {
      showToast('Invalid QR code');
      setState(() {
        isProcessing = false;
      });
      return;
    }

    try {
      // Decode the QR code as JSON
      Map<String, dynamic> decodedMap = json.decode(code);
      // Extract the user_type and id fields
      String scannedUserType = decodedMap['user_type'];
      String encodedId = decodedMap['id'];
      // Decode the Base64-encoded id
      String decodedId = decodeBase64(encodedId);
      print('Scanned User Type: $scannedUserType');
      print('Decoded ID: $decodedId');

      // Check if the QR code is valid for the current user
      if (scannedUserType == 'exhibitor') {
        if (constant.exhibitorUser == constant.userType) {
          showToast('Exhibitors cannot scan their own QR codes');
          Navigator.pop(context);
          return;
        }
      } else if (scannedUserType == 'visitor') {
        if (constant.visitorUser == constant.userType) {
          showToast('Visitors cannot scan their own QR codes');
          Navigator.pop(context);
          return;
        }
      }

      // When exhibitor scan visitor QR code
      if (scannedUserType == 'visitor') {
        setState(() {
          isDialgueOpen = true;
        });
        _showExhibitionSelectionDialog(decodedId);
        return;
      }
      // When visitor scan exhibitor QR code
      else if (scannedUserType == 'exhibitor') {
        dynamic scanExhibitor =
            await apiValue.scanExhibitor(context, decodedId);
        if (scanExhibitor != null) {
          if (scanExhibitor['status'] == 'false') {
            Navigator.of(context).pop();
            showCustomDialog(context, scanExhibitor['message']);
            return;
          }
          dynamic teamMemberDetails =
              await apiValue.getTeamMemberDetails(context, decodedId);
          if (teamMemberDetails != null) {
            dynamic exhibitorDetails = await apiValue.getExhibitorDetails(
                context, teamMemberDetails['exhibitorId']);
            if (exhibitorDetails != null) {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FeedbackForExhibitor(
                    name: teamMemberDetails['name'] ?? '',
                    image: exhibitorDetails['imageLink'] ?? '',
                    circularImage: teamMemberDetails['imageLink'] ?? '',
                    exhibitorId: decodedId,
                    category: exhibitorDetails['category'] ?? '',
                    // countryCode: exhibitorDetails['country_code'] ?? '',
                    countryCode: teamMemberDetails['countryCode'] ?? '',
                    phone: teamMemberDetails['mobile'] ?? '',
                    email: teamMemberDetails['email'] ?? '',
                    insta: exhibitorDetails['instagram_link'] ?? '',
                    exhibitionName: teamMemberDetails['exhibitionName'] ?? '',
                    companyName: exhibitorDetails['name'] ?? '',
                  ),
                ),
              );
            } else {
              debugPrint('Failed to fetch exhibitor details');
              Navigator.pop(context);
            }
          } else {
            debugPrint('Failed to fetch team member details');
            Navigator.pop(context);
          }
        } else {
          debugPrint('Invalid QR code');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error decoding JSON or Base64: $e');
      debugPrint('Invalid QR code');
      Navigator.pop(context);
    }

    setState(() {
      isProcessing = false;
    });
  }

  // Function to Show Custom Popup Dialog
  void showCustomDialog(BuildContext context, String message) {
    var width = MediaQuery.of(context).size.width;
    showDialog(
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
                Text(
                  message, // Use the API message dynamically
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: convertFigmaToUIWidth(20, width)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: cyangreen, // Ensure `cyangreen` is defined
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                        fontSize: convertFigmaToUIWidth(16, width),
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to validate JSON string
  bool isValidJsonString(String jsonString) {
    try {
      json.decode(jsonString);
      return true;
    } on FormatException {
      return false;
    }
  }

  // Base64 decode function
  String decodeBase64(String base64String) {
    try {
      List<int> decodedBytes = base64.decode(base64String);
      return utf8.decode(decodedBytes);
    } catch (e) {
      print('Error decoding Base64: $e');
      return ''; // Return an empty string in case of error
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    bool _backButtonPressed = false;
    return BaseScreen(
      onItemSelected: (index) {
        // Navigator.pushNamedAndRemoveUntil(context, getRouteForIndex(index), (route) => false);
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 2,
      child: WillPopScope(
        onWillPop: () async {
          // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          // return false; // prevent default pop
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            elevation: 0,
            shadowColor: Colors.transparent,
            // backgroundColor: Colors.transparent,
            backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            leading: InkWell(
                onTap: () {
                  // Track that the back button was pressed
                  if (_backButtonPressed) {
                    // If it was already pressed, don't do anything
                    return;
                  }
                  _backButtonPressed = true;
                  // SystemNavigator.pop();
                  Navigator.pop(context);
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, '/home', (route) => false);
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
                preferredSize: Size.fromHeight(10), child: SizedBox()),
          ),
          body: Container(
            height: size.height,
            width: size.width,
            color: Color.fromRGBO(204, 232, 234, 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 100),
                Center(
                  child: Container(
                    // height: 300,
                    // width: 300,
                    height: convertFigmaToUIWidth(300, width),
                    width: convertFigmaToUIWidth(300, width),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MobileScanner(
                            controller: controller,
                            onDetect: _onBarcodeDetected,
                          ),
                        ),
                        // Custom overlay to mimic QrScannerOverlayShape
                        CustomScannerOverlay(
                          borderColor: cyangreen,
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 250,
                        ),
                        if (!isDialgueOpen) ScanningOverlay(),
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
}

// Custom overlay widget to replace QrScannerOverlayShape
class CustomScannerOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  const CustomScannerOverlay({
    Key? key,
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      // width: 300,
      // height: 300,
      height: convertFigmaToUIWidth(300, width),
      width: convertFigmaToUIWidth(300, width),
      child: CustomPaint(
        painter: OverlayPainter(
          borderColor: borderColor,
          borderRadius: borderRadius,
          borderLength: borderLength,
          borderWidth: borderWidth,
          cutOutSize: cutOutSize,
        ),
      ),
    );
  }
}

class OverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  OverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw corner borders
    final path = Path();

    // Top-left corner
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    path.arcToPoint(
      Offset(cutOutRect.left + borderRadius, cutOutRect.top),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top-right corner
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    path.arcToPoint(
      Offset(cutOutRect.right, cutOutRect.top + borderRadius),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom-right corner
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    path.arcToPoint(
      Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom-left corner
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    path.arcToPoint(
      Offset(cutOutRect.left, cutOutRect.bottom - borderRadius),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    _animation = Tween<double>(begin: 0, end: 250).animate(_animationController)
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
        // width: 250,
        // height: 2,
        height: convertFigmaToUIWidth(2, width),
        width: convertFigmaToUIWidth(250, width),
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
