class OrganizationListItems {
  String? id;
  String? showName;
  String? location;
  String? showStartDate;
  String? imageLink;
  String? isBooked;
  List<DateItem>? dateList;

  OrganizationListItems({
    this.id,
    this.showName,
    this.location,
    this.showStartDate,
    this.imageLink,
    this.isBooked,
    this.dateList,
  });

  OrganizationListItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    showName = json['showName'];
    location = json['location'];
    showStartDate = json['showStartDate'];
    imageLink = json['imageLink'];
    isBooked = json['isBooked'];
    if (json['dateList'] != null) {
      dateList = [];
      json['dateList'].forEach((v) {
        dateList!.add(DateItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['showName'] = this.showName;
    data['location'] = this.location;
    data['showStartDate'] = this.showStartDate;
    data['imageLink'] = this.imageLink;
    data['isBooked'] = this.isBooked;
    if (this.dateList != null) {
      data['dateList'] = this.dateList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DateItem {
  String? showDate;
  String? startTime;
  String? endTime;

  DateItem({this.showDate, this.startTime, this.endTime});

  DateItem.fromJson(Map<String, dynamic> json) {
    showDate = json['showDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['showDate'] = this.showDate;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    return data;
  }
}
