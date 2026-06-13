// To parse this JSON data, do
//
//     final usersSubscribedModel = usersSubscribedModelFromJson(jsonString);

import 'dart:convert';

UsersSubscribedModel usersSubscribedModelFromJson(String str) => UsersSubscribedModel.fromJson(json.decode(str));

String usersSubscribedModelToJson(UsersSubscribedModel data) => json.encode(data.toJson());

class UsersSubscribedModel {
    final int? id;
    final String? firstName;
    final String? lastName;
    final String? email;
    final String? phone;
    final DateTime? dateOfBirth;
    final String? role;
    final int? gender;
    final int? height;
    final int? weight;
    final int? isActive;
    final bool? isVerified;
    final String? profilePic;
    final List<UserSubscription>? userSubscriptions;

    UsersSubscribedModel({
        this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.dateOfBirth,
        this.role,
        this.gender,
        this.height,
        this.weight,
        this.isActive,
        this.isVerified,
        this.profilePic,
        this.userSubscriptions,
    });

    factory UsersSubscribedModel.fromJson(Map<String, dynamic> json) => UsersSubscribedModel(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phone: json["phone"],
        dateOfBirth: json["date_of_birth"] == null ? null : DateTime.parse(json["date_of_birth"]),
        role: json["role"],
        gender: json["gender"],
        height: json["height"],
        weight: json["weight"],
        isActive: json["is_active"],
        isVerified: json["is_verified"],
        profilePic: json["profile_pic"],
        userSubscriptions: json["user_subscriptions"] == null ? [] : List<UserSubscription>.from(json["user_subscriptions"]!.map((x) => UserSubscription.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "date_of_birth": "${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}",
        "role": role,
        "gender": gender,
        "height": height,
        "weight": weight,
        "is_active": isActive,
        "is_verified": isVerified,
        "profile_pic": profilePic,
        "user_subscriptions": userSubscriptions == null ? [] : List<dynamic>.from(userSubscriptions!.map((x) => x.toJson())),
    };
}

class UserSubscription {
    final int? id;
    final Subscription? subscription;
    final String? status;
    final int? isActive;
    final DateTime? startDate;
    final DateTime? endDate;

    UserSubscription({
        this.id,
        this.subscription,
        this.status,
        this.isActive,
        this.startDate,
        this.endDate,
    });

    factory UserSubscription.fromJson(Map<String, dynamic> json) => UserSubscription(
        id: json["id"],
        subscription: json["subscription"] == null ? null : Subscription.fromJson(json["subscription"]),
        status: json["status"],
        isActive: json["is_active"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "subscription": subscription?.toJson(),
        "status": status,
        "is_active": isActive,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
    };
}

class Subscription {
    final int? id;
    final String? title;
    final String? description;
    final String? type;
    final int? price;
    final String? currency;
    final bool? isGeneral;
    final bool? isActive;
    final int? months;

    Subscription({
        this.id,
        this.title,
        this.description,
        this.type,
        this.price,
        this.currency,
        this.isGeneral,
        this.isActive,
        this.months,
    });

    factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        type: json["type"],
        price: json["price"],
        currency: json["currency"],
        isGeneral: json["is_general"],
        isActive: json["is_active"],
        months: json["months"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "type": type,
        "price": price,
        "currency": currency,
        "is_general": isGeneral,
        "is_active": isActive,
        "months": months,
    };
}
