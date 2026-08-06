class OfferModels {
  String? id;
  String? description;
  String? validity;
  String? imageLink;

  OfferModels({
    this.id,
    this.description,
    this.validity,
    this.imageLink,
  });

  OfferModels.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    validity = json['validity'];
    imageLink = json['imageLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['validity'] = this.validity;
    data['imageLink'] = this.imageLink;
    return data;
  }
}
