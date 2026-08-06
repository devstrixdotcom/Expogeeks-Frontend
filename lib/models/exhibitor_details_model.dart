// class ExhibitorDetailsModel {
//   String? id;
//   String? name;
//   String? mobile;
//   String? website;
//   String? email;
//   String? whatsapp_no;
//   String? instagram_link;
//   String? stallNo;
//   // String? price;
//   String? description;
//   String? category;
//   String? imageLink;
//   String? videoLink;
//   String? pdfLink;
//   String? isFavourite;
//   String? isBooked;
//   String? isMeetingRequested;
//   String? meetingDate;
//   String? meetingTime;
//   String? meetingStatus;
//   String? circularImageLink;
//   List<String>? notBookedDates;
//   List<String>? bookedDates;

//   ExhibitorDetailsModel({
//     this.id,
//     this.name,
//     this.mobile,
//     this.website,
//     this.email,
//     this.whatsapp_no,
//     this.instagram_link,
//     this.stallNo,
//     // this.price,
//     this.description,
//     this.category,
//     this.imageLink,
//     this.videoLink,
//     this.pdfLink,
//     this.isFavourite,
//     this.isBooked,
//     this.isMeetingRequested,
//     this.meetingDate,
//     this.meetingTime,
//     this.meetingStatus,
//     this.circularImageLink,
//     this.notBookedDates,
//     this.bookedDates,
//   });

//   ExhibitorDetailsModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     mobile = json['mobile'];
//     website = json['website'];
//     email = json['email'];
//     whatsapp_no = json['whatsapp_no'];
//     instagram_link = json['instagram_link'];
//     stallNo = json['stall_no'];
//     // price = json['price'];
//     description = json['description'];
//     category = json['category'];
//     imageLink = json['imageLink'];
//     videoLink = json['videoLink'];
//     pdfLink = json['pdfLink'];
//     isFavourite = json['isFavourite'].toString();
//     isBooked = json['isBooked'].toString();
//     isMeetingRequested = json['isMeetingRequested'].toString();
//     meetingDate = json['meetingDate'];
//     meetingTime = json['meetingTime'];
//     meetingStatus = json['meetingStatus'];
//     circularImageLink = json['iconLink'];
//     // Debug log to check the value of notBookedDates
//     print('notBookedDates from JSON: ${json['notBookedDates']}');
//     notBookedDates = List<String>.from(json['notBookedDates'] ?? []);
//     bookedDates = List<String>.from(json['bookedDates'] ?? []);

//     // Debug log to check the parsed notBookedDates
//     print('Parsed notBookedDates: $notBookedDates');
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['mobile'] = this.mobile;
//     data['website'] = this.website;
//     data['email'] = this.email;
//     data['whatsapp_no'] = this.whatsapp_no;
//     data['instagram_link'] = this.instagram_link;
//     data['stall_no'] = this.stallNo;
//     // data['price'] = this.price;
//     data['description'] = this.description;
//     data['category'] = this.category;
//     data['imageLink'] = this.imageLink;
//     data['videoLink'] = this.videoLink;
//     data['pdfLink'] = this.pdfLink;
//     data['isFavourite'] = this.isFavourite;
//     data['isBooked'] = this.isBooked;
//     data['isMeetingRequested'] = this.isMeetingRequested;
//     data['meetingDate'] = this.meetingDate;
//     data['meetingTime'] = this.meetingTime;
//     data['meetingStatus'] = this.meetingStatus;
//     data['iconLink'] = this.circularImageLink;
//     data['notBookedDates'] = this.notBookedDates;
//     data['bookedDates'] = this.bookedDates;
//     return data;
//   }
// }

class Meeting {
  String? meetingDate;
  String? meetingTime;
  String? meetingStatus;

  Meeting({this.meetingDate, this.meetingTime, this.meetingStatus});

  Meeting.fromJson(Map<String, dynamic> json) {
    meetingDate = json['meetingDate'];
    meetingTime = json['meetingTime'];
    meetingStatus = json['meetingStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['meetingDate'] = this.meetingDate;
    data['meetingTime'] = this.meetingTime;
    data['meetingStatus'] = this.meetingStatus;
    return data;
  }
}

class ExhibitorDetailsModel {
  String? id;
  String? name;
  String? country_code;
  String? mobile;
  String? website;
  String? email;
  String? whatsapp_no;
  String? instagram_link;
  String? stallNo;
  String? description;
  String? category;
  String? imageLink;
  String? videoLink;
  String? pdfLink;
  String? isFavourite;
  String? isBooked;
  String? isMeetingRequested;
  String? meetingDate;
  String? meetingTime;
  String? meetingStatus;
  String? circularImageLink;
  List<String>? notBookedDates;
  List<String>? bookedDates;
  List<Meeting>? meetingList;

  ExhibitorDetailsModel({
    this.id,
    this.name,
    this.country_code,
    this.mobile,
    this.website,
    this.email,
    this.whatsapp_no,
    this.instagram_link,
    this.stallNo,
    this.description,
    this.category,
    this.imageLink,
    this.videoLink,
    this.pdfLink,
    this.isFavourite,
    this.isBooked,
    this.isMeetingRequested,
    this.meetingDate,
    this.meetingTime,
    this.meetingStatus,
    this.circularImageLink,
    this.notBookedDates,
    this.bookedDates,
    this.meetingList,
  });

  ExhibitorDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    country_code = json['country_code'];
    mobile = json['mobile'];
    website = json['website'];
    email = json['email'];
    whatsapp_no = json['whatsapp_no'];
    instagram_link = json['instagram_link'];
    stallNo = json['stall_no'];
    description = json['description'];
    category = json['category'];
    imageLink = json['imageLink'];
    videoLink = json['videoLink'];
    pdfLink = json['pdfLink'];
    isFavourite = json['isFavourite'].toString();
    isBooked = json['isBooked'].toString();
    isMeetingRequested = json['isMeetingRequested'].toString();
    meetingDate = json['meetingDate'];
    meetingTime = json['meetingTime'];
    meetingStatus = json['meetingStatus'];
    circularImageLink = json['iconLink'];
    notBookedDates = List<String>.from(json['notBookedDates'] ?? []);
    bookedDates = List<String>.from(json['bookedDates'] ?? []);
    meetingList = (json['meetingList'] as List?)
        ?.map((meeting) => Meeting.fromJson(meeting))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['country_code'] = this.country_code;
    data['mobile'] = this.mobile;
    data['website'] = this.website;
    data['email'] = this.email;
    data['whatsapp_no'] = this.whatsapp_no;
    data['instagram_link'] = this.instagram_link;
    data['stall_no'] = this.stallNo;
    data['description'] = this.description;
    data['category'] = this.category;
    data['imageLink'] = this.imageLink;
    data['videoLink'] = this.videoLink;
    data['pdfLink'] = this.pdfLink;
    data['isFavourite'] = this.isFavourite;
    data['isBooked'] = this.isBooked;
    data['isMeetingRequested'] = this.isMeetingRequested;
    data['meetingDate'] = this.meetingDate;
    data['meetingTime'] = this.meetingTime;
    data['meetingStatus'] = this.meetingStatus;
    data['iconLink'] = this.circularImageLink;
    data['notBookedDates'] = this.notBookedDates;
    data['bookedDates'] = this.bookedDates;
    data['meetingList'] =
        this.meetingList?.map((meeting) => meeting.toJson()).toList();
    return data;
  }
}
