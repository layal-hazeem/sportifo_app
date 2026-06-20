// To parse this JSON data, do
//
//     final existingDaysModel = existingDaysModelFromJson(jsonString);

import 'dart:convert';

ExistingDaysModel existingDaysModelFromJson(String str) => ExistingDaysModel.fromJson(json.decode(str));

String existingDaysModelToJson(ExistingDaysModel data) => json.encode(data.toJson());

class ExistingDaysModel {
    final int? id;
    final String? name;
    final List<Exercise>? exercises;

    ExistingDaysModel({
        this.id,
        this.name,
        this.exercises,
    });

    factory ExistingDaysModel.fromJson(Map<String, dynamic> json) => ExistingDaysModel(
        id: json["id"],
        name: json["name"],
        exercises: json["exercises"] == null ? [] : List<Exercise>.from(json["exercises"]!.map((x) => Exercise.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "exercises": exercises == null ? [] : List<dynamic>.from(exercises!.map((x) => x.toJson())),
    };
}

class Exercise {
    final int? id;
    final String? name;
    final String? description;
    final Category? category;
    final List<Image>? images;

    Exercise({
        this.id,
        this.name,
        this.description,
        this.category,
        this.images,
    });

    factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
        images: json["images"] == null ? [] : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "category": category?.toJson(),
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    };
}

class Category {
    final int? id;
    final String? name;

    Category({
        this.id,
        this.name,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class Image {
    final String? url;
    final String? type;

    Image({
        this.url,
        this.type,
    });

    factory Image.fromJson(Map<String, dynamic> json) => Image(
        url: json["url"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "type": type,
    };
}
