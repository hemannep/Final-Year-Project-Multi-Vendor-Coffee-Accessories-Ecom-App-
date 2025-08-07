import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/controllers/updateUserController.dart';
import 'package:get/get.dart';

class UpdateProfilePage extends StatelessWidget {
  const UpdateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    var dataController = Get.find<GetDataController>();
    var user = dataController.userResponse?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: false,
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
              child: GetBuilder<EditProfileController>(
                initState: (_) {
                  Get.lazyPut<EditProfileController>(
                      () => EditProfileController());
                  if (user != null) {
                    Get.find<EditProfileController>().initUser(user);
                  }
                },
                builder: (controller) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

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
                                // Name Field
                                TextFormField(
                                  controller: controller.nameController,
                                  decoration: InputDecoration(
                                    labelText: "Full Name",
                                    labelStyle: const TextStyle(
                                        color: textSecondaryColor),
                                    prefixIcon: const Icon(Icons.person_outline,
                                        color: accentColor),
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
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                //Email

                                TextFormField(
                                  controller: controller.emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email Address",
                                    labelStyle: const TextStyle(
                                        color: textSecondaryColor),
                                    prefixIcon: const Icon(Icons.email_outlined,
                                        color: accentColor),
                                    filled: true,
                                    fillColor: boxColor.withOpacity(0.6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your email';
                                    }
                                    if (!value!.contains('@')) {
                                      return 'Enter valid email';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(color: textColor),
                                ),
                                const SizedBox(height: 16),

                                // Phone Field
                                TextFormField(
                                  controller: controller.phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Phone Number",
                                    labelStyle: const TextStyle(
                                        color: textSecondaryColor),
                                    prefixIcon: const Icon(Icons.phone_outlined,
                                        color: accentColor),
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
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your phone';
                                    } else if (value!.length < 10) {
                                      return 'Enter valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Update Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text(
                                      'UPDATE PROFILE',
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
