class OrganizerCategoryListModel {
  String? id;
  String? categoryName;
  String? imageLink;
  String? videoLink;
  String? bannerLink;

  OrganizerCategoryListModel({
    this.id,
    this.categoryName,
    this.imageLink,
    this.videoLink,
     this.bannerLink,
 });

  OrganizerCategoryListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryName'];
    imageLink = json['imageLink'];
    videoLink = json['videoLink'];
    bannerLink = json['bannerLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categoryName'] = this.categoryName;
    data['imageLink'] = this.imageLink;
    data['videoLink'] = this.videoLink;
    data['bannerLink'] = this.bannerLink;
    return data;
  }
}
