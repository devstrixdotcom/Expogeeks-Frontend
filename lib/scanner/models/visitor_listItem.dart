class VisitorListItem {
  final String id;
  final String visitorId;
  final String name;
  final String email;
  final String countryCode;
  final String mobile;
  final String qrCode;
  final String imageLink;

  VisitorListItem({
    required this.id,
    required this.visitorId,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.mobile,
    required this.qrCode,
    required this.imageLink,
  });

  factory VisitorListItem.fromJson(Map<String, dynamic> json) {
    return VisitorListItem(
      id: json['id'],
      visitorId: json['visitorId'],
      name: json['name'],
      email: json['email'],
      countryCode: json['countryCode'],
      mobile: json['mobile'],
      qrCode: json['qrCode'],
      imageLink: json['imageLink'],
    );
  }
}
