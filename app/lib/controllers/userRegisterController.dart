// lib/controllers/userRegisterController.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:silverskin/constant.dart';

class UserRegisterController extends GetxController {
  // HTTP client
  late final http.Client _client;

  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key
  final registerFormKey = GlobalKey<FormState>();

  // State
  final obscurePassword = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _client = http.Client();
  }

  @override
  void onClose() {
    _client.close();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
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
      duration: const Duration(seconds: 3),
    ));
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  /// Register a new user
  Future<void> register() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    isLoading(true);
    try {
      final uri = Uri(
        scheme: 'http',
        host: ipAddress,
        path: '/silverskin-api/auth/userRegister.php',
      );

      final response = await _client.post(uri, body: {
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
      });

      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        // Clear inputs
        fullNameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();

        Get.back();
        showTopSnack(result['message'], isSuccess: true);
      } else {
        showTopSnack(result['message'], isSuccess: false);
      }
    } catch (e) {
      showTopSnack('Error: \$e', isSuccess: false);
    } finally {
      isLoading(false);
    }
  }
}