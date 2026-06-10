class CoachImageModel {
  final int id;
  final String type;
  final String name;
  final String url;

  CoachImageModel({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
  });

  factory CoachImageModel.fromJson(Map<String, dynamic> json) {
    return CoachImageModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
    );
  }
}