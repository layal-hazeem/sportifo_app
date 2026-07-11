
class ProfileDisplayModel {
  final String id;
  final String name;
  final String imageUrl;
  final String role;

  final String? description;
  final int? yearsOfExp;
  final List<String> gallery;

  ProfileDisplayModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.role,
    this.description,
    this.yearsOfExp,
    this.gallery = const [],
  });


}