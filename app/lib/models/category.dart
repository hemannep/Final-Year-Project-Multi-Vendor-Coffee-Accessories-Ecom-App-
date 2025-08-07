// To parse this JSON data, do
//
//     final categoriesResponse = categoriesResponseFromJson(jsonString);

import 'dart:convert';

CategoriesResponse categoriesResponseFromJson(String str) => CategoriesResponse.fromJson(json.decode(str));

String categoriesResponseToJson(CategoriesResponse data) => json.encode(data.toJson());

class CategoriesResponse {
    final bool? success;
    final List<Category>? categories;
    final String? message;

    CategoriesResponse({
        this.success,
        this.categories,
        this.message,
    });

    factory CategoriesResponse.fromJson(Map<String, dynamic> json) => CategoriesResponse(
        success: json["success"],
        categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "message": message,
    };
}

class Category {
    final String? categoryId;
    final String? categoryTitle;
    final String? categoryDescription;
    final DateTime? createdAt;

    Category({
        this.categoryId,
        this.categoryTitle,
        this.categoryDescription,
        this.createdAt,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json["category_id"],
        categoryTitle: json["category_title"],
        categoryDescription: json["category_description"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "category_title": categoryTitle,
        "category_description": categoryDescription,
        "created_at": createdAt?.toIso8601String(),
    };
}
