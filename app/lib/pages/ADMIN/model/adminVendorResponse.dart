// models/admin_vendors_response.dart

import 'dart:convert';

import 'package:silverskin/models/vendor.dart';

AdminVendorsResponse adminVendorsResponseFromJson(String str) => 
    AdminVendorsResponse.fromJson(json.decode(str));

String adminVendorsResponseToJson(AdminVendorsResponse data) => 
    json.encode(data.toJson());

class AdminVendorsResponse {
  bool? success;
  List<Vendor>? vendors;
  String? message;

  AdminVendorsResponse({
    this.success,
    this.vendors,
    this.message,
  });

  factory AdminVendorsResponse.fromJson(Map<String, dynamic> json) => AdminVendorsResponse(
    success: json["success"],
    vendors: json["vendors"] == null 
      ? [] 
      : List<Vendor>.from(json["vendors"]!.map((x) => Vendor.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "vendors": vendors == null 
      ? [] 
      : List<dynamic>.from(vendors!.map((x) => x.toJson())),
    "message": message,
  };
}