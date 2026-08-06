import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ShowsDetailsCard extends StatelessWidget {
  bool isBooked;
  var img;
  String showName;
  String address;
  Function() onpressed;
  String date;

  ShowsDetailsCard(
      {super.key,
      required this.isBooked,
      required this.img,
      required this.showName,
      required this.address,
      required this.onpressed,
      required this.date});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(
          bottom:
              convertFigmaToUIWidth(20, width) ?? 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onpressed,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 174, 176, 0.25),
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0)),
                    child: CachedNetworkImage(
                      imageUrl: img,
                      // imageUrl: img.isNotEmpty ? img : "invalid-url",
                      width: width,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: width,
                        height: convertFigmaToUIWidth(2, width),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: Colors.grey.shade300),
                        child:
                            Center(child: Icon(Icons.error_outline, size: 30)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // 👈 Align vertically center
                      children: [
                        // Left Side Column with showName and address
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: convertFigmaToUIWidth(15, width)),
                              Container(
                                padding: const EdgeInsets.only(left: 17),
                                child: Text(
                                  showName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(14, width),
                                      fontWeight: FontWeight.w700,
                                      color:
                                          const Color.fromRGBO(100, 76, 76, 1),
                                      fontFamily: "Roboto"),
                                ),
                              ),
                              SizedBox(height: convertFigmaToUIWidth(5, width)),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on,
                                        size:
                                            convertFigmaToUIWidth(11.2, width),
                                        color: const Color.fromRGBO(
                                            147, 123, 123, 1)),
                                    SizedBox(
                                        width: convertFigmaToUIWidth(5, width)),
                                    Expanded(
                                      child: Text(
                                        address,
                                        // maxLines: 2,
                                        // overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: convertFigmaToUIWidth(
                                                10, width),
                                            color: const Color.fromRGBO(
                                                100, 76, 76, 1),
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "Roboto"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: convertFigmaToUIWidth(
                                      15, width)),
                            ],
                          ),
                        ),
SizedBox(
                                  width: convertFigmaToUIWidth(10, width)),
                        // Right side "More Info" button aligned center
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          width: convertFigmaToUIWidth(80, width),
                          height: convertFigmaToUIWidth(
                              35, width),
                          decoration: BoxDecoration(
                            color: constant.userType == constant.exhibitorUser
                                ? white
                                : isBooked
                                    ? lightpink
                                    : white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              constant.userType == constant.exhibitorUser
                                  ? "More Info"
                                  : isBooked
                                      ? "Booked"
                                      : "More Info",
                              style: TextStyle(
                                fontSize: convertFigmaToUIWidth(10, width),
                                color: brownText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8, top: 12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: convertFigmaToUIWidth(10, width) ?? 10,
                  horizontal: convertFigmaToUIWidth(10, width) ?? 10),
              child: Text(DateFormatter.formatDayWithSuffix(date),
                  style: TextStyle(fontSize: convertFigmaToUIWidth(12, width))),
            ),
          ),
        ],
      ),
    );
  }
}
