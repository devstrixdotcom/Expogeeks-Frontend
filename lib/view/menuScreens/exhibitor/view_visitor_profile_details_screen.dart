import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/models/meeting_request_list_model.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';

class ViewVisitorProfileDetailsScreen extends StatefulWidget {
  MeetingRequestListModel profileData;
  ViewVisitorProfileDetailsScreen({super.key, required this.profileData});

  @override
  State<ViewVisitorProfileDetailsScreen> createState() =>
      _ViewVisitorProfileDetailsScreenState();
}

class _ViewVisitorProfileDetailsScreenState
    extends State<ViewVisitorProfileDetailsScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _budgetController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _venueController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.profileData.visitorName ?? '';
    _phoneController.text = widget.profileData.mobile ?? '';
    _emailController.text = widget.profileData.email ?? '';
    _addressController.text = widget.profileData.address ?? '';
    _budgetController.text = widget.profileData.estimatedBudget ?? '';
    _destinationController.text = widget.profileData.destination ?? '';
    _venueController.text = widget.profileData.venue ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text("Profile",
              style: TextStyle(
                  height: 1.5,
                  fontSize: convertFigmaToUIWidth(20, width),
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          flexibleSpace: Container(
            height: convertFigmaToUIWidth(200, width),
            decoration: BoxDecoration(
              color: cyangreen,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
          ),
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(convertFigmaToUIWidth(200, width) ?? 0),
            child: Container(
              height: convertFigmaToUIWidth(200, width) ?? 0,
              width: size.width,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 0,
                    child: Container(
                      height: convertFigmaToUIWidth(200, width),
                      width: convertFigmaToUIWidth(200, width),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: white,
                          border: Border.all(
                              color: constant.imageLinkValue == ''
                                  ? cyangreen
                                  : white,
                              width: 2)),
                      child: widget.profileData.imageLink == ''
                          ? CircleAvatar(
                              child: Container(
                                height: convertFigmaToUIWidth(200, width),
                                width: convertFigmaToUIWidth(200, width),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                              ),
                            )
                          : CircleAvatar(
                              onBackgroundImageError: (exception, stackTrace) =>
                                  Container(
                                height: convertFigmaToUIWidth(200, width),
                                width: convertFigmaToUIWidth(200, width),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300),
                                child: Center(
                                    child: Icon(Icons.error_outline, size: 45)),
                              ),
                              backgroundImage: CachedNetworkImageProvider(
                                  widget.profileData.imageLink ?? ''),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _nameController.text,
                        style: TextStyle(
                            height: 1.5,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(85, 85, 85, 1)),
                      ),
                      SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.profileData.weddingRole.toString() == 'null' ||
                                  widget.profileData.weddingRole == ''
                              ? Text(
                                  "",
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize:
                                          convertFigmaToUIWidth(21.5, width),
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(2, 141, 148, 1)),
                                )
                              : Text(
                                  "${widget.profileData.weddingRole ?? ''} | ",
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(2, 141, 148, 1)),
                                ),
                          Text(
                            widget.profileData.expectedDate ?? '',
                            style: TextStyle(
                                height: 1.5,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(85, 85, 85, 1)),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      tabContainerBuilder(
                          'Contact Details',
                          _phoneController.text,
                          _emailController.text,
                          '',
                          true),
                      tabContainerBuilder(
                          'Address', '', '', _addressController.text, false),
                      tabContainerBuilder(
                          'Budget', '', '', _budgetController.text, false),
                      tabContainerBuilder('Destination', '', '',
                          _destinationController.text, false),
                      tabContainerBuilder(
                          'Venue', '', '', _venueController.text, false),
                      SizedBox(height: 100)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget tabContainerBuilder(
      String title, String phone, String email, String text, bool isTwoValue) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 12),
      padding: EdgeInsets.only(left: 20, right: 6, top: 12, bottom: 12),
      decoration: BoxDecoration(
          color: Color.fromRGBO(204, 232, 234, 0.5),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      height: 1.5,
                      color: Color.fromRGBO(85, 85, 85, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 7),
              isTwoValue
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Phone: ',
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text: phone,
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Email: ',
                                  style: TextStyle(
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      fontSize:
                                          convertFigmaToUIWidth(11, width),
                                      fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text: email,
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: convertFigmaToUIWidth(300, width),
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: title == 'Budget' ? '£ $text' : text,
                                style: TextStyle(
                                    color: Color.fromRGBO(85, 85, 85, 1),
                                    fontSize: convertFigmaToUIWidth(11, width),
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
