// lib/controllers/updateVendorController.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/users.dart';
import 'package:silverskin/models/vendor.dart';

class UpdateVendorController extends GetxController {
  // HTTP client
  late final http.Client _client;

  // Current user and vendor data
  User? user;
  Vendor? vendor;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final storeNameController = TextEditingController();
  final storeDescController = TextEditingController();
  final addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _client = http.Client();
  }

  @override
  void onClose() {
    _client.close();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    storeNameController.dispose();
    storeDescController.dispose();
    addressController.dispose();
    super.onClose();
  }

  /// Centralized top‑snackbar: green=success, red=error
  void showTopSnack(String message, {bool isSuccess = true}) {
    Get.showSnackbar(GetSnackBar(
      message: message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      borderRadius: 8,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    ));
  }

  /// Initialize form fields with existing data
  void initVendor(User user, Vendor vendor) {
    this.user = user;
    this.vendor = vendor;
    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
    phoneController.text = user.phone ?? '';
    storeNameController.text = vendor.storeName ?? '';
    storeDescController.text = vendor.storeDescription ?? '';
    addressController.text = vendor.address ?? '';
    update();
  }

  /// Send updated vendor info to server
  Future<void> updateVendor() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final uid = user?.user_id;
    if (uid == null || uid.isEmpty) {
      showTopSnack('Invalid user ID', isSuccess: false);
      return;
    }

    try {
      final uri = Uri(
        scheme: 'http',
        host: ipAddress,
        path: '/silverskin-api/updateVendorProfile.php',
      );
      final body = {
        'user_id': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'store_name': storeNameController.text.trim(),
        'store_description': storeDescController.text.trim(),
        'address': addressController.text.trim(),
      };

      final response = await _client.post(uri, body: body);
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        Get.back(); // close form
        // Refresh user data
        Get.find<GetDataController>().getMyDetails().catchError((_) {});
        showTopSnack(result['message'], isSuccess: true);
      } else {
        showTopSnack(result['message'], isSuccess: false);
      }
    } catch (e) {
      showTopSnack('Error updating vendor: \$e', isSuccess: false);
    }
  }
}
