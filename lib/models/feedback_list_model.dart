class FeedbackListModel {
  String? id;
  String? name;
  String? additional_info;
  String? call_to_action;
  String? interest_level;
  String? feedback;
  String? feedbackDate;
  String? imageLink;
  String? feedbackAudio;
  String? feedbackImage;
  String? feedbackVideo;
  String? email;
  String? mobile;
  String? weddingRole;
  String? address;
  String? estimated_budget;
  String? destination;
  String? venue;
  String? expectedDate;
  String? qrCode;

  FeedbackListModel({
    this.id,
    this.name,
    this.additional_info,
    this.call_to_action,
    this.interest_level,
    this.feedback,
    this.feedbackDate,
    this.imageLink,
    this.feedbackAudio,
    this.feedbackImage,
    this.feedbackVideo,
    this.email,
    this.mobile,
    this.weddingRole,
    this.address,
    this.estimated_budget,
    this.destination,
    this.venue,
    this.expectedDate,
    this.qrCode,
  });

  FeedbackListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    additional_info = json['additional_info'];
    call_to_action = json['call_to_action'];
    interest_level = json['interest_level'];
    feedback = json['feedback'];
    feedbackDate = json['feedbackDate'];
    imageLink = json['imageLink'];
    feedbackAudio = json['feedbackAudio'];
    feedbackImage = json['feedbackImage'];
    feedbackVideo = json['feedbackVideo'];
    email = json['email'];
    mobile = json['mobile'];
    weddingRole = json['weddingRole'];
    address = json['address'];
    estimated_budget = json['estimated_budget'];
    destination = json['destination'];
    venue = json['venue'];
    expectedDate = json['expectedDate'];
    qrCode = json['qrCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['additional_info'] = this.additional_info;
    data['call_to_action'] = this.call_to_action;
    data['interest_level'] = this.interest_level;
    data['feedback'] = this.feedback;
    data['feedbackDate'] = this.feedbackDate;
    data['imageLink'] = this.imageLink;
    data['feedbackAudio'] = this.feedbackAudio;
    data['feedbackImage'] = this.feedbackImage;
    data['feedbackVideo'] = this.feedbackVideo;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['weddingRole'] = this.weddingRole;
    data['address'] = this.address;
    data['estimated_budget'] = this.estimated_budget;
    data['destination'] = this.destination;
    data['venue'] = this.venue;
    data['expectedDate'] = this.expectedDate;
    data['qrCode'] = this.qrCode;

    return data;
  }
}
