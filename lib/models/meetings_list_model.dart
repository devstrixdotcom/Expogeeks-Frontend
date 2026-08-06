// class MeetingListModel {
//   String? id;
//   String? visitorName;
//   String? teamName;
//   String? status;
//   String? message;
//   String? replyMessage;
//   String? exhibitorName;
//   String? categoryName;
//   String? meetingDate;
//   String? meetingTime;
//   String? imageLink;

//   MeetingListModel({
//     this.id,
//     this.visitorName,
//     this.teamName,
//     this.status,
//     this.message,
//     this.replyMessage,
//     this.exhibitorName,
//     this.categoryName,
//     this.meetingDate,
//     this.meetingTime,
//     this.imageLink,
//   });

//   MeetingListModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     visitorName = json['visitorName'];
//     teamName = json['teamName'];
//     status = json['status'];
//     message = json['message'];
//     replyMessage = json['reply_message'];
//     exhibitorName = json['exhibitorName'];
//     categoryName = json['categoryName'];
//     meetingDate = json['meetingDate'];
//     meetingTime = json['meetingTime'];
//     imageLink = json['imageLink'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['visitorName'] = this.visitorName;
//     data['teamName'] = this.teamName;
//     data['status'] = this.status;
//     data['message'] = this.message;
//     data['reply_message'] = this.replyMessage;
//     data['exhibitorName'] = this.exhibitorName;
//     data['categoryName'] = this.categoryName;
//     data['meetingDate'] = this.meetingDate;
//     data['meetingTime'] = this.meetingTime;
//     data['imageLink'] = this.imageLink;
//     return data;
//   }
// }

class MeetingListModel {
  String? id;
  String? visitorName;
  String? teamName;
  String? status;
  String? message;
  String? replyMessage;
  String? exhibitorName;
  String? showName;
  String? categoryName;
  String? meetingDate;
  String? meetingTime;
  String? stallNo;
  String? imageLink;
  List<DateSlotsModel>? dateList;

  MeetingListModel({
    this.id,
    this.visitorName,
    this.teamName,
    this.status,
    this.message,
    this.replyMessage,
    this.exhibitorName,
    this.showName,
    this.categoryName,
    this.meetingDate,
    this.meetingTime,
    this.stallNo,
    this.imageLink,
    this.dateList,
  });

  MeetingListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitorName = json['visitorName'];
    teamName = json['teamName'];
    status = json['status'];
    message = json['message'];
    replyMessage = json['reply_message'];
    exhibitorName = json['exhibitorName'];
    showName = json['showName'];
    categoryName = json['categoryName'];
    meetingDate = json['meetingDate'];
    meetingTime = json['meetingTime'];
    stallNo = json['stallNo'];
    imageLink = json['imageLink'];
    if (json['dateSlots'] != null) {
      dateList = [];
      json['dateSlots'].forEach((v) {
        dateList!.add(DateSlotsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['visitorName'] = visitorName;
    data['teamName'] = teamName;
    data['status'] = status;
    data['message'] = message;
    data['reply_message'] = replyMessage;
    data['exhibitorName'] = exhibitorName;
    data['showName'] = showName;
    data['categoryName'] = categoryName;
    data['meetingDate'] = meetingDate;
    data['meetingTime'] = meetingTime;
    data['stallNo'] = stallNo;
    data['imageLink'] = imageLink;
    if (dateList != null) {
      data['dateSlots'] = dateList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DateSlotsModel {
  String? dateSlot;
  List<TimeSlotsModel>? timeList;
  String? exhibitionName;

  DateSlotsModel({
    this.dateSlot,
    this.timeList,
    this.exhibitionName,
  });

  DateSlotsModel.fromJson(Map<String, dynamic> json) {
    dateSlot = json['dateSlot'];
    if (json['timeSlots'] != null) {
      timeList = [];
      json['timeSlots'].forEach((v) {
        timeList!.add(TimeSlotsModel.fromJson(v));
      });
    }
    ;
    exhibitionName = json['exhibitionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['dateSlot'] = dateSlot;
    if (timeList != null) {
      data['timeSlots'] = timeList!.map((v) => v.toJson()).toList();
    }
    data['exhibitionName'] = exhibitionName;
    return data;
  }
}

class TimeSlotsModel {
  String? time;
  String? isBooked;
  String? meetingStatus; // Add this field

  TimeSlotsModel({
    this.time,
    this.isBooked,
    this.meetingStatus,
  });

  TimeSlotsModel.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    isBooked = json['isBooked'];
    meetingStatus = json['meetingStatus']; // Add this line
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['time'] = time;
    data['isBooked'] = isBooked;
    data['meetingStatus'] = meetingStatus;
    return data;
  }
}
