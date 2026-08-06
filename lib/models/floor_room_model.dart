class FloorPlanModel {
  String? id;
  String? floorName;
  String? imageLink;

  FloorPlanModel({
    this.id,
    this.floorName,
    this.imageLink,
  });

  FloorPlanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    floorName = json['floorName'];
    imageLink = json['imageLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['floorName'] = this.floorName;
    data['imageLink'] = this.imageLink;
    return data;
  }
}
