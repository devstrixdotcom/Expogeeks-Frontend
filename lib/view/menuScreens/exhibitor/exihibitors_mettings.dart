import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/models/meeting_request_list_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:event_pro/view/home/home_screen.dart';
import 'package:event_pro/view/menuScreens/exhibitor/view_visitor_profile_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExhibitorMeetingsScreen extends StatefulWidget {
  bool isFromAppStart;
  ExhibitorMeetingsScreen({super.key, required this.isFromAppStart});

  @override
  State<ExhibitorMeetingsScreen> createState() =>
      _ExhibitorMeetingsScreenState();
}

class _ExhibitorMeetingsScreenState extends State<ExhibitorMeetingsScreen> {
  List<String> options = ["Meetings", "Accepted", "Rejected"];

  List<MeetingRequestListModel> allMeetings = [];
  List<MeetingRequestListModel> acceptedMeetings = [];
  List<MeetingRequestListModel> rejectedMeetings = [];
  // List<MeetingRequestListModel> completedMeetings = [];

  var selectedOptionsIndex = 0;

  bool isLoading = true;

  getMeetings() {
    if (selectedOptionsIndex == 0) {
      return allMeetings;
    } else if (selectedOptionsIndex == 1) {
      return acceptedMeetings;
    } else if (selectedOptionsIndex == 2) {
      return rejectedMeetings;
    }
    // else if (selectedOptionsIndex == 3) {
    //   return completedMeetings;
    // }
  }

  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    setState(() {
      isLoading = true;
    });
    dynamic response = await apiValue.getMeetingRequestList(context);
    if (response != null) {
      setState(() {
        isLoading = false;
        var tempList = response as List;
        allMeetings =
            tempList.map((i) => MeetingRequestListModel.fromJson(i)).toList();
        print(allMeetings.length);
        acceptedMeetings = allMeetings
            .where((element) => element.status == 'Accepted')
            .toList();
        print(acceptedMeetings.length);
        rejectedMeetings = allMeetings
            .where((element) => element.status == 'Rejected')
            .toList();
        print(rejectedMeetings.length);
        // completedMeetings = allMeetings.where((element) => element.status == 'Completed').toList();
        // print(completedMeetings.length);
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> onWillPop(BuildContext context) {
    if (widget.isFromAppStart) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false);
      return Future.value(true);
    } else {
      Navigator.pop(context);
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(convertFigmaToUIWidth(110, width) ?? 110),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                AppBar(
                  shadowColor: Colors.transparent,
                  backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  leading: GestureDetector(
                    onTap: () {
                      if (widget.isFromAppStart) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                            (route) => false);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  iconTheme: IconThemeData(color: Colors.white),
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  title: Padding(
                    padding: EdgeInsets.only(
                        right: convertFigmaToUIWidth(10, width) ?? 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            if (selectedOptionsIndex != 0) {
                              setState(() {
                                selectedOptionsIndex--;
                              });
                            }
                          },
                          child: SizedBox(
                            height: convertFigmaToUIWidth(20, width),
                            width: convertFigmaToUIWidth(40, width),
                            child: Center(
                              child: Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: convertFigmaToUIWidth(15, width)),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          options[selectedOptionsIndex],
                          style: TextStyle(
                            fontSize: convertFigmaToUIWidth(20, width),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            if (selectedOptionsIndex != options.length - 1) {
                              setState(() {
                                selectedOptionsIndex++;
                              });
                            }
                          },
                          child: SizedBox(
                            width: convertFigmaToUIWidth(40, width),
                            child: Center(
                              child: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: convertFigmaToUIWidth(15, width)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: PopupMenuButton<String>(
                        offset: Offset(-7, 30),
                        color: Colors.white,
                        elevation: 3,
                        itemBuilder: (BuildContext context) => [
                          _buildPopupMenuItem('Meetings', 'meeting', context),
                          _buildPopupMenuDivider(),
                          _buildPopupMenuItem('Accepted', 'accepted', context),
                          _buildPopupMenuDivider(),
                          _buildPopupMenuItem('Rejected', 'rejected', context),
                        ],
                        onSelected: (value) {
                          setState(() {
                            if (value == "meeting") selectedOptionsIndex = 0;
                            if (value == "accepted") selectedOptionsIndex = 1;
                            if (value == "rejected") selectedOptionsIndex = 2;
                          });
                        },
                        surfaceTintColor: Colors.white,
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ],
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      color: cyangreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),

                /// 👇 Overlapping Circular Count Badge
                Positioned(
                  bottom: convertFigmaToUIWidth(-45, width) ?? 0,
                  child: Container(
                    height: convertFigmaToUIWidth(90, width),
                    width: convertFigmaToUIWidth(90, width),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: cyangreen,
                    ),
                    child: Center(
                      child: Text(
                        getMeetings().length.toString(),
                        style: TextStyle(
                          height: 1.5,
                          // fontSize: 20,
                          fontSize: convertFigmaToUIWidth(20, width),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(204, 232, 234, 0.7),
            ),
            height: size.height,
            width: size.width,
            // color: Color.fromRGBO(204, 232, 234, 0.7),
            // color: Colors.white,
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: cyangreen))
                : RefreshIndicator(
                    onRefresh: () async {
                      initialPref();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: convertFigmaToUIWidth(30, width) ?? 30),
                        shrinkWrap: true,
                        itemCount: getMeetings().length,
                        itemBuilder: (context, index) => MeetingScreenCard(
                            model: getMeetings()[index],
                            refresh: initialPref,
                            index: index,
                            listLength: getMeetings().length),
                      ),
                    ),
                  ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String title, String value, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;

    return PopupMenuItem<String>(
      height: convertFigmaToUIWidth(30, width) ?? 30,
      value: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value == "meeting")
            SizedBox(height: convertFigmaToUIWidth(10, width)),
          Text(title,
              style: TextStyle(
                  height: 1.5,
                  // fontSize: 12,
                  fontSize: convertFigmaToUIWidth(12, width),
                  color: Color.fromRGBO(85, 85, 85, 0.8),
                  fontWeight: FontWeight.w400)),
          (value != "rejected") ? SizedBox() : SizedBox(height: 10),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuDivider() {
    return PopupMenuItem<String>(
        height: 10,
        enabled: false,
        onTap: null,
        value: null,
        child: Divider(color: Colors.grey, thickness: 0.2));
  }
}

// ignore: must_be_immutable
class MeetingScreenCard extends StatelessWidget {
  MeetingRequestListModel model;
  Function refresh;
  int index;
  int listLength;
  MeetingScreenCard(
      {super.key,
      required this.model,
      required this.refresh,
      required this.index,
      required this.listLength});

  TextEditingController _messageController = TextEditingController();

  editDialog(double h, double w, bool isRejectionMsg, context) {
    return Dialog(
      child: Container(
          width: convertFigmaToUIWidth(340, w),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
              color: cyangreenLight, borderRadius: BorderRadius.circular(10)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isRejectionMsg ? 'Rejection Message' : 'Message',
                    style: TextStyle(
                        color: Color.fromRGBO(85, 85, 85, 1),
                        fontSize: convertFigmaToUIWidth(10, w),
                        fontWeight: FontWeight.w500)),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 8),
                  child: TextField(
                    autofocus: true,
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 3,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    cursorColor: cyangreen,
                    style: TextStyle(
                        color: Color.fromRGBO(85, 85, 85, 1),
                        fontSize: convertFigmaToUIWidth(13, w),
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLength: 200,
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel Button
                    SizedBox(
                      width: convertFigmaToUIWidth(86, w),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: convertFigmaToUIWidth(15, w),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: convertFigmaToUIWidth(21, w),
                    ),

                    // Save Button
                    SizedBox(
                      width: convertFigmaToUIWidth(86, w),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: cyangreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: cyangreen, width: 1),
                          ),
                        ),
                        onPressed: () async {
                          if (isRejectionMsg &&
                              _messageController.text.isEmpty) {
                            showToast('Add rejection message');
                            return;
                          }
                          Navigator.of(context).pop(1);
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: convertFigmaToUIWidth(15, w),
                            color: white,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(model.imageLink.toString());

    double width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(
          top: 5,
          bottom: listLength - 1 == index ? 100 : 5,
          left: 20,
          right: 20),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.6),
        borderRadius: BorderRadius.circular(37),
        // border: Border.all(
        //   color: cyangreen,
        //   width: 1,
        // ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewVisitorProfileDetailsScreen(profileData: model)));
            },
            child: getCircularImageWidget(
                45,
                model.imageLink ?? '',
                Colors.grey.shade300,
                cyangreen,
                15,
                getNameInitials(model.visitorName ?? ''),
                showBoarder: false),
          ),
          SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: model.message.toString() == '' &&
                      model.replyMessage.toString() == ''
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) => messageDialog(
                            size.height,
                            size.width,
                            model.message ?? '',
                            model.visitorName ?? '',
                            model.replyMessage ?? '',
                            model.teamName ?? '',
                            context),
                      );
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.visitorName ?? '',
                      style: TextStyle(
                          height: 1.5,
                          color: Color.fromRGBO(85, 85, 85, 1),
                          // fontSize: 10,
                          fontSize: convertFigmaToUIWidth(10, width),
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),

                  Text(
                    "Message: ${model.message ?? ''}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.5,
                      color: Color.fromRGBO(85, 85, 85, 1),
                      // fontSize: 10,
                      fontSize: convertFigmaToUIWidth(10, width),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // SizedBox(height: 2),
                  SizedBox(height: convertFigmaToUIWidth(2, width)),
                  // Text('${model.meetingDate} | ${model.meetingTime}',
                  Text(
                      '${DateFormatter.formatDayWithSuffix(model.meetingDate ?? '')} | ${model.meetingTime}',
                      style: TextStyle(
                          height: 1.5,
                          color: Color.fromRGBO(85, 85, 85, 1),
                          // fontSize: 10,
                          fontSize: convertFigmaToUIWidth(10, width),
                          fontWeight: FontWeight.w500)),
                  if (model.replyMessage != "" &&
                      model.replyMessage.toString() != "null")
                    // SizedBox(height: 2),
                    SizedBox(height: convertFigmaToUIWidth(2, width)),
                  if (model.replyMessage != "" &&
                      model.replyMessage.toString() != "null")
                    Text(
                      "${model.status == "Rejected" ? 'Rejection msg: ' : 'Reply msg: '}${model.replyMessage ?? ''}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.5,
                        color: Color.fromRGBO(85, 85, 85, 1),
                        // fontSize: 10,
                        fontSize: convertFigmaToUIWidth(10, width),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // SizedBox(width: 8),
          SizedBox(
            width: convertFigmaToUIWidth(8, width),
          ),
          model.status == "Pending"
              ? Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return editDialog(
                                  size.height, size.width, true, context);
                            }).then((value) async {
                          // editDialog already blocks confirming a rejection with an
                          // empty message, so value==1 implies a non-empty reason.
                          if (value == 1) {
                            await apiValue
                                .updateMeetingStatus(context, model.id ?? '',
                                    'Rejected', _messageController.text)
                                .then((value) {
                              if (value != null) {
                                refresh();
                                showToast(value['message']);
                                _messageController.clear();
                              }
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            border: Border.all(color: cyangreen),
                            shape: BoxShape.circle),
                        child:
                            Icon(Icons.event_busy, color: cyangreen, size: 18),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return editDialog(
                                  size.height, size.width, false, context);
                            }).then((value) async {
                          print(value);
                          print('==========================================');
                          if (value == 1) {
                            await apiValue
                                .updateMeetingStatus(context, model.id ?? '',
                                    'Accepted', _messageController.text)
                                .then((value) {
                              if (value != null) {
                                refresh();
                                showToast(value['message']);
                                _messageController.clear();
                              }
                            });
                          }
                        });
                        // await apiValue.updateMeetingStatus(context, model.id ?? '', 'Accepted').then((value) => widget.refresh());
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            border: Border.all(color: cyangreen),
                            shape: BoxShape.circle),
                        child: Icon(Icons.event_available,
                            color: cyangreen, size: 18),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                )
              : model.status == "Accepted"
                  ? Container(
                      width: convertFigmaToUIWidth(80, width),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(2, 141, 148, 0.5),
                          borderRadius: BorderRadius.circular(13)),
                      child: Center(
                          child: Text('Accepted',
                              style: TextStyle(
                                  height: 1.5,
                                  color: Colors.white,
                                  fontSize: convertFigmaToUIWidth(10, width),
                                  fontWeight: FontWeight.w500))),
                    )
                  : Container(
                      width: convertFigmaToUIWidth(80, width),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Pink, borderRadius: BorderRadius.circular(13)),
                      child: Center(
                          child: Text('Rejected',
                              style: TextStyle(
                                  height: 1.5,
                                  color: Colors.white,
                                  fontSize: convertFigmaToUIWidth(10, width),
                                  fontWeight: FontWeight.w500))),
                    ),
        ],
      ),
    );
  }

  messageDialog(double h, double w, String msg, String msgName, String replyMsg,
      String replyMsgName, context) {
    return Dialog(
      child: Container(
        width: convertFigmaToUIWidth(347, w),
        padding: EdgeInsets.only(bottom: 15, left: 10, right: 10, top: 5),
        decoration: BoxDecoration(
            color: cyangreenLight, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg != '')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${msgName.trim()}:',
                        style: TextStyle(
                            height: 1.5,
                            color: Colors.black,
                            fontSize: convertFigmaToUIWidth(16, w),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: convertFigmaToUIWidth(4, w),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: msg,
                        style: TextStyle(
                            height: 1.5, color: Color.fromRGBO(85, 85, 85, 1)),
                      ),
                    ),
                  ],
                ),
              ),
            if (replyMsg != '')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${replyMsgName.trim()}:',
                        style: TextStyle(
                            height: 1.5,
                            color: Colors.black,
                            fontSize: convertFigmaToUIWidth(16, w),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: convertFigmaToUIWidth(4, w),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: replyMsg,
                        style: TextStyle(
                            height: 1.5, color: Color.fromRGBO(85, 85, 85, 1)),
                      ),
                    ),
                  ],
                ),
              ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 60,
                padding: EdgeInsets.symmetric(vertical: 2),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(child: Text('Cancel')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
