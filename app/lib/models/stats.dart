// To parse this JSON data, do
//
//     final vendorStatResponse = vendorStatResponseFromJson(jsonString);

import 'dart:convert';

VendorStatResponse vendorStatResponseFromJson(String str) => VendorStatResponse.fromJson(json.decode(str));

String vendorStatResponseToJson(VendorStatResponse data) => json.encode(data.toJson());

class VendorStatResponse {
    final bool? success;
    final List<Stat>? stats;
    final String? message;

    VendorStatResponse({
        this.success,
        this.stats,
        this.message,
    });

    factory VendorStatResponse.fromJson(Map<String, dynamic> json) => VendorStatResponse(
        success: json["success"],
        stats: json["stats"] == null ? [] : List<Stat>.from(json["stats"]!.map((x) => Stat.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "stats": stats == null ? [] : List<dynamic>.from(stats!.map((x) => x.toJson())),
        "message": message,
    };
}

class Stat {
    final String? title;
    final String? value;

    Stat({
        this.title,
        this.value,
    });

    factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        title: json["title"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "value": value,
    };
}
