class CategoryExhibitorListModel {
  String? id;
  String? exhibitorId;
  String? name;
  String? imageLink;
  String? countryCode;
  String? mobile;
  String? email;
  String? instagramLink;
  String? circularImageLink;
  String? exhibitionName;

  CategoryExhibitorListModel({
    this.id,
    this.exhibitorId,
    this.name,
    this.imageLink,
    this.countryCode,
    this.mobile,
    this.email,
    this.instagramLink,
    this.circularImageLink,
    this.exhibitionName,
  });

  CategoryExhibitorListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json.containsKey('exhibitorId')) {
      exhibitorId = json['exhibitorId'];
    }
    name = json['name'];
    imageLink = json['imageLink'];
    if (json.containsKey('countryCode')) {
      countryCode = json['countryCode'];
    }
    if (json.containsKey('mobile')) {
      mobile = json['mobile'];
    }
    if (json.containsKey('email')) {
      email = json['email'];
    }
    if (json.containsKey('instagram_link')) {
      instagramLink = json['instagram_link'];
    }
    if (json.containsKey('iconLink')) {
      circularImageLink = json['iconLink'];
    }
    if (json.containsKey('exhibitionName')) {
      exhibitionName = json['exhibitionName'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (data.containsKey('exhibitorId')) {
      data['exhibitorId'] = this.exhibitorId;
    }
    data['name'] = this.name;
    data['imageLink'] = this.imageLink;
    if (data.containsKey('countryCode')) {
      data['countryCode'] = this.countryCode;
    }
    if (data.containsKey('mobile')) {
      data['mobile'] = this.mobile;
    }
    if (data.containsKey('email')) {
      data['email'] = this.email;
    }
    if (data.containsKey('instagram_link')) {
      data['instagram_link'] = this.instagramLink;
    }
    if (data.containsKey('iconLink')) {
      data['iconLink'] = this.circularImageLink;
    }
    if (data.containsKey('exhibitionName')) {
      data['exhibitionName'] = this.exhibitionName;
    }
    return data;
  }
}
