class ExhibitorTeamListModel {
  String? id;
  String? name;
  String? mobile;
  String? office_no;
  String? email;
  String? meeting_duration;
  String? imageLink;
  List<DateSlotsModel>? dateList;

  bool canBookTime(String selectedDate, String selectedTime) {
    final dateSlot = dateList?.firstWhere(
      (date) => date.dateSlot == selectedDate,
      orElse: () => DateSlotsModel(dateSlot: selectedDate),
    );

    if (dateSlot!.hasAnyBooking()) {
      return false;
    }

    final timeSlot = dateSlot.timeList?.firstWhere(
      (time) => time.time == selectedTime,
      orElse: () => TimeSlotsModel(time: selectedTime),
    );

    return !timeSlot!.isAlreadyBooked(selectedTime, selectedDate);
  }

  ExhibitorTeamListModel({
    this.id,
    this.name,
    this.mobile,
    this.office_no,
    this.email,
    this.meeting_duration,
    this.imageLink,
    this.dateList,
  });

  ExhibitorTeamListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    office_no = json['office_no'];
    email = json['email'];
    meeting_duration = json['meeting_duration'];
    imageLink = json['imageLink'];
    if (json['dateSlots'] != null) {
      dateList = [];
      json['dateSlots'].forEach((v) {
        dateList!.add(DateSlotsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['office_no'] = this.office_no;
    data['email'] = this.email;
    data['meeting_duration'] = this.meeting_duration;
    data['imageLink'] = this.imageLink;
    if (this.dateList != null) {
      data['dateSlots'] = this.dateList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DateSlotsModel {
  String? dateSlot;
  List<TimeSlotsModel>? timeList;

  bool hasAnyBooking() {
    return timeList != null && timeList!.any((slot) => slot.isBooked == "true");
  }

  DateSlotsModel({
    this.dateSlot,
    this.timeList,
  });

  DateSlotsModel.fromJson(Map<String, dynamic> json) {
    dateSlot = json['dateSlot'];
    if (json['timeSlots'] != null) {
      timeList = [];
      json['timeSlots'].forEach((v) {
        timeList!.add(TimeSlotsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dateSlot'] = this.dateSlot;
    if (this.timeList != null) {
      data['timeSlots'] = this.timeList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TimeSlotsModel {
  String? time;
  String? isBooked;
  String? meetingstatus;
  String? dateeSlot;
  String? visitorName;
  String? expected_date;
  String? estimated_budget;
  String? venue;
  String? exhibitionName;
  String? exhName;

  bool isAlreadyBooked(String selectedTime, String selectedDate) {
    if (time == selectedTime && dateeSlot == selectedDate) {
      return isBooked == "true";
    }
    return false;
  }

  TimeSlotsModel(
      {this.time,
      this.isBooked,
      this.meetingstatus,
      this.dateeSlot,
      this.visitorName,
      this.expected_date,
      this.estimated_budget,
      this.venue,
      this.exhibitionName,
      this.exhName});

  TimeSlotsModel.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    isBooked = json['isBooked'];
    meetingstatus = json['meetingStatus'];
    dateeSlot = json['dateSlot'];
    visitorName = json['visitorName'];
    expected_date = json['expected_date'];
    estimated_budget = json['estimated_budget'];
    venue = json['venue'];
    exhibitionName = json['exhibitionName'];
    exhName = json['exhName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['isBooked'] = this.isBooked;
    data['meetingStatus'] = this.meetingstatus;
    data['dateSlot'] = this.dateeSlot;
    data['visitorName'] = this.visitorName;
    data['expected_date'] = this.expected_date;
    data['estimated_budget'] = this.estimated_budget;
    data['venue'] = this.venue;
    data['exhibitionName'] = this.exhibitionName;
    data['exhName'] = this.exhName;
    return data;
  }
}
