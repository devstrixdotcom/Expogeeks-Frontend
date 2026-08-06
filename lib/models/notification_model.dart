class NotificationModel {
  String? id;
  String? title;
  String? message;
  String? createdDate;
  String? imageLink;

  NotificationModel({
    this.id,
    this.title,
    this.message,
    this.createdDate,
    this.imageLink,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    createdDate = json['createdDate'];
    imageLink = json['imageLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['message'] = this.message;
    data['createdDate'] = this.createdDate;
    data['imageLink'] = this.imageLink;
    return data;
  }
}
