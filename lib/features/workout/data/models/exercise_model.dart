class ExerciseResponseModel {
  final bool success;
  final String message;
  final List<ExerciseModel> data;

  ExerciseResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExerciseResponseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ExerciseModel>.from(
              json['data'].map((x) => ExerciseModel.fromJson(x)),
            )
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
  bool isSaved;
  int? sets;
  String? reps;
  String? duration;
  int? order;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    this.category,
    required this.images,
    this.isSaved = false,

    this.sets,
    this.reps,
    this.duration,
    this.order,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] != null
          ? ExerciseCategory.fromJson(json['category'])
          : null,
      images: json['images'] != null
          ? List<ExerciseMedia>.from(
              json['images'].map((x) => ExerciseMedia.fromJson(x)),
            )
          : [],
      // يدعم السيرفر الحقيقي سواء رجع 0/1 أو true/false
      isSaved: json['is_saved'] == 1 || json['is_saved'] == true,
      sets: json['sets'],
      reps: json['reps']?.toString(),
      duration: json['duration'],
      order: json['order'],
    );
  }

  // أضف هذه الدالة داخل كلاس ExerciseModel
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category != null
          ? {
              'id': category!.id,
              'name': category!.name,
              'organ': category!.organ != null
                  ? {
                      'id': category!.organ!.id,
                      'name': category!.organ!.name,
                      'part': category!.organ!.part != null
                          ? {
                              'id': category!.organ!.part!.id,
                              'name': category!.organ!.part!.name,
                            }
                          : null,
                    }
                  : null,
            }
          : null,
      'images': images.map((x) => {'url': x.url, 'type': x.type}).toList(),
      'is_saved': isSaved ? 1 : 0,
    };
  }

  // 🔥 جلب رابط الـ GIF لعرضه مباشرة في الـ UI
  String? get gifUrl {
    try {
      // نبحث عن أول عنصر نوعه gif ونعيد الرابط تبعه
      return images.firstWhere((media) => media.type == 'gif').url;
    } catch (e) {
      return null; // إذا التمرين ما فيه GIF
    }
  }

  // 🔥 جلب قائمة روابط الصور (بدون الـ GIF) لعرضها في Slider
  List<String> get pictureUrls {
    return images
        .where((media) => media.type == 'pictures')
        .map((e) => e.url)
        .toList();
  }

  bool get isCardio {
    return category?.id == 2;
  }

  bool get isResistance {
    return category?.id == 1;
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
      organ: json['organ'] != null
          ? ExerciseOrgan.fromJson(json['organ'])
          : null,
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
    return ExercisePart(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class ExerciseMedia {
  final String url;
  final String type;

  ExerciseMedia({required this.url, required this.type});

  factory ExerciseMedia.fromJson(Map<String, dynamic> json) {
    // على السيرفر الحقيقي الروابط عم ترجع كاملة https
    // لهيك ما عاد في داعي لعمليات الـ replace للـ localhost
    return ExerciseMedia(url: json['url'] ?? '', type: json['type'] ?? '');
  }
}
