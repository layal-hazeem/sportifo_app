class AdModel {
  final int id;
  final String name;
  final String details;
  final String companyName;
  final String type;
  final String url;
  final double? price;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> images;

  AdModel({
    required this.id,
    required this.name,
    required this.details,
    required this.companyName,
    required this.type,
    required this.url,
    this.price,
    this.startDate,
    this.endDate,
    required this.images,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as int,
      name: json['name'] as String,
      details: json['details'] as String,
      companyName: json['company_name'] as String,
      type: (json['type'] as String).toLowerCase(),
      url: json['url'] as String,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }


}

class AdsResponseModel {
  final String message;
  final List<AdModel> data;

  AdsResponseModel({required this.message, required this.data});

  factory AdsResponseModel.fromJson(Map<String, dynamic> json) {
    return AdsResponseModel(
      message: json['message'] as String,
      data: (json['data'] as List).map((e) => AdModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}