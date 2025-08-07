import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:silverskin/main.dart';

class ChangePasswordPage extends StatefulWidget {
  final String user_id;
  const ChangePasswordPage({super.key, required this.user_id});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscureOldPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  Future<void> changePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/auth/changePassword.php",
        ),
        body: {
          "currentPassword": oldPasswordController.text,
          "newPassword": newPasswordController.text,
          "user_id": prefs.getInt("user_id").toString(),
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        Get.back();
        Get.snackbar(
          'Success',
          result['message'] ?? 'Password changed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to change password',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        "Error: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            // Old Password
                            TextFormField(
                              controller: oldPasswordController,
                              obscureText: obscureOldPassword,
                              decoration: InputDecoration(
                                labelText: "Old Password",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.lock_outline, color: accentColor),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureOldPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: accentColor,
                                  ),
                                  onPressed: () => setState(() {
                                    obscureOldPassword = !obscureOldPassword;
                                  }),
                                ),
                                filled: true,
                                fillColor: boxColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              style: const TextStyle(color: textColor),
                              validator: (val) =>
                                  (val?.isEmpty ?? true) ? 'Please enter your current password' : null,
                            ),
                            const SizedBox(height: 16),
                            // New Password
                            TextFormField(
                              controller: newPasswordController,
                              obscureText: obscureNewPassword,
                              decoration: InputDecoration(
                                labelText: "New Password",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.lock_outline, color: accentColor),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureNewPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: accentColor,
                                  ),
                                  onPressed: () => setState(() {
                                    obscureNewPassword = !obscureNewPassword;
                                  }),
                                ),
                                filled: true,
                                fillColor: boxColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              style: const TextStyle(color: textColor),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Please enter password';
                                if (val.length < 8) return 'Must be at least 8 characters';
                                if (!RegExp(r'[A-Z]').hasMatch(val)) return 'Add an uppercase letter';
                                if (!RegExp(r'[a-z]').hasMatch(val)) return 'Add a lowercase letter';
                                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(val)) return 'Add a special character';
                                if (val == oldPasswordController.text) return 'Choose a different password';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Confirm Password
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: "Confirm Password",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.lock_outline, color: accentColor),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: accentColor,
                                  ),
                                  onPressed: () => setState(() {
                                    obscureConfirmPassword = !obscureConfirmPassword;
                                  }),
                                ),
                                filled: true,
                                fillColor: boxColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              style: const TextStyle(color: textColor),
                              validator: (val) {
                                if (val?.isEmpty ?? true) return 'Please confirm your password';
                                if (val != newPasswordController.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Change Password Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'CHANGE PASSWORD',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
