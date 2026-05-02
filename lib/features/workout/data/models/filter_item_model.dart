class FilterResponseModel {
  final String message;
  final List<FilterItemModel> data;

  FilterResponseModel({required this.message, required this.data});

  factory FilterResponseModel.fromJson(Map<String, dynamic> json) {
    return FilterResponseModel(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<FilterItemModel>.from(json['data'].map((x) => FilterItemModel.fromJson(x)))
          : [],
    );
  }
}

class FilterItemModel {
  final int id;
  final String name;

  FilterItemModel({required this.id, required this.name});

  factory FilterItemModel.fromJson(Map<String, dynamic> json) {
    return FilterItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}