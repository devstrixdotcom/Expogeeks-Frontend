class ExhibitorListModel {
  String? id;
  String? name;
  String? categoryId;
  String? category;
  String? imageLink;
  String? isFavourite;
  String? stallNo;

  ExhibitorListModel({
    this.id,
    this.name,
    this.categoryId,
    this.category,
    this.imageLink,
    this.isFavourite,
    this.stallNo,
  });

  ExhibitorListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    categoryId = json['category_id'];
    category = json['category'];
    imageLink = json['imageLink'];
    isFavourite = json['isFavourite'].toString();
    stallNo = json['stall_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['category_id'] = this.categoryId;
    data['category'] = this.category;
    data['imageLink'] = this.imageLink;
    data['isFavourite'] = this.isFavourite;
    data['stall_no'] = this.stallNo;
    return data;
  }
}
