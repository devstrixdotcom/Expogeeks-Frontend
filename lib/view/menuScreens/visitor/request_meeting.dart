import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/models/exhibitor_team_list_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/exhibitor_details_model.dart';

class RequestMeetingScreen extends StatefulWidget {
  String exhibitorId;
  List<String> bookedDates;
  List<Meeting> meetingList;
  List<String> meetingTimes;
  List<String> meetingDate;

  RequestMeetingScreen(
      {super.key,
      required this.exhibitorId,
      required this.bookedDates,
      required this.meetingList,
      required this.meetingTimes,
      required this.meetingDate});

  @override
  State<RequestMeetingScreen> createState() => _RequestMeetingScreenState();
}

class _RequestMeetingScreenState extends State<RequestMeetingScreen> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController _messageController = TextEditingController();
  bool showDropdown = false;

  String selectedTime = '';
  String selectedDate = '';
  List<TimeSlotsModel> timeSlots = [];
  List<String> mainTimeSlots = [];
  List<String> dateSlots = [];
  Set<String> bookedTimes = Set<String>();

  ExhibitorTeamListModel? exhibitorDetails;
  List<ExhibitorTeamListModel> exhibitorTeamList = [];
  bool isLoading = true;
  bool isButtonLoading = false;

  bool isDateSelected = false;

  @override
  void initState() {
    super.initState();
    initialPref();
    debugPrint("BookedDates: ${widget.bookedDates}");
    debugPrint(
        "MeetingList: ${widget.meetingList.map((m) => m.toJson()).toList()}");
    debugPrint("MeetingTimes: ${widget.meetingTimes}");
    debugPrint("MeetingDate: ${widget.meetingDate}");
  }

  List<String> getAvailableDates() {
    List<String> availableDates = [];

    // Create a set of booked dates for quick lookup
    Set<String> bookedDatesSet = Set<String>.from(widget.meetingDate);

    for (var date in widget.bookedDates) {
      // Check if the date is not in the booked dates set
      if (!bookedDatesSet.contains(DateFormatter.formatDayWithSuffix(date))) {
        availableDates.add(date);
        print("Available Date: $date");
      }
    }

    return availableDates;
  }

  initialPref() async {
    print(constant.userType);
    setState(() {
      isLoading = true;
    });
    if (constant.userType != constant.exhibitorUser) {
      dynamic response = await apiValue.getExhibitorTeamList(
          context,
          constant.userType == constant.exhibitorUser
              ? constant.userId
              : widget.exhibitorId);
      if (response != null) {
        setState(() {
          isLoading = false;
          var tempList = response as List;
          exhibitorTeamList =
              tempList.map((i) => ExhibitorTeamListModel.fromJson(i)).toList();
          print(exhibitorTeamList.length);
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      dynamic response = await apiValue.getExhibitorProfile(context);
      if (response != null) {
        setState(() {
          isLoading = false;
          var temp = response;
          exhibitorDetails = ExhibitorTeamListModel.fromJson(temp);
          dateSlots = exhibitorDetails!.dateList!
              .map((date) => date.dateSlot!)
              .toList();
          if (dateSlots.isNotEmpty) {
            selectedDate = dateSlots[0];
            updateTimeSlotsForSelectedDate();
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void updateTimeSlotsForSelectedDate() {
    if (exhibitorDetails != null && selectedDate.isNotEmpty) {
      var selectedDateSlot = exhibitorDetails!.dateList!.firstWhere(
          (date) => date.dateSlot == selectedDate,
          orElse: () => DateSlotsModel(dateSlot: selectedDate));

      timeSlots = selectedDateSlot.timeList ?? [];
      generateMainTimeSlots();
    }
  }

  void generateMainTimeSlots() {
    Set<String> uniqueHours = {};
    for (var slot in timeSlots) {
      String hour = slot.time!.split(":")[0];
      uniqueHours.add(hour);
    }
    mainTimeSlots.clear();
    mainTimeSlots.addAll(uniqueHours.map((hour) => "$hour:00").toList());
    mainTimeSlots.sort((a, b) =>
        int.parse(a.split(":")[0]).compareTo(int.parse(b.split(":")[0])));
  }

  void onDateSelected(String date) {
    setState(() {
      if (date.isNotEmpty) {
        selectedDate = date;
        isDateSelected = true;
        updateTimeSlotsForSelectedDate();
      } else {
        selectedDate = '';
        isDateSelected = false;
      }
    });
  }

  void onOptionSelected(ExhibitorTeamListModel option) {
    setState(() {
      exhibitorDetails = option;
      if (exhibitorDetails != null && exhibitorDetails!.dateList != null) {
        final uniqueDates = <String>{};
        dateSlots = exhibitorDetails!.dateList!
            .where((date) =>
                // Keep only future dates and handle duplicates
                date.dateSlot != null &&
                DateTime.parse(date.dateSlot!).isAfter(DateTime.now()) &&
                uniqueDates.add(date.dateSlot!))
            .map((date) => date.dateSlot!)
            .toList();

        if (dateSlots.isNotEmpty) {
          selectedDate = dateSlots[0];
          updateTimeSlotsForSelectedDate();
        } else {
          selectedDate = '';
        }
      }
    });
  }

  // List<TimeSlotsModel> getTimeSlotsForHour(String hour) {
  //   var selectedDateSlot = exhibitorDetails!.dateList!
  //       .firstWhere((date) => date.dateSlot == selectedDate);
  //   return selectedDateSlot.timeList!
  //       .where((slot) => slot.time!.startsWith(hour))
  //       .toList();
  // }
  List<TimeSlotsModel> getTimeSlotsForHour(String hour) {
    var selectedDateSlot = exhibitorDetails!.dateList!
        .firstWhere((date) => date.dateSlot == selectedDate);

    List<TimeSlotsModel> slotsForHour = selectedDateSlot.timeList!
        .where((slot) => slot.time!.startsWith(hour))
        .toList();

    // --- FILTER OUT PAST TIMES ---
    DateTime now = DateTime.now();
    DateTime selectedDateTime = DateTime.parse(selectedDate);

    // If selected date is today → remove slots before current time
    if (selectedDateTime.year == now.year &&
        selectedDateTime.month == now.month &&
        selectedDateTime.day == now.day) {
      slotsForHour = slotsForHour.where((slot) {
        if (slot.time == null) return false;

        // slot.time is like "10:30"
        final parts = slot.time!.split(":");
        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = int.tryParse(parts[1]) ?? 0;

        final slotDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          hour,
          minute,
        );

        return slotDateTime.isAfter(now);
      }).toList();
    }

    return slotsForHour;
  }

  bool isTimeSlotBooked(String selectedTime) {
    return bookedTimes.contains(selectedTime);
  }

  void submitMeetingRequest() async {
    if (exhibitorDetails == null) {
      showToast('Please select a team member');
      return;
    }
    if (selectedDate == '') {
      showToast('Please select a date');
      return;
    }
    if (selectedTime == '') {
      showToast('Please select a time slot');
      return;
    }

    if (isTimeSlotBooked(selectedTime)) {
      showToast('This time slot is already booked, please select another.');
      return;
    }
    setState(() {
      isButtonLoading = true;
    });

    dynamic response = await apiValue.submitExhibitorMeetingRequest(
      context,
      widget.exhibitorId,
      exhibitorDetails!.id ?? '',
      selectedDate,
      selectedTime,
      _messageController.text,
    );

    if (response != null) {
      setState(() {
        isButtonLoading = false;
      });

      if (response['title'] == 'Success') {
        showToast(response['message']);
        Navigator.pop(context);
      } else {
        _showPopup("", response['message']);
      }
    } else {
      setState(() {
        isButtonLoading = false;
      });
      showToast('An error occurred');
    }
  }

  void _showPopup(String title, String message) {
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
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontSize: 16,
                    fontSize: convertFigmaToUIWidth(16, width),
                    color: Colors.black54,
                  ),
                ),
                // SizedBox(height: 20),
                SizedBox(
                  height: convertFigmaToUIWidth(20, width),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: cyangreen,
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
              constant.userType == constant.exhibitorUser
                  ? "Meeting Slots"
                  : "Meeting Request",
              style: TextStyle(
                  height: 1.5,
                  fontSize: convertFigmaToUIWidth(15, width),
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: cyangreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(10), child: SizedBox()),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: cyangreen))
            : Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(204, 232, 234, 0.7),
                ),
                height: height,
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            if (constant.userType != constant.exhibitorUser)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showDropdown = !showDropdown;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 25),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color:
                                          Color.fromRGBO(255, 255, 255, 0.8)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Request a meeting with',
                                        style: TextStyle(
                                            height: 1.5,
                                            color:
                                                Color.fromRGBO(85, 85, 85, 1),
                                            // fontSize: 13,
                                            fontSize: convertFigmaToUIWidth(
                                                13, width),
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Icon(
                                        showDropdown
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        color: Color.fromRGBO(85, 85, 85, 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(height: 10),
                            if (constant.userType != constant.exhibitorUser)
                              if (showDropdown) ...[
                                SizedBox(
                                    height: convertFigmaToUIWidth(3, width)),
                                CustomDropdown(
                                  options: exhibitorTeamList,
                                  selectedOptions: exhibitorDetails,
                                  onOptionSelected:
                                      (ExhibitorTeamListModel option) {
                                    setState(() {
                                      exhibitorDetails = option;
                                      if (exhibitorDetails != null) {
                                        if (option.dateList != null) {
                                          dateSlots = option.dateList!
                                              .map((date) => date.dateSlot!)
                                              .toList();
                                          if (dateSlots.isNotEmpty) {
                                            selectedDate = dateSlots[0];
                                            updateTimeSlotsForSelectedDate();
                                          }
                                        } else {
                                          showToast('Not available!');
                                        }
                                      }
                                    });
                                  },
                                  onClose: () {
                                    setState(() {
                                      showDropdown = false;
                                    });
                                  },
                                  // bookedDates: widget.bookedDates,
                                  bookedDates: getAvailableDates(),
                                  onDateSelected: onDateSelected,
                                ),
                              ],
                            SizedBox(height: 10),
                            if (constant.userType != constant.exhibitorUser)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 25),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color.fromRGBO(255, 255, 255, 0.8)),
                                child: TextField(
                                  controller: _messageController,
                                  maxLines: 3,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  textAlign: TextAlign.start,
                                  cursorColor: cyangreen,
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color.fromRGBO(85, 85, 85, 1),
                                      fontSize:
                                          convertFigmaToUIWidth(13, width),
                                      fontWeight: FontWeight.w400),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 5),
                                    hintText: 'Type your message here!',
                                    hintStyle: TextStyle(
                                        height: 1.5,
                                        color: Color.fromRGBO(85, 85, 85, 1),
                                        // fontSize: 13,
                                        fontSize:
                                            convertFigmaToUIWidth(13, width),
                                        fontWeight: FontWeight.w400),
                                  ),
                                  maxLength: 200,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(200)
                                  ],
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ),
                            if (exhibitorDetails != null) SizedBox(height: 20),
                            if (exhibitorDetails != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          if (isDateSelected &&
                                              dateSlots.isNotEmpty)
                                            ListView.separated(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: mainTimeSlots.length,
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                      height:
                                                          convertFigmaToUIWidth(
                                                              10, width)),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int mainIndex) {
                                                String hour =
                                                    mainTimeSlots[mainIndex]
                                                        .split(":")[0];
                                                List<TimeSlotsModel>
                                                    filteredSlots =
                                                    getTimeSlotsForHour(hour);
                                                return GridView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      filteredSlots.length,
                                                  controller: _scrollController,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    crossAxisSpacing: 6,
                                                    mainAxisExtent: 33,
                                                    mainAxisSpacing: 6,
                                                  ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: filteredSlots[
                                                                          index]
                                                                      .isBooked ==
                                                                  'true' ||
                                                              constant.userType ==
                                                                  constant
                                                                      .exhibitorUser
                                                          ? () {}
                                                          : () {
                                                              setState(() {
                                                                selectedTime =
                                                                    filteredSlots[index]
                                                                            .time ??
                                                                        '';
                                                              });
                                                            },
                                                      child: Container(
                                                        // width: 65,
                                                        width:
                                                            convertFigmaToUIWidth(
                                                                65, width),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: filteredSlots[
                                                                          index]
                                                                      .isBooked ==
                                                                  'true'
                                                              ? Color.fromRGBO(
                                                                  255,
                                                                  239,
                                                                  239,
                                                                  1)
                                                              : selectedTime ==
                                                                      filteredSlots[
                                                                              index]
                                                                          .time
                                                                  ? cyangreen
                                                                  : Color
                                                                      .fromRGBO(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          0.6),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          border: Border.all(
                                                            color: selectedTime ==
                                                                    filteredSlots[
                                                                            index]
                                                                        .time
                                                                ? cyangreen
                                                                : Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        0.6),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            filteredSlots[index]
                                                                    .time ??
                                                                '',
                                                            style: TextStyle(
                                                              height: 1.5,
                                                              // fontSize: 10,
                                                              fontSize:
                                                                  convertFigmaToUIWidth(
                                                                      10,
                                                                      width),
                                                              color: selectedTime ==
                                                                      filteredSlots[
                                                                              index]
                                                                          .time
                                                                  ? Colors.white
                                                                  : Color
                                                                      .fromRGBO(
                                                                          85,
                                                                          85,
                                                                          85,
                                                                          1),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          if (!isDateSelected ||
                                              dateSlots.isEmpty)
                                            Center(
                                              child: Text(
                                                "Please select a date",
                                                style: TextStyle(
                                                    height: 1.5,
                                                    color: Color.fromRGBO(
                                                        85, 85, 85, 1),
                                                    // fontSize: 13,
                                                    fontSize:
                                                        convertFigmaToUIWidth(
                                                            13, width),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // SizedBox(height: 35),
                            SizedBox(
                              height: convertFigmaToUIWidth(35, width),
                            ),
                            //--------------------------Request button------------------------------------//
                            if (constant.userType != constant.exhibitorUser)
                              isButtonLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                          color: cyangreen),
                                    )
                                  : GestureDetector(
                                      onTap: isDateSelected
                                          ? submitMeetingRequest
                                          : null, // Disable if no date is selected
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 30),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isDateSelected
                                              ? cyangreen
                                              : Colors
                                                  .grey, // Change color if disabled
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Center(
                                          child: Text(
                                            constant.userType ==
                                                    constant.exhibitorUser
                                                ? "Update"
                                                : 'Request',
                                            style: TextStyle(
                                                height: 1.5,
                                                // fontSize: 13,
                                                fontSize: convertFigmaToUIWidth(
                                                    13, width),
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),

                            SizedBox(
                              height: convertFigmaToUIWidth(200, width),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget dropDownBuilder(String hintText, List type, String? value) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color.fromRGBO(255, 255, 255, 0.6),
      ),
      child: DropdownButtonFormField(
        value: value,
        icon: Icon(Icons.arrow_drop_down_sharp,
            color: Color.fromRGBO(2, 141, 148, 0.3),
            size: convertFigmaToUIWidth(25, width)),
        style: TextStyle(
            height: 1.5,
            color: Color.fromRGBO(85, 85, 85, 1),
            // fontSize: 13,
            fontSize: convertFigmaToUIWidth(13, width),
            fontWeight: FontWeight.w400),
        onChanged: (value) {
          setState(() {
            value = value;
          });
        },
        items: type.map((type) {
          return DropdownMenuItem<String>(
              value: type,
              child: Text(type,
                  style: const TextStyle(
                      height: 1.5, fontWeight: FontWeight.w400)));
        }).toList(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              height: 1.5,
              color: Color.fromRGBO(85, 85, 85, 1),
              // fontSize: 13,
              fontSize: convertFigmaToUIWidth(13, width),
              fontWeight: FontWeight.w400),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final List<ExhibitorTeamListModel> options;
  final ExhibitorTeamListModel? selectedOptions;
  final Function(ExhibitorTeamListModel) onOptionSelected;
  final VoidCallback onClose;
  final List<String> bookedDates;
  final Function(String) onDateSelected;

  const CustomDropdown({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onOptionSelected,
    required this.onClose,
    required this.bookedDates,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    debugPrint("bookedDatessss: $bookedDates");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      padding: const EdgeInsets.only(left: 0, right: 15, top: 20, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromRGBO(255, 255, 255, 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              ExhibitorTeamListModel option = options[index];
              final isSelected = option == selectedOptions;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          onOptionSelected(option);
                        },
                        child: Container(
                          // height: 18,
                          // width: 18,
                          height: convertFigmaToUIWidth(18, width),
                          width: convertFigmaToUIWidth(18, width),
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromRGBO(2, 141, 148, 0.6)
                                : const Color.fromRGBO(190, 225, 228, 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isSelected
                              ? Icon(Icons.check,
                                  color: Colors.white,
                                  size: convertFigmaToUIWidth(10, width))
                              : const SizedBox(),
                        ),
                      ),
                      Text(
                        option.name ?? '',
                        style: TextStyle(
                          height: 1.5,
                          // fontSize: 12,
                          fontSize: convertFigmaToUIWidth(12, width),
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(85, 85, 85, 0.8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: convertFigmaToUIWidth(16, width)),
                  if (isSelected && bookedDates.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color.fromRGBO(190, 225, 228, 0.8),
                            width: 1.0,
                          ),
                        ),
                        child: IntrinsicWidth(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              isDense: true,
                              isExpanded: false,
                              value: null,
                              dropdownColor: Colors.white,
                              menuMaxHeight: 150,
                              alignment: Alignment.center,
                              style: TextStyle(
                                // fontSize: 12,
                                fontSize: convertFigmaToUIWidth(12, width),
                                fontWeight: FontWeight.w400,
                                color: textColor,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Center(
                                    child: Text(
                                      "Select Date",
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                                ...bookedDates.map((date) {
                                  return DropdownMenuItem<String>(
                                    value: date,
                                    alignment: Alignment.center,
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          DateFormatter.formatDayWithSuffix(
                                              date),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  onDateSelected('');
                                } else {
                                  onDateSelected(value);
                                }
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: InputBorder.none,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              icon: Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  // size: 20,
                                  size: convertFigmaToUIWidth(20, width),
                                  color: Colors.grey,
                                ),
                              ),
                              iconSize: 24,
                              elevation: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
