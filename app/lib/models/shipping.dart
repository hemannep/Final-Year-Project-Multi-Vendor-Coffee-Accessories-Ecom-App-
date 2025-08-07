// To parse this JSON data, do
//
//     final shippingResponse = shippingResponseFromJson(jsonString);

import 'dart:convert';

ShippingResponse shippingResponseFromJson(String str) => ShippingResponse.fromJson(json.decode(str));

String shippingResponseToJson(ShippingResponse data) => json.encode(data.toJson());

class ShippingResponse {
    final bool? success;
    final List<Datum>? data;
    final String? message;

    ShippingResponse({
        this.success,
        this.data,
        this.message,
    });

    factory ShippingResponse.fromJson(Map<String, dynamic> json) => ShippingResponse(
        success: json["success"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class Datum {
  final int? shippingId;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final bool? isDefault; // Add this line

  Datum({
    this.shippingId,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.isDefault = false, // Add with default value
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        shippingId: json["shipping_id"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        postalCode: json["postal_code"],
        country: json["country"],
        isDefault: json["is_default"] ?? false, // Add this line
      );

  Map<String, dynamic> toJson() => {
        "shipping_id": shippingId,
        "address": address,
        "city": city,
        "state": state,
        "postal_code": postalCode,
        "country": country,
        "is_default": isDefault, // Add this line
      };
}
