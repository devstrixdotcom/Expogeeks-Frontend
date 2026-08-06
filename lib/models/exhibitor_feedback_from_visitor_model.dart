class ExhibitorFeedbackFromVisitorModel {
  String? id;
  // String? name;
  String? additionalInfo;
  String? callToAction;
  String? interestLevel;
  String? feedback;
  String? feedbackDate;

  String? exhibitorId;
  String? exhibitorName;
  String? exhibitorCountryCode;
  String? exhibitorMobile;
  // String? exhibitorWebsite;
  String? exhibitorEmail;
  // String? exhibitorWhatsappNo;
  String? exhibitorInstagramLink;
  // String? exhibitorStallNo;
  // String? exhibitorDescription;
  String? exhibitorCategory;
  String? iconLink;
  String? imageLink;
  String? feedbackAudio;
  String? feedbackImage;
  String? feedbackVideo;
  List<String>? feedbackImageList;
  // String? email;
  // String? mobile;
  // String? weddingRole;
  // String? address;
  // String? estimatedBudget;
  // String? destination;
  // String? venue;
  // String? expectedDate;
  // String? qrCode;
  // String? userImageLink;
  String? teamName;
  String? teamMobile;
  String? teamPic;
  String? teamCountryCode;
  String? teamEmail;
  String? exhibitionName;

  ExhibitorFeedbackFromVisitorModel({
    this.id,
    // this.name,
    this.additionalInfo,
    this.callToAction,
    this.interestLevel,
    this.feedback,
    this.feedbackDate,
    this.exhibitorId,
    this.exhibitorName,
    this.exhibitorCountryCode,
    this.exhibitorMobile,
    // this.exhibitorWebsite,
    this.exhibitorEmail,
    // this.exhibitorWhatsappNo,
    this.exhibitorInstagramLink,
    // this.exhibitorStallNo,
    // this.exhibitorDescription,
    this.exhibitorCategory,
    this.iconLink,
    this.imageLink,
    this.feedbackAudio,
    this.feedbackImage,
    this.feedbackVideo,
    this.feedbackImageList,
    // this.email,
    // this.mobile,
    // this.weddingRole,
    // this.address,
    // this.estimatedBudget,
    // this.destination,
    // this.venue,
    // this.expectedDate,
    // this.qrCode,
    // this.userImageLink,
    this.teamName,
    this.teamMobile,
    this.teamPic,
    this.teamCountryCode,
    this.teamEmail,
    this.exhibitionName,
  });

  ExhibitorFeedbackFromVisitorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // name = json['name'];
    additionalInfo = json['additional_info'];
    callToAction = json['call_to_action'];
    interestLevel = json['interest_level'];
    feedback = json['feedback'];
    feedbackDate = json['feedbackDate'];

    exhibitorId = json['exhibitorId'];
    exhibitorName = json['exhibitorName'];
    exhibitorCountryCode = json['exhibitorCountryCode'];
    exhibitorMobile = json['exhibitorMobile'];
    // exhibitorWebsite = json['exhibitorWebsite'];
    exhibitorEmail = json['exhibitorEmail'];
    // exhibitorWhatsappNo = json['exhibitor_whatsapp_no'];
    exhibitorInstagramLink = json['exhibitor_instagram_link'];
    // exhibitorStallNo = json['exhibitor_stall_no'];
    // exhibitorDescription = json['exhibitor_description'];
    exhibitorCategory = json['exhibitor_category'];
    iconLink = json['iconLink'];
    imageLink = json['imageLink'];
    feedbackAudio = json['feedbackAudio'];
    feedbackImage = json['feedbackImage'];
    feedbackVideo = json['feedbackVideo'];
    feedbackImageList = json['feedbackImageList'] != null
    ? List<String>.from(json['feedbackImageList'].map((item) => item.toString()))
    : null;
    // email = json['email'];
    // mobile = json['mobile'];
    // weddingRole = json['weddingRole'];
    // address = json['address'];
    // estimatedBudget = json['estimated_budget'];
    // destination = json['destination'];
    // venue = json['venue'];
    // expectedDate = json['expectedDate'];
    // qrCode = json['qrCode'];
    // userImageLink = json['userImageLink'];
    teamName = json['teamName'];
    teamMobile = json['teamMobile'];
    teamPic = json['teamPic'];
    teamCountryCode = json['teamCountryCode'];
    teamEmail = json['teamEmail'];
    exhibitionName = json['exhibitionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    // data['name'] = this.name;
    data['additional_info'] = this.additionalInfo;
    data['call_to_action'] = this.callToAction;
    data['interest_level'] = this.interestLevel;
    data['feedback'] = this.feedback;
    data['feedbackDate'] = this.feedbackDate;
    data['exhibitorId'] = this.exhibitorId;
    data['exhibitorName'] = this.exhibitorName;
    data['exhibitorCountryCode'] = this.exhibitorCountryCode;
    data['exhibitorMobile'] = this.exhibitorMobile;
    // data['exhibitorWebsite'] = this.exhibitorWebsite;
    data['exhibitorEmail'] = this.exhibitorEmail;
    // data['exhibitor_whatsapp_no'] = this.exhibitorWhatsappNo;
    data['exhibitor_instagram_link'] = this.exhibitorInstagramLink;
    // data['exhibitor_stall_no'] = this.exhibitorStallNo;
    // data['exhibitor_description'] = this.exhibitorDescription;
    data['exhibitor_category'] = this.exhibitorCategory;
    data['iconLink'] = this.iconLink;
    data['imageLink'] = this.imageLink;
    data['feedbackAudio'] = this.feedbackAudio;
    data['feedbackImage'] = this.feedbackImage;
    data['feedbackVideo'] = this.feedbackVideo;
    data['feedbackImageList'] = this.feedbackImageList;
    // data['email'] = this.email;
    // data['mobile'] = this.mobile;
    // data['weddingRole'] = this.weddingRole;
    // data['address'] = this.address;
    // data['estimated_budget'] = this.estimatedBudget;
    // data['destination'] = this.destination;
    // data['venue'] = this.venue;
    // data['expectedDate'] = this.expectedDate;
    // data['qrCode'] = this.qrCode;
    // data['userImageLink'] = this.userImageLink;
    data['teamName'] = this.teamName;
    data['teamMobile'] = this.teamMobile;
    data['teamPic'] = this.teamPic;
    data['teamCountryCode'] = this.teamCountryCode;
    data['teamEmail'] = this.teamEmail;
    data['exhibitionName'] = this.exhibitionName;
    return data;
  }
}
