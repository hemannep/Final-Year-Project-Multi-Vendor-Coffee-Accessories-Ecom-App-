import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/main.dart';
import 'package:silverskin/pages/ADMIN/adminDashboard.dart';
import 'package:silverskin/pages/ADMIN/adminOrderPage.dart';
import 'package:silverskin/pages/ADMIN/adminProductPage.dart';
import 'package:silverskin/pages/ADMIN/adminUserPage.dart';
import 'package:silverskin/pages/login.dart';

import '../users/changePassword.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  File? _image;
  String name = "Admin";
  String email = "admin@example.com";
  var admin;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadProfileDetail();
  }

  Future<void> _loadProfileDetail() async {
    final controller = Get.find<GetDataController>();
    await controller.getMyDetails();
    setState(() {
      admin = controller.userResponse?.user;
      name = admin?.name ?? name;
      email = admin?.email ?? email;
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('admin_profile_image');
    if (imagePath != null) {
      setState(() => _image = File(imagePath));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final dir = await getApplicationDocumentsDirectory();
      final saved = File('${dir.path}/admin_profile.png');
      await File(pickedFile.path).copy(saved.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_profile_image', saved.path);
      setState(() => _image = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
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
            constraints: BoxConstraints(minHeight: height),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: boxColor,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(Icons.admin_panel_settings, size: 50, color: textSecondaryColor)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text(email, style: const TextStyle(fontSize: 16, color: textSecondaryColor)),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ProfileButton(
                          icon: Icons.group,
                          text: 'Manage Users',
                          onTap: () => Get.to(() => const AdminUsersPage()),
                        ),
                        const SizedBox(height: 16),
                        ProfileButton(
                          icon: Icons.inventory,
                          text: 'Manage Products',
                          onTap: () => Get.to(() => const AdminProductsPage()),
                        ),
                        const SizedBox(height: 16),
                        ProfileButton(
                          icon: Icons.receipt_long,
                          text: 'View Orders',
                          onTap: () => Get.to(() => const AdminOrdersPage()),
                        ),
                        const SizedBox(height: 16),
                        ProfileButton(
                          icon: Icons.bar_chart,
                          text: 'Analytics & Reports',
                          onTap: () => Get.to(() => const AdminDashboardPage()),
                        ),
                        const SizedBox(height: 16),
                        ProfileButton(
                          icon: Icons.lock_outline,
                          text: "Change Password",
                          onTap: () {
                            Get.to(() => const ChangePasswordPage(user_id: ''));
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await prefs.clear();
                              Get.offAll(() =>  LoginPage());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: const Text('LOGOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileButton({super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(color: boxColor.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: textSecondaryColor, size: 16),
          ],
        ),
      ),
    );
  }
}