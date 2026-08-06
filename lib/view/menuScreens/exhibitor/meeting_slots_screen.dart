
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/models/exhibitor_team_list_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';

import 'package:flutter/material.dart';

import '../../../models/exhibition_list_model.dart';
import '../../../utils/helper_functions.dart';

class MeetingSlotsScreen extends StatefulWidget {
  MeetingSlotsScreen({super.key});

  @override
  State<MeetingSlotsScreen> createState() => _MeetingSlotsScreenState();
}

class _MeetingSlotsScreenState extends State<MeetingSlotsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<DateSlotsModel> dateSlots = [];
  ExhibitorTeamListModel? exhibitorDetails;
  bool isLoading = true;

  String? selectedExhibitionId; // Store selected exhibition ID
  List<ExhibitionModel> exhibitions = []; // Store exhibition list
  @override
  void initState() {
    super.initState();
    initialPref();
  }

  initialPref() async {
    print(constant.userType);
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

    // Fetch exhibitor profile with selected exhibition ID
    if (selectedExhibitionId != null) {
      dynamic response = await apiValue.getExhibitorProfile(context,
          exhibitionId: selectedExhibitionId);
      if (response != null) {
        setState(() {
          isLoading = false;
          exhibitorDetails = ExhibitorTeamListModel.fromJson(response);
          if (exhibitorDetails!.dateList != null) {
            print(exhibitorDetails!.dateList![0].timeList!.length);
            print("hehe    " + exhibitorDetails!.dateList!.length.toString());
            dateSlots = exhibitorDetails!.dateList ?? [];
            print("hehe DATE    " + dateSlots.length.toString());
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> generateMainTimeSlots(List<TimeSlotsModel> list) {
    List<String> mainTimeSlots = [];
    Set<String> uniqueHours = {};
    for (var slot in list) {
      String hour = slot.time!.split(":")[0];
      uniqueHours.add(hour);
    }
    mainTimeSlots.clear();
    mainTimeSlots.addAll(uniqueHours.map((hour) => "$hour:00").toList());
    mainTimeSlots.sort((a, b) =>
        int.parse(a.split(":")[0]).compareTo(int.parse(b.split(":")[0])));
    return mainTimeSlots;
  }

  List<TimeSlotsModel> getTimeSlotsForHour(
      String hour, List<TimeSlotsModel> list) {
    return list.where((slot) => slot.time!.startsWith(hour)).toList();
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
    Size size = MediaQuery.of(context).size;
    List<DateSlotsModel> bookedDateSlots = dateSlots.where((dateSlot) {
      bool hasBookedSlot = dateSlot.timeList?.any((timeSlot) {
            return timeSlot.isBooked?.trim() == "true" &&
                timeSlot.exhibitionName ==
                    exhibitions
                        .firstWhere((ex) => ex.id == selectedExhibitionId,
                            orElse: () => ExhibitionModel(
                                exhibitionName: timeSlot.exhibitionName))
                        .exhibitionName;
          }) ??
          false;

      print("Date: ${dateSlot.dateSlot}, Has Booked Slot: $hasBookedSlot");
      return hasBookedSlot;
    }).toList();

    print("Original Date Slots Length: ${dateSlots.length}");
    print("Filtered Booked Slots Length: ${bookedDateSlots.length}");

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
          // backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Meeting Slots",
              style: TextStyle(
                  fontSize: convertFigmaToUIWidth(20, width),
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: cyangreen,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(10), child: SizedBox()),
        ),
        body: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Color.fromRGBO(204, 232, 234, 0.7),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: cyangreen))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add dropdown here
                    if (exhibitions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: DropdownButton<String>(
                            style: TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(85, 85, 85, 1),
                              // fontSize: 13,
                              fontSize: convertFigmaToUIWidth(13, width),
                              fontWeight: FontWeight.w400,
                            ),
                            value: selectedExhibitionId,
                            isExpanded: true,
                            underline: SizedBox(),
                            items:
                                exhibitions.map((ExhibitionModel exhibition) {
                              return DropdownMenuItem<String>(
                                value: exhibition.id,
                                child: Text(exhibition.exhibitionName ?? ''),
                              );
                            }).toList(),
                            onChanged: (newValue) async {
                              setState(() {
                                selectedExhibitionId = newValue;
                                isLoading = true;
                              });
                              // Fetch exhibitor profile with new exhibition ID
                              dynamic response =
                                  await apiValue.getExhibitorProfile(context,
                                      exhibitionId: selectedExhibitionId);
                              if (response != null) {
                                setState(() {
                                  isLoading = false;
                                  exhibitorDetails =
                                      ExhibitorTeamListModel.fromJson(response);
                                  dateSlots = exhibitorDetails!.dateList ?? [];
                                });
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        child: bookedDateSlots.isEmpty
                            ? Center(
                                child: Text(
                                  'No slots booked yet!',
                                  style: TextStyle(
                                    // fontSize: 13,
                                    fontSize: convertFigmaToUIWidth(13, width),
                                    height: 1.5,
                                    color: Color.fromRGBO(85, 85, 85, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  // SizedBox(height: 20),
                                  ListView.separated(
                                    itemCount: bookedDateSlots.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(height: 30);
                                    },
                                    itemBuilder: (BuildContext context,
                                        int parentIndex) {
                                      List<TimeSlotsModel> timeSlots =
                                          bookedDateSlots[parentIndex]
                                                  .timeList ??
                                              [];

                                      List<String> mainTimeSlots =
                                          generateMainTimeSlots(timeSlots);
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                DateFormatter
                                                    .formatDayWithSuffix(
                                                        bookedDateSlots[
                                                                    parentIndex]
                                                                .dateSlot ??
                                                            ""),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  height: 1.5,
                                                  color: Color.fromRGBO(
                                                      85, 85, 85, 1),
                                                  // fontSize: 13,
                                                  fontSize:
                                                      convertFigmaToUIWidth(
                                                          13, width),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // SizedBox(height: 15),
                                          SizedBox(
                                              height: convertFigmaToUIWidth(
                                                  15, width)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        mainTimeSlots.length,
                                                    separatorBuilder: (context,
                                                            index) =>
                                                        SizedBox(
                                                            height:
                                                                convertFigmaToUIWidth(
                                                                    10, width)),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int mainIndex) {
                                                      String hour =
                                                          mainTimeSlots[
                                                                  mainIndex]
                                                              .split(":")[0];
                                                      List<TimeSlotsModel>
                                                          filteredSlots =
                                                          getTimeSlotsForHour(
                                                              hour, timeSlots);
                                                      return GridView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: filteredSlots
                                                            .length,
                                                        controller:
                                                            _scrollController,
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
                                                          return GestureDetector(
                                                            onTap: () {
                                                              _showPopup(
                                                                  context,
                                                                  filteredSlots[
                                                                      index],
                                                                  bookedDateSlots[
                                                                          parentIndex]
                                                                      .dateSlot!);
                                                            },
                                                            child: Container(
                                                              // width: 65,
                                                              width:
                                                                  convertFigmaToUIWidth(
                                                                      65,
                                                                      width),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: _getTimeSlotColor(
                                                                    filteredSlots[
                                                                        index]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  filteredSlots[
                                                                              index]
                                                                          .time ??
                                                                      '',
                                                                  style:
                                                                      TextStyle(
                                                                    height: 1.5,
                                                                    // fontSize:
                                                                    //     10,
                                                                    fontSize:
                                                                        convertFigmaToUIWidth(
                                                                            10,
                                                                            width),
                                                                    color: _getTextColor(
                                                                        filteredSlots[
                                                                            index]),
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: convertFigmaToUIWidth(200, width) ?? 200,),
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

  void _showPopup(BuildContext context, TimeSlotsModel selectedSlot,
      String dateSlot) async {
    var width = MediaQuery.of(context).size.width;

    if (selectedSlot.meetingstatus != 'Pending' &&
        selectedSlot.meetingstatus != 'Accepted') {
      showToast('No meetings available for this date.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      var response = await apiValue.getExhibitorProfile(context,
          exhibitionId: selectedExhibitionId);
      Navigator.of(context).pop();

      if (response != null) {
        var exhibitorDetails = ExhibitorTeamListModel.fromJson(response);

        var selectedDateSlot = exhibitorDetails.dateList?.firstWhere(
          (date) => date.dateSlot == dateSlot,
          orElse: () => DateSlotsModel(),
        );

        if (selectedDateSlot != null && selectedDateSlot.dateSlot != null) {
          var exactTimeSlot = selectedDateSlot.timeList?.firstWhere(
            (timeSlot) => timeSlot.time == selectedSlot.time,
            orElse: () => TimeSlotsModel(),
          );

          if (exactTimeSlot != null) {
            String visitorName = exactTimeSlot.visitorName ?? 'N/A';
            String weddingDate = exactTimeSlot.expected_date ?? 'N/A';
            String budget = exactTimeSlot.estimated_budget ?? 'N/A';
            String venue = exactTimeSlot.venue ?? 'Not set';
            String status = exactTimeSlot.meetingstatus ?? 'N/A';

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  title: Text(
                    'Meeting Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // fontSize: 20.0,
                      fontSize: convertFigmaToUIWidth(20, width),
                      fontWeight: FontWeight.bold,
                      color: cyangreen,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Visitor:', visitorName),
                        _buildDetailRow('Wedding Date:', weddingDate),
                        _buildDetailRow('Budget:', budget),
                        _buildDetailRow('Venue:', venue),
                        _buildDetailRow('Status:', status),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            showToast('Time slot not found.');
          }
        } else {
          showToast('Date slot not found.');
        }
      } else {
        showToast('Failed to fetch exhibitor profile.');
      }
    } catch (e) {
      Navigator.of(context).pop();
      showToast('Failed to load data: $e');
    }
  }

  Widget _buildDetailRow(String title, String value) {
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                // fontSize: 14.0,
                fontSize: convertFigmaToUIWidth(14, width),
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(fontSize: 
              // 14.0, 
              convertFigmaToUIWidth(14, width),
              color: Colors.black87),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimeSlotColor(TimeSlotsModel slot) {
    if (slot.isBooked == 'true') {
      switch (slot.meetingstatus) {
        case 'Pending':
          return Pink;
        case 'Accepted':
          return cyangreen;
        case 'Rejected':
          return const Color.fromARGB(255, 119, 44, 39);
        default:
          return Color.fromRGBO(255, 255, 255, 0.6);
      }
    } else {
      return Color.fromRGBO(255, 255, 255, 0.6);
    }
  }

  Color _getTextColor(TimeSlotsModel slot) {
    if (slot.isBooked == 'true' && slot.meetingstatus == 'Accepted') {
      return Colors.white;
    } else {
      return const Color.fromRGBO(85, 85, 85, 1);
    }
  }
}
