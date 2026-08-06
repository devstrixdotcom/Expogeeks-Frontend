class CategoryShowListModel {
  String? id;
  String? name;
  String? description;
  String? showDate;
  String? fromDate;
  String? toDate;
  String? imageLink;
  String? isBooked;
  String? bookingRequired;
  int? seatsLeft;

  CategoryShowListModel({
    this.id,
    this.name,
    this.description,
    this.showDate,
    this.fromDate,
    this.toDate,
    this.imageLink,
    this.isBooked,
    this.bookingRequired,
    this.seatsLeft,
  });

  CategoryShowListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    showDate = json['showDate'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    imageLink = json['imageLink'];
    isBooked = json['isBooked'];
    bookingRequired = json['booking_required'];
    seatsLeft = json['seatsLeft'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['showDate'] = this.showDate;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['imageLink'] = this.imageLink;
    data['isBooked'] = this.isBooked;
    data['booking_required'] = this.bookingRequired;
    data['seatsLeft'] = this.seatsLeft;
    return data;
  }
}
