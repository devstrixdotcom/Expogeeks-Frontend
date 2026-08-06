import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:flutter/material.dart';

deleteFileConfirmationPopup(String fileType, onTap, BuildContext context) {
  var width = MediaQuery.of(context).size.width;
  Widget ok = GestureDetector(
    onTap: onTap,
    child: Container(
      width: 70,
      padding: EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(color: cyangreen, border: Border.all(color: cyangreen.withOpacity(0.8), width: 1), borderRadius: BorderRadius.circular(5)),
      child: Center(child: Text("Delete", style: TextStyle(height: 1, color: white))),
    ),
  );

  Widget cancel = GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: Container(
      width: 70,
      padding: EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(color: cyangreen, border: Border.all(color: cyangreen.withOpacity(0.8), width: 1), borderRadius: BorderRadius.circular(5)),
      child: Center(child: Text("Cancel", style: TextStyle(height: 1, color: white))),
    ),
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: Text("Confirm", style: TextStyle(fontSize: convertFigmaToUIWidth(16, width), fontWeight: FontWeight.w600)) ),
      content: Text("Are you sure you want to delete $fileType?", textAlign: TextAlign.center, style: TextStyle(fontSize: convertFigmaToUIWidth(12, width))),
      actions: [ok, SizedBox(width: 5), cancel],
      elevation: 5,
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      actionsPadding: EdgeInsets.only(bottom: 20),
    ),
  );
}
