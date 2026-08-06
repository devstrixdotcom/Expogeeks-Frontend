import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';

Widget getCircularImageWidget(double size, String imageLink, Color bgColor, Color textColor, double textSize, String name, {bool showBoarder = true, Color borderColor = cyangreen}) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: bgColor,
      border: showBoarder ? Border.all(color: imageLink == '' ? borderColor : white, width: 2) : null,
    ),
    child: imageLink == ''
        ? Container(
            height: size,
            width: size,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Center(child: Text(name, style: TextStyle(height: 1.5, color: textColor, fontSize: textSize))),
          )
        : CircleAvatar(
            onBackgroundImageError: (exception, stackTrace) => Container(
              height: size,
              width: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300),
              child: Center(child: Icon(Icons.error_outline, size: 45)),
            ),
            backgroundImage: CachedNetworkImageProvider(imageLink),
            backgroundColor: Colors.grey.shade200,
          ),
  );
}
