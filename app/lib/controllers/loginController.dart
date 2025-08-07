// lib/controllers/loginController.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:silverskin/constant.dart';
import 'package:silverskin/pages/ADMIN/adminhomepage.dart';
import 'package:silverskin/pages/vendor/vendorhomepage.dart';
import 'package:silverskin/pages/users/home.dart';

class LoginController extends GetxController {
  // Controllers & form key
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  // State
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  // Reusable HTTP client
  final http.Client _client = http.Client();

  @override
  void onClose() {
    _client.close();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Top‐snackbar helper: green=success, red=error
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

  /// Attempt login
  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uri = Uri(
        scheme: 'http',
        host: ipAddress,
        path: '/silverskin-api/auth/login.php',
      );

      final response = await _client.post(uri, body: {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        // Clear inputs
        emailController.clear();
        passwordController.clear();

        showTopSnack(result['message'], isSuccess: true);

        // Persist session
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', result['role']);
        await prefs.setInt('user_id', result['user_id']);

        // Navigate by role
        switch (result['role']) {
          case 'admin':
            Get.offAll(() => const AdminHomePage());
            break;
          case 'vendor':
            await prefs.setString('vendor_id', result['vendor_id'].toString());
            Get.offAll(() => const VendorHomePage());
            break;
          default:
            Get.offAll(() => const HomePage());
        }
      } else {
        // Special vendor states
        final msg = result['message'];
        if (msg == 'vendor_pending') {
          _showVendorPendingDialog();
        } else if (msg == 'vendor_rejected') {
          _showVendorRejectedDialog();
        } else {
          showTopSnack(msg, isSuccess: false);
        }
      }
    } catch (e) {
      showTopSnack("Error: ${e.toString()}", isSuccess: false);
    } finally {
      isLoading(false);
    }
  }

  void _showVendorPendingDialog() {
    Get.defaultDialog(
      title: "Approval Pending",
      middleText:
          "Your vendor account is not yet approved. You'll be redirected to the user side.",
      textConfirm: "OK",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: accentColor,
      cancelTextColor: textColor,
      onConfirm: () {
        Get.back();
        Get.offAll(() => const HomePage());
      },
      onCancel: Get.back,
    );
  }

  void _showVendorRejectedDialog() {
    Get.defaultDialog(
      title: "Account Rejected",
      middleText:
          "Your vendor account has been rejected. You'll be redirected to the user side.",
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      buttonColor: accentColor,
      onConfirm: () {
        Get.back();
        Get.offAll(() => const HomePage());
      },
    );
  }

  /// Toggle password field visibility
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }
}
