class VisitorFeedbackFromExhibitorModel {
  String? id;
  String? name;
  String? additionalInfo;
  String? callToAction;
  String? interestLevel;
  String? feedback;
  String? feedbackDate;
  String? exhibitionId;
  String? imageLink;
  String? feedbackAudio;
  String? feedbackImage;
  String? feedbackVideo;
  String? visitorId;
  String? email;
  String? countryCode;
  String? mobile;
  String? weddingRole;
  String? address;
  String? estimatedBudget;
  String? destination;
  String? venue;
  String? expectedDate;
  String? qrCode;
  String? userImageLink;
  List<String>? feedbackImageList;

  VisitorFeedbackFromExhibitorModel({
    this.id,
    this.name,
    this.additionalInfo,
    this.callToAction,
    this.interestLevel,
    this.feedback,
    this.feedbackDate,
    this.exhibitionId,
    this.imageLink,
    this.feedbackAudio,
    this.feedbackImage,
    this.feedbackVideo,
    this.visitorId,
    this.email,
    this.countryCode,
    this.mobile,
    this.weddingRole,
    this.address,
    this.estimatedBudget,
    this.destination,
    this.venue,
    this.expectedDate,
    this.qrCode,
    this.userImageLink,
    this.feedbackImageList,
  });

  VisitorFeedbackFromExhibitorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    additionalInfo = json['additional_info'];
    callToAction = json['call_to_action'];
    interestLevel = json['interest_level'];
    feedback = json['feedback'];
    feedbackDate = json['feedbackDate'];
    exhibitionId = json['exhibitionId'];
    imageLink = json['imageLink'];
    feedbackAudio = json['feedbackAudio'];
    feedbackImage = json['feedbackImage'];
    feedbackVideo = json['feedbackVideo'];
    visitorId = json['visitorId'];
    email = json['email'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    weddingRole = json['weddingRole'];
    address = json['address'];
    estimatedBudget = json['estimated_budget'];
    destination = json['destination'];
    venue = json['venue'];
    expectedDate = json['expectedDate'];
    qrCode = json['qrCode'];
    userImageLink = json['userImageLink'];
    feedbackImageList = json['feedbackImageList'] != null
        ? List<String>.from(json['feedbackImageList'].map((item) => item.toString()))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['additional_info'] = this.additionalInfo;
    data['call_to_action'] = this.callToAction;
    data['interest_level'] = this.interestLevel;
    data['feedback'] = this.feedback;
    data['feedbackDate'] = this.feedbackDate;
    data['exhibitionId'] = this.exhibitionId;
    data['imageLink'] = this.imageLink;
    data['feedbackAudio'] = this.feedbackAudio;
    data['feedbackImage'] = this.feedbackImage;
    data['feedbackVideo'] = this.feedbackVideo;
    data['visitorId'] = this.visitorId;
    data['email'] = this.email;
    data['countryCode'] = this.countryCode;
    data['mobile'] = this.mobile;
    data['weddingRole'] = this.weddingRole;
    data['address'] = this.address;
    data['estimated_budget'] = this.estimatedBudget;
    data['destination'] = this.destination;
    data['venue'] = this.venue;
    data['expectedDate'] = this.expectedDate;
    data['qrCode'] = this.qrCode;
    data['userImageLink'] = this.userImageLink;
    data['feedbackImageList'] = feedbackImageList;
    return data;
  }
}
