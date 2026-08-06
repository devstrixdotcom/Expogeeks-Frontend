import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';

import '../utils/helper_functions.dart';

SizedBox filledButtonWidgt(context, String text, onpressed) {
    var width = MediaQuery.of(context).size.width;
  return SizedBox(
    height: convertFigmaToUIWidth(60, width),
    child: FilledButton(
      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(cyangreen)),
      onPressed: onpressed,
      child: Text(text, 
      style: TextStyle(fontSize: convertFigmaToUIWidth(16, width) ?? 14,),
      )
    ),
  );
}
