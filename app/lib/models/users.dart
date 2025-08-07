// To parse this JSON data, do
//
//     final userResponse = userResponseFromJson(jsonString);

import 'dart:convert';

UserResponse userResponseFromJson(String str) => UserResponse.fromJson(json.decode(str));

String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
    bool? success;
    User? user;
    String? message;

    UserResponse({
        this.success,
        this.user,
        this.message,
    });

    factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        success: json["success"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "user": user?.toJson(),
        "message": message,
    };
}

class User {
    String? user_id;
    String? name;
    String? email;
    String? phone;
    String? role;

    User({
        this.user_id,
        this.name,
        this.email,
        this.phone,
        this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        user_id: json["user_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": user_id,
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
    };
}
