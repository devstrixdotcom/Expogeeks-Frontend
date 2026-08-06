import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';

class CustomProgressDialog extends StatelessWidget {
  const CustomProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: boldpink,
      contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Downloading, please wait...',
            style: TextStyle(fontSize: 16, color: cyangreen),
            textAlign: TextAlign.center,
            
          ),
        ],
      ),
    );
  }
}
