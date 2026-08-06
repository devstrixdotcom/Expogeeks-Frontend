import 'package:flutter/material.dart';

import '../utils/color.dart';

Widget feedbackTextFields(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 15),
    child: TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      minLines: 1,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: Color.fromRGBO(235, 246, 247, 0.5),
        labelStyle: TextStyle(height: 1.5, color: cyangreen),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cyangreen, width: 0.8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cyangreen, width: 0.8)),
      ),
    ),
  );
}
