import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/userRegisterController.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserRegisterController());
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo & Header
                    Column(
                      children: [
                        Image.asset("assets/logo.png", height: 120),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join SilverSkin today',
                          style: TextStyle(fontSize: 16, color: textSecondaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Registration Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: boxColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: controller.registerFormKey,
                        child: Column(
                          children: [
                            // Full Name
                            TextFormField(
                              controller: controller.fullNameController,
                              decoration: _buildInputDecoration("Full Name", Icons.person_outline),
                              style: const TextStyle(color: textColor),
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _buildInputDecoration("Email Address", Icons.email_outlined),
                              style: const TextStyle(color: textColor),
                              validator: (value) {
                                if (value!.isEmpty) return 'Please enter your email';
                                if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone Number
                            TextFormField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration("Phone Number", Icons.phone_outlined),
                              style: const TextStyle(color: textColor),
                              validator: (value) =>
                                  value!.length < 10 ? 'Enter a valid phone number' : null,
                            ),
                            const SizedBox(height: 16),

                            // Password
                             Obx(() => TextFormField(
                              controller: controller.passwordController,
                              obscureText: controller.obscurePassword.value,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.lock_outline, color: accentColor),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.obscurePassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: accentColor,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!value.contains(RegExp(r'[A-Z]'))) {
                                  return 'Must contain at least one uppercase letter';
                                }
                                if (!value.contains(RegExp(r'[a-z]'))) {
                                  return 'Must contain at least one lowercase letter';
                                }
                                if (!value.contains(RegExp(r'[0-9]'))) {
                                  return 'Must contain at least one number';
                                }
                                if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                  return 'Must contain at least one special character';
                                }
                                return null;
                              },
                            )),
                            const SizedBox(height: 16),
                            // Register Button
                            Obx(() => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'REGISTER',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Already have account
                    TextButton(
                      onPressed: () => Get.back(),
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: textSecondaryColor),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textSecondaryColor),
      prefixIcon: Icon(icon, color: accentColor),
      filled: true,
      fillColor: boxColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
