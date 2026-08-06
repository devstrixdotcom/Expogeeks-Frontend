import 'package:device_calendar/device_calendar.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/data/local/contants.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/organization_item_details.dart';

class ReminderAlertBoxDialog extends StatefulWidget {
  final DateTime eventDate;
  final String eventId;
  final String eventName;
  final bool isMeeting;
  final String? startTime;
  final List<DateItem>? dateList;
  final bool showDropdown;

  const ReminderAlertBoxDialog({
    super.key,
    required this.eventDate,
    required this.eventId,
    required this.eventName,
    required this.isMeeting,
    this.startTime,
    this.dateList,
    this.showDropdown = true,
  });

  @override
  State<ReminderAlertBoxDialog> createState() => _ReminderAlertBoxDialogState();
}

class _ReminderAlertBoxDialogState extends State<ReminderAlertBoxDialog> {
  bool oneHourReminderSelected = false;
  bool oneDayReminderSelected = false;
  bool oneWeekReminderSelected = false;
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  var reminderMap;
  DateTime? selectedDate;

  bool get isAnyReminderSelected {
    return oneHourReminderSelected ||
        oneDayReminderSelected ||
        oneWeekReminderSelected;
  }

  String _formatDateWithOrdinal(DateTime date) {
    final day = date.day;
    String daySuffix;

    if (day >= 11 && day <= 13) {
      daySuffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          daySuffix = 'st';
          break;
        case 2:
          daySuffix = 'nd';
          break;
        case 3:
          daySuffix = 'rd';
          break;
        default:
          daySuffix = 'th';
          break;
      }
    }

    return DateFormat('EEE, d\'$daySuffix\' MMM yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();

    if (!widget.showDropdown) {
      selectedDate = widget.eventDate;
    } else if (widget.dateList != null && widget.dateList!.length == 1) {
      String cleanedDate = widget.dateList!.first.showDate!
          .replaceAll(RegExp(r'(st|nd|rd|th)'), '')
          .trim();

      try {
        selectedDate = DateFormat('EEE dd MMM yyyy').parse(cleanedDate);
      } catch (e) {
        print('Error parsing date with day: $e');
        try {
          selectedDate = DateFormat('dd MMM yyyy').parse(cleanedDate);
        } catch (e) {
          print('Fallback parsing failed: $e');
          selectedDate = null;
        }
      }
    }

    initialPref();
    print("START TIME: ${widget.startTime}");
  }

  initialPref() async {
    dynamic tempMap = await getReminderMapData();
    if (tempMap != null) {
      setState(() {
        reminderMap = tempMap;
        print(reminderMap);
        if (reminderMap != null) {
          print("Hello");
          print(reminderMap!['isOneDay'].toString());
          print(reminderMap!['isOneWeek'].toString());
          print(reminderMap!['isOneHour'].toString());
          oneDayReminderSelected = reminderMap!['isOneDay'] ?? false;
          oneWeekReminderSelected = reminderMap!['isOneWeek'] ?? false;
          oneHourReminderSelected = reminderMap!['isOneHour'] ?? false;
        }
      });
    } else {
      _requestPermissions();
    }
  }

  Future getReminderMapData() async {
    try {
      var rem = hiveBox.get('reminders');
      print('Reminders from Hive: $rem');
      print('---------------------------');
      if (rem == null) {
        return null;
      }
      List allReminders = List.from(rem as List<dynamic>);
      return allReminders.firstWhere(
          (reminder) =>
              reminder['exhibitorId'].toString() == widget.eventId.toString() &&
              reminder['userId'].toString() == constant.phoneValue.toString(),
          orElse: () => null);
    } catch (e) {
      print('Error fetching reminder data: $e');
      return null;
    }
  }

  Future<void> _requestPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
      final permissionRequestResult =
          await _deviceCalendarPlugin.requestPermissions();
      if (!permissionRequestResult.isSuccess ||
          !permissionRequestResult.data!) {
        _showPermissionDeniedDialog();
        return;
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission denied'),
          content: Text(
              'Calendar access is required to set reminders. Please enable it in the device settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReminder() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        await _requestPermissions();
        permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          showToast("Calendar permissions are required to set reminders.");
          return;
        }
      }
      var calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.data == null || calendarsResult.data!.isEmpty) {
        print("No calendars available. Result: ${calendarsResult.errors}");
        showToast("No calendars available. Please add a calendar first.");
        return;
      }
      Calendar? calendar = await _findOrCreateCalendar(calendarsResult.data!);
      if (calendar == null) {
        showToast('Unable to find or create a suitable calendar.');
        return;
      }
      if (selectedDate == null) {
        showToast('Please select a date');
        return;
      }
      DateTime reminderDate;
      if (oneHourReminderSelected) {
        final timeFormat = DateFormat('HH:mm');
        DateTime parsedStartTime = timeFormat.parse(widget.startTime!);
        reminderDate = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          parsedStartTime.hour,
          parsedStartTime.minute,
        ).subtract(Duration(minutes: 45));
      } else if (oneDayReminderSelected) {
        reminderDate = selectedDate!.subtract(Duration(days: 1));
      } else if (oneWeekReminderSelected) {
        reminderDate = selectedDate!.subtract(Duration(days: 7));
      } else {
        showToast('Please select a reminder time');
        return;
      }
      try {
        var localTime = tz.TZDateTime.from(reminderDate, tz.local);
        var endTime = localTime.add(Duration(minutes: 45));
        var event = Event(calendar.id,
            title: "Event Reminder: ${widget.eventName}",
            description: "Reminder for ${widget.eventName}",
            start: localTime,
            end: endTime,
            allDay: false);
        event.reminders = [Reminder(minutes: 0)];
        event.location = "App reminder";
        var createEventResult =
            await _deviceCalendarPlugin.createOrUpdateEvent(event);
        if (createEventResult?.isSuccess ?? false) {
          showToast('Reminder added successfully');
          await _updateReminderMap();
          showLocalNotification(
              1,
              widget.isMeeting
                  ? 'Meeting reminder saved'
                  : 'Event reminder saved',
              widget.isMeeting
                  ? 'Meeting Reminder for ${widget.eventName} saved for ${DateFormat('dd MMM yyyy').format(localTime)}'
                  : '${widget.eventName} reminder saved for ${DateFormat('dd MMM yyyy').format(localTime)}');
        } else {
          print("Failed to create event. Errors: ${createEventResult?.errors}");
          showToast('Failed to save event. Check calendar settings.');
        }
      } on tz.LocationNotFoundException catch (e) {
        print("Timezone error: $e");
        showToast("Unable to set reminder due to timezone issues.");
      }
    } catch (e, stackTrace) {
      showToast('An error occurred while saving reminder.');
      print("Comprehensive error in save Reminder: $e");
      print("Detailed stack trace: $stackTrace");
      throw '';
    }
  }

  Future<Calendar?> _findOrCreateCalendar(List<Calendar> calendars) async {
    print(
        "Available calendars: ${calendars.map((c) => '${c.name} (${c.id})').join(', ')}");
    for (var calendar in calendars) {
      if (calendar.isReadOnly == false) {
        print("Found writable calendar: ${calendar.name} (${calendar.id})");
        return calendar;
      }
    }
    print("No writable calendar found. Attempting to create a new one.");
    var createCalendarResult =
        await _deviceCalendarPlugin.createCalendar('My App Calendar');
    if (createCalendarResult.isSuccess && createCalendarResult.data != null) {
      print("Created new calendar with ID: ${createCalendarResult.data}");
      return Calendar(id: createCalendarResult.data!, name: 'My App Calendar');
    }
    print(
        "Failed to create a new calendar. Error: ${createCalendarResult.errors}");
    return null;
  }

  Future<void> _updateReminderMap() async {
    var reminderMapData = hiveBox.get('reminders');
    List allReminders = reminderMapData == null ? [] : reminderMapData as List;
    print("Existing reminders count: ${allReminders.length}");
    print("Existing reminders: ${allReminders}");

    if (reminderMapData != null) {
      for (int i = 0; i < allReminders.length; i++) {
        if (allReminders[i]['exhibitorId'] == widget.eventId &&
            allReminders[i]['userId'] == constant.phoneValue) {
          allReminders.removeAt(i);
        }
      }
    }
    dynamic newReminder = {
      "exhibitorId": widget.eventId,
      "isOneDay": oneDayReminderSelected,
      "isOneWeek": oneWeekReminderSelected,
      "isOneHour": oneHourReminderSelected,
      "userId": constant.phoneValue,
    };
    allReminders.add(newReminder);
    await hiveBox.put("reminders", allReminders);
  }

  bool _isDateBefore1Hour(DateTime date) {
    DateTime now = DateTime.now();

    final timeFormat = DateFormat('HH:mm');
    DateTime parsedStartTime = timeFormat.parse(widget.startTime!);

    DateTime eventDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      parsedStartTime.hour,
      parsedStartTime.minute,
    );

    return now.isBefore(eventDateTime.subtract(Duration(minutes: 45)));
  }

  bool _isDateBefore1Day(DateTime date) {
    DateTime now = DateTime.now();
    return now.isBefore(date.subtract(Duration(days: 1)));
  }

  bool _isDateBefore1Week(DateTime date) {
    DateTime now = DateTime.now();
    return now.isBefore(date.subtract(Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Center(
          child: Text(
            widget.isMeeting ? "Set Reminder for Meeting" : "Set Reminder",
            style: TextStyle(
              fontSize: convertFigmaToUIWidth(18, width),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showDropdown)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: widget.dateList!.length == 1
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildDateText(widget.dateList!.first),
                        )
                      : Padding(
                          padding:  EdgeInsets.only(right: 9.5),
                          child: DropdownButtonFormField<DateTime>(
                            isExpanded: true,
                            value: selectedDate,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                alignLabelWithHint: true),
                            dropdownColor: Colors.white,
                            onChanged: (DateTime? newValue) {
                              setState(() {
                                selectedDate = newValue;
                                oneHourReminderSelected = false;
                                oneDayReminderSelected = false;
                                oneWeekReminderSelected = false;
                              });
                            },
                            items: [
                              DropdownMenuItem<DateTime>(
                                value: null,
                                child: Text(
                                  'Select Date',
                                  style: TextStyle(
                                    fontSize: convertFigmaToUIWidth(15, width),
                                    color: textColor,
                                  ),
                                ),
                              ),
                              ...widget.dateList!.map((dateItem) {
                                String cleanedDate = dateItem.showDate!
                                    .replaceAll(RegExp(r'(st|nd|rd|th)'), '')
                                    .trim();

                                DateTime parsedDate;
                                try {
                                  parsedDate = DateFormat('EEE dd MMM yyyy')
                                      .parse(cleanedDate);
                                } catch (e) {
                                  parsedDate = DateFormat('dd MMM yyyy')
                                      .parse(cleanedDate);
                                }

                                return DropdownMenuItem<DateTime>(
                                  value: parsedDate,
                                  child: Text(
                                    _formatDateWithOrdinal(parsedDate),
                                    style: TextStyle(
                                      fontSize:
                                          convertFigmaToUIWidth(15, width),
                                      
                                      ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                ),
              ),
            Visibility(
              visible:
                  selectedDate != null && _isDateBefore1Hour(selectedDate!),
              child: _buildCheckboxTile(
                '45 minutes before',
                oneHourReminderSelected,
                () {
                  if (selectedDate != null) {
                    setState(() {
                      oneHourReminderSelected = !oneHourReminderSelected;
                      oneDayReminderSelected = false;
                      oneWeekReminderSelected = false;
                    });
                  } else {
                    showToast('Please select a date first.');
                  }
                },
                isEnabled: selectedDate != null,
              ),
            ),
            Visibility(
              visible: selectedDate != null && _isDateBefore1Day(selectedDate!),
              child: _buildCheckboxTile('1 day before', oneDayReminderSelected,
                  () {
                setState(() {
                  oneDayReminderSelected = !oneDayReminderSelected;
                  oneWeekReminderSelected = false;
                  oneHourReminderSelected = false;
                });
              }),
            ),
            Visibility(
              visible:
                  selectedDate != null && _isDateBefore1Week(selectedDate!),
              child: _buildCheckboxTile(
                  '1 week before', oneWeekReminderSelected, () {
                setState(() {
                  oneWeekReminderSelected = !oneWeekReminderSelected;
                  oneDayReminderSelected = false;
                  oneHourReminderSelected = false;
                });
              }),
            ),
          ],
        ),
        actions: [
          Container(
            width: convertFigmaToUIWidth(200, width),
            height: convertFigmaToUIWidth(40, width),
            margin: EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAnyReminderSelected ? cyangreen : textfiledColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: isAnyReminderSelected
                  ? () async {
                      if (selectedDate == null) {
                        showToast('Please select a date first.');
                        return;
                      }
                      if (!isAnyReminderSelected) {
                        showToast(
                            'Please select at least one reminder option.');
                        return;
                      }
                      await _saveReminder();
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(
                reminderMap != null ? 'Edit' : 'Save',
                style: TextStyle(
                  fontSize: convertFigmaToUIWidth(18, width),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
        elevation: 10,
      ),
    );
  }

  Widget _buildDateText(DateItem dateItem) {
    try {
      String cleanedDate =
          dateItem.showDate!.replaceAll(RegExp(r'(st|nd|rd|th)'), '').trim();

      DateTime parsedDate;
      try {
        parsedDate = DateFormat('EEE dd MMM yyyy').parse(cleanedDate);
      } catch (e) {
        parsedDate = DateFormat('dd MMM yyyy').parse(cleanedDate);
      }

      return Text(
        _formatDateWithOrdinal(parsedDate),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      );
    } catch (e) {
      return Text(
        dateItem.showDate ?? '',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      );
    }
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    VoidCallback onChanged, {
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: CheckboxListTile(
        value: value,
        activeColor: cyangreen,
        onChanged: isEnabled ? (bool? val) => onChanged() : null,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isEnabled ? textColor : Colors.grey, // Grey out if disabled
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.grey.shade100,
      ),
    );
  }
}
