// To parse this JSON data, do
//
//     final logoutResponsModel = logoutResponsModelFromJson(jsonString);

import 'dart:convert';

LogoutResponsModel logoutResponsModelFromJson(String str) => LogoutResponsModel.fromJson(json.decode(str));

String logoutResponsModelToJson(LogoutResponsModel data) => json.encode(data.toJson());

class LogoutResponsModel {
    final String? message;
    final bool? data;

    LogoutResponsModel({
        this.message,
        this.data,
    });

    factory LogoutResponsModel.fromJson(Map<String, dynamic> json) => LogoutResponsModel(
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
    };
}
