

import 'dart:convert';

import 'package:silverskin/models/users.dart';

AdminUsersResponse adminUsersResponseFromJson(String str) => 
    AdminUsersResponse.fromJson(json.decode(str));

String adminUsersResponseToJson(AdminUsersResponse data) => 
    json.encode(data.toJson());

class AdminUsersResponse {
  bool? success;
  List<User>? users;
  String? message;

  AdminUsersResponse({
    this.success,
    this.users,
    this.message,
  });

  factory AdminUsersResponse.fromJson(Map<String, dynamic> json) => AdminUsersResponse(
    success: json["success"],
    users: json["users"] == null 
      ? [] 
      : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "users": users == null 
      ? [] 
      : List<dynamic>.from(users!.map((x) => x.toJson())),
    "message": message,
  };
}