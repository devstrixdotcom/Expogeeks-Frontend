class CategoryDetails {
  final String id;
  final String? categoryName;
  final String imageLink;
  final String bannerLink;
  final String videoLink;

  CategoryDetails({
    required this.id,
    this.categoryName,
    required this.imageLink,
    required this.bannerLink,
    required this.videoLink,
  });

  factory CategoryDetails.fromJson(Map<String, dynamic> json) {
    return CategoryDetails(
      id: json['id']?.toString() ?? '', // Convert to string if it's not already
      categoryName: json['categoryName'],
      imageLink: json['imageLink'] ?? '',
      bannerLink: json['bannerLink'] ?? '',
      videoLink: json['videoLink'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'imageLink': imageLink,
      'bannerLink': bannerLink,
      'videoLink': videoLink,
    };
  }
}
