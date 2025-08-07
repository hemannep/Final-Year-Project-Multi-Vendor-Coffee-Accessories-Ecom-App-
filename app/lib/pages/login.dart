// lib/pages/login.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/loginController.dart';
import 'package:silverskin/pages/registration.dart';

class LoginPage extends StatelessWidget {
  // 1️⃣ Initialize once, keep alive for the lifetime of the app:
  final LoginController controller = Get.put(
    LoginController(),
    permanent: true,
  );

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    // ───── Logo & Welcome ─────
                    Image.asset(
                      "assets/logo.png",
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue to SilverSkin',
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ───── Form Container ─────
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
                        key: controller.loginFormKey,
                        child: Column(
                          children: [
                            // Email
                            TextFormField(
                              controller: controller.emailController,
                              decoration: InputDecoration(
                                labelText: "Email Address",
                                labelStyle:
                                    const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: accentColor,
                                ),
                                filled: true,
                                fillColor: boxColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16),
                              ),
                              style: const TextStyle(color: textColor),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Please enter your email' : null,
                            ),
                            const SizedBox(height: 20),

                            // Password
                            Obx(
                              () => TextFormField(
                                controller: controller.passwordController,
                                obscureText: controller.obscurePassword.value,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: const TextStyle(
                                      color: textSecondaryColor),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: accentColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: accentColor,
                                    ),
                                    onPressed: controller.obscurePassword.toggle,
                                  ),
                                  filled: true,
                                  fillColor: boxColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                ),
                                style: const TextStyle(color: textColor),
                                validator: (v) =>
                                    (v?.isEmpty ?? true) ? 'Please enter your password' : null,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // // Forgot Password
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: TextButton(
                            //     onPressed: () {
                            //       Get.to(() => const ForgetPasswordPage());
                            //     },
                            //     child: const Text(
                            //       'Forgot Password?',
                            //       style: TextStyle(
                            //         color: accentColor,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 20),

                            // Login Button
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ───── Signup Link ─────
                    TextButton(
                      onPressed: () {
                        Get.to(() => const RegistrationTypePage());
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: textSecondaryColor),
                          children: [
                            TextSpan(
                              text: 'Register',
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
}
