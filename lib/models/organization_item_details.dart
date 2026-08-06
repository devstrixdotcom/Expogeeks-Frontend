class OrganizationItemsDetails {
  String? id;
  String? showName;
  String? location;
  String? description;
  String? showStartDate;
  String? imageLink;
  String? videoLink;
  List<String>? imageList;
  List<DateItem>? dateList;
  List<CategoryItem>? categoryList;
  String? isBooked;
  String? redirectLink;

  OrganizationItemsDetails({
    this.id,
    this.showName,
    this.location,
    this.description,
    this.showStartDate,
    this.imageLink,
    this.videoLink,
    this.imageList,
    this.dateList,
    this.categoryList,
    this.isBooked,
    this.redirectLink,
  });

  OrganizationItemsDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    showName = json['showName'];
    location = json['location'];
    description = json['description'];
    showStartDate = json['showStartDate'];
    imageLink = json['imageLink'];
    videoLink = json['videoLink'];
    if (json['imageList'] != null) {
      imageList = [];
      json['imageList'].forEach((v) {
        imageList!.add(v['imageLink']); // Extract the imageLink from each item
      });
    }
    if (json['dateList'] != null) {
      dateList = [];
      json['dateList'].forEach((v) {
        dateList!.add(DateItem.fromJson(v));
      });
    }
    if (json['categoryList'] != null) {
      categoryList = [];
      json['categoryList'].forEach((v) {
        categoryList!.add(CategoryItem.fromJson(v));
      });
    }
    isBooked = json['isBooked'];
    redirectLink = json['redirectLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['showName'] = this.showName;
    data['location'] = this.location;
    data['description'] = this.description;
    data['showStartDate'] = this.showStartDate;
    data['imageLink'] = this.imageLink;
    data['videoLink'] = this.videoLink;
    if (this.imageList != null) {
      data['imageList'] = this.imageList!.map((v) => {'imageLink': v}).toList();
    }
    if (this.dateList != null) {
      data['dateList'] = this.dateList!.map((v) => v.toJson()).toList();
    }
    if (this.categoryList != null) {
      data['categoryList'] = this.categoryList!.map((v) => v.toJson()).toList();
    }
    data['isBooked'] = this.isBooked;
    data['redirectLink'] = this.redirectLink;

    return data;
  }
}

class DateItem {
  String? showDate;
  String? startTime;
  String? endTime;
  String? redirectLink;

  DateItem({this.showDate, this.startTime, this.endTime, this.redirectLink});

  DateItem.fromJson(Map<String, dynamic> json) {
    showDate = json['showDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    redirectLink = json['redirectLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['showDate'] = this.showDate;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['redirectLink'] = this.redirectLink;
    return data;
  }
}

class CategoryItem {
  String? id;
  String? categoryName;
  String? imageLink;

  CategoryItem({this.id, this.categoryName, this.imageLink});

  CategoryItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryName'];
    imageLink = json['imageLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categoryName'] = this.categoryName;
    data['imageLink'] = this.imageLink;
    return data;
  }
}
