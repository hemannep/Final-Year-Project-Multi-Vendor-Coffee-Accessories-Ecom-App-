// lib/controllers/editProfileController.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/users.dart';

class EditProfileController extends GetxController {
  // Reusable HTTP client
  late final http.Client _client;

  // Current user data
  User? user;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final registerFormKey = GlobalKey<FormState>();

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
    phoneNumberController.dispose();
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

  /// Populate controllers with existing user data
  void initUser(User user) {
    this.user = user;
    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
    phoneNumberController.text = user.phone ?? '';
    update();
  }

  /// Submit updated profile to the server
  Future<void> updateProfile() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    final uid = user?.user_id;
    if (uid == null || uid.isEmpty) {
      showTopSnack('Invalid user ID', isSuccess: false);
      return;
    }

    try {
      final uri = Uri(
        scheme: 'http',
        host: ipAddress,
        path: '/silverskin-api/updateProfilePage.php',
      );

      final body = {
        'user_id': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'phone': phoneNumberController.text.trim().isNotEmpty
            ? phoneNumberController.text.trim()
            : null,
      }..removeWhere((key, value) => value == null);

      final response = await _client.post(uri, body: body);
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        Get.back(); // close edit screen
        update();
        showTopSnack(result['message'], isSuccess: true);
        // Refresh user details in GetDataController
        Get.find<GetDataController>()
            .getMyDetails()
            .catchError((_) {});
      } else {
        showTopSnack(result['message'], isSuccess: false);
      }
    } catch (e) {
      showTopSnack('Error updating profile: \$e', isSuccess: false);
    }
  }
}
