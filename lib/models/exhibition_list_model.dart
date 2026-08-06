// lib\models\exhibition_model.dart
class ExhibitionModel {
  String? id;
  String? exhibitionName;

  ExhibitionModel({this.id, this.exhibitionName});

  ExhibitionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    exhibitionName = json['exhibitionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['exhibitionName'] = this.exhibitionName;
    return data;
  }
}