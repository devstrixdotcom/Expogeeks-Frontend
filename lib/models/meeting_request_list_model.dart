class MeetingRequestListModel {
  String? id;
  String? visitorName;
  String? teamName;
  String? status;
  String? message;
  String? meetingDate;
  String? meetingTime;
  String? email;
  String? mobile;
  String? weddingRole;
  String? address;
  String? estimatedBudget;
  String? destination;
  String? venue;
  String? expectedDate;
  String? imageLink;
  String? replyMessage;

  MeetingRequestListModel({
    this.id,
    this.visitorName,
    this.teamName,
    this.status,
    this.message,
    this.meetingDate,
    this.meetingTime,
    this.email,
    this.mobile,
    this.weddingRole,
    this.address,
    this.estimatedBudget,
    this.destination,
    this.venue,
    this.expectedDate,
    this.imageLink,
    this.replyMessage,
  });

  MeetingRequestListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitorName = json['visitorName'];
    teamName = json['teamName'];
    status = json['status'];
    message = json['message'];
    meetingDate = json['meetingDate'];
    meetingTime = json['meetingTime'];
    email = json['email'];
    mobile = json['mobile'];
    weddingRole = json['weddingRole'];
    address = json['address'];
    estimatedBudget = json['estimated_budget'];
    destination = json['destination'];
    venue = json['venue'];
    expectedDate = json['expectedDate'];
    imageLink = json['imageLink'];
    replyMessage = json['reply_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['visitorName'] = this.visitorName;
    data['teamName'] = this.teamName;
    data['status'] = this.status;
    data['message'] = this.message;
    data['meetingDate'] = this.meetingDate;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['weddingRole'] = this.weddingRole;
    data['address'] = this.address;
    data['estimated_budget'] = this.estimatedBudget;
    data['destination'] = this.destination;
    data['venue'] = this.venue;
    data['expectedDate'] = this.expectedDate;
    data['imageLink'] = this.imageLink;
    data['reply_message'] = this.replyMessage;
    return data;
  }
}
