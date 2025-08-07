// To parse this JSON data, do
//
//     final statsResponse = statsResponseFromJson(jsonString);

import 'dart:convert';

StatsResponse statsResponseFromJson(String str) =>
    StatsResponse.fromJson(json.decode(str));

String statsResponseToJson(StatsResponse data) => json.encode(data.toJson());

class StatsResponse {
  final bool? success;
  final List<Stat>? stats;
  final String? message;

  StatsResponse({
    this.success,
    this.stats,
    this.message,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) => StatsResponse(
        success: json["success"],
        stats: json["stats"] == null
            ? []
            : List<Stat>.from(json["stats"]!.map((x) => Stat.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "stats": stats == null
            ? []
            : List<dynamic>.from(stats!.map((x) => x.toJson())),
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