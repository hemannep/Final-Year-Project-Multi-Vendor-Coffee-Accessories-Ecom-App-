import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/VendorRegisterController.dart';

class VendorRegisterPage extends StatelessWidget {
  const VendorRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorRegisterController());
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
                    // Logo and Header Section
                    Column(
                      children: [
                        Image.asset(
                          "assets/logo.png",
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Your Store',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join SilverSkin as a vendor',
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Form Section
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
                            // Vendor Name Field
                            TextFormField(
                              controller: controller.fullNameController,
                              decoration: InputDecoration(
                                labelText: "Vendor Name",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.person_outline, color: accentColor),
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
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter vendor name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Store Name Field
                            TextFormField(
                              controller: controller.storeNameController,
                              decoration: InputDecoration(
                                labelText: "Store Name",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.store_outlined, color: accentColor),
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
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter store name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            TextFormField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email Address",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.email_outlined, color: accentColor),
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
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your email';
                                } else if (!GetUtils.isEmail(value!)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Store Description Field
                            TextFormField(
                              controller: controller.storeDescriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Store Description",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.description_outlined, color: accentColor),
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
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter store description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Store Address Field
                            TextFormField(
                              controller: controller.storeAddressController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: "Store Address",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.location_on_outlined, color: accentColor),
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
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter store address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone Field
                            TextFormField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                labelStyle: const TextStyle(color: textSecondaryColor),
                                prefixIcon: const Icon(Icons.phone_outlined, color: accentColor),
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
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your phone';
                                } else if (value!.length < 10) {
                                  return 'Enter valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field with visibility toggle
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
                                onPressed: controller.isLoading.value ? null : controller.register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'REGISTER STORE',
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

                    // Login Option
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
}