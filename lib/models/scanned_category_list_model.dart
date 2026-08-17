class ScannedCategoryListModel {
  String? id;
  String? categoryName;
  String? imageLink;
  String? videoLink;

  /// Show this category belongs to, used to build the shared ticket link.
  String? exhibitionId;
  String? exhibitionName;

  ScannedCategoryListModel({
    this.id,
    this.categoryName,
    this.imageLink,
    this.videoLink,
    this.exhibitionId,
    this.exhibitionName,
  });

  ScannedCategoryListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryName'];
    imageLink = json['imageLink'];
    videoLink = json['videoLink'];
    exhibitionId = json['exhibitionId']?.toString();
    exhibitionName = json['exhibitionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categoryName'] = this.categoryName;
    data['imageLink'] = this.imageLink;
    data['videoLink'] = this.videoLink;
    data['exhibitionId'] = this.exhibitionId;
    data['exhibitionName'] = this.exhibitionName;
    return data;
  }
}
