import 'exhibitor_details_model.dart';

class FavCategoryListModel {
  String? id;
  String? categoryName;
  String? imageLink;
  String? videoLink;
  List<ExhibitorDetailsModel>? exhibitors;

  FavCategoryListModel({
    this.id,
    this.categoryName,
    this.imageLink,
    this.videoLink,
    this.exhibitors,
  });

  FavCategoryListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryName'];
    imageLink = json['imageLink'];
    videoLink = json['videoLink'];
    if (json['exhibitors'] != null) {
      exhibitors = (json['exhibitors'] as List<dynamic>)
          .map((e) => ExhibitorDetailsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      exhibitors = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categoryName'] = this.categoryName;
    data['imageLink'] = this.imageLink;
    data['videoLink'] = this.videoLink;
    if (exhibitors != null) {
      data['exhibitors'] = exhibitors!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
