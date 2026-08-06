class ScannedCategoryListModel {
  String? id;
  String? categoryName;
  String? imageLink;
  String? videoLink;

  ScannedCategoryListModel({
    this.id,
    this.categoryName,
    this.imageLink,
    this.videoLink,
  });

  ScannedCategoryListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryName'];
    imageLink = json['imageLink'];
    videoLink = json['videoLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categoryName'] = this.categoryName;
    data['imageLink'] = this.imageLink;
    data['videoLink'] = this.videoLink;
    return data;
  }
}
