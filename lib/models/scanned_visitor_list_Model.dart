class ScannedVisitorListModel {
  String? id;
  String? visitorId;
  String? name;
  String? budget;
  String? weddingRole;
  String? email;
  String? countryCode;
  String? mobile;
  String? qrCode;
  String? created;
  String? weddingDate;
  String? imageLink;
  String? interestLevel;
  String? message;
  String? exhibitionId;

  ScannedVisitorListModel({
    this.id,
    this.visitorId,
    this.name,
    this.budget,
    this.weddingRole,
    this.email,
    this.countryCode,
    this.mobile,
    this.qrCode,
    this.created,
    this.weddingDate,
    this.imageLink,
    this.interestLevel,
    this.message,
    this.exhibitionId,  
  });

  ScannedVisitorListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitorId = json['visitorId'];
    name = json['name'];
    budget = json['budget'];
    weddingRole = json['weddingRole'];
    email = json['email'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    qrCode = json['qrCode'];
    created = json['created'];
    weddingDate = json['weddingDate'];
    imageLink = json['imageLink'];
    interestLevel = json['interestLevel'];
    message = json['message'];
    exhibitionId = json['exhibitionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['budget'] = this.budget;
    data['weddingRole'] = this.weddingRole;
    data['email'] = this.email;
    data['countryCode'] = this.countryCode;
    data['mobile'] = this.mobile;
    data['qrCode'] = this.qrCode;
    data['created'] = this.created;
    data['weddingDate'] = this.weddingDate;
    data['imageLink'] = this.imageLink;
    data['interestLevel'] = this.interestLevel;
    data['message'] = this.message;
    data['exhibitionId'] = this.exhibitionId;
    return data;
  }
}
