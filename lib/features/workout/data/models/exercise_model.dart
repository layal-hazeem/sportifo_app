class ExerciseResponseModel {
  final bool success;
  final String message;
  final List<ExerciseModel> data;

  ExerciseResponseModel({required this.success, required this.message, required this.data});

  factory ExerciseResponseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ExerciseModel>.from(json['data'].map((x) => ExerciseModel.fromJson(x)))
          : [],
    );
  }
}

class ExerciseModel {
  final int id;
  final String name;
  final String description;
  final ExerciseCategory? category;
  final List<ExerciseMedia> images;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    this.category,
    required this.images,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] != null ? ExerciseCategory.fromJson(json['category']) : null,
      images: json['images'] != null
          ? List<ExerciseMedia>.from(json['images'].map((x) => ExerciseMedia.fromJson(x)))
          : [],
    );
  }

  // 🔥 دوال مساعدة ذكية (Helpers) لتسهيل جلب الصور في الـ UI
  String? get gifUrl {
    try {
      return images.firstWhere((media) => media.type == 'gif').url;
    } catch (e) {
      return null;
    }
  }

  List<String> get pictureUrls {
    return images.where((media) => media.type == 'pictures').map((e) => e.url).toList();
  }
}

class ExerciseCategory {
  final int id;
  final String name;
  final ExerciseOrgan? organ;

  ExerciseCategory({required this.id, required this.name, this.organ});

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      organ: json['organ'] != null ? ExerciseOrgan.fromJson(json['organ']) : null,
    );
  }
}

class ExerciseOrgan {
  final int id;
  final String name;
  final ExercisePart? part;

  ExerciseOrgan({required this.id, required this.name, this.part});

  factory ExerciseOrgan.fromJson(Map<String, dynamic> json) {
    return ExerciseOrgan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      part: json['part'] != null ? ExercisePart.fromJson(json['part']) : null,
    );
  }
}

class ExercisePart {
  final int id;
  final String name;

  ExercisePart({required this.id, required this.name});

  factory ExercisePart.fromJson(Map<String, dynamic> json) {
    return ExercisePart(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ExerciseMedia {
  final String url;
  final String type;

  ExerciseMedia({required this.url, required this.type});

  factory ExerciseMedia.fromJson(Map<String, dynamic> json) {
    return ExerciseMedia(
      url: json['url'] ?? '',
      type: json['type'] ?? '',
    );
  }
}