import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/main.dart';
import 'package:silverskin/pages/login.dart';
import 'package:silverskin/pages/users/changePassword.dart';
import 'package:silverskin/pages/vendor/updateVendor.dart';
import 'package:silverskin/pages/vendor/vendorOrderPage.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  _VendorProfilePageState createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  File? _image;
  String name = "User Name";
  var user;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadProfileDetail();
  }

  Future<void> _loadProfileDetail() async {
    var dataController = Get.find<GetDataController>();
    await dataController.getMyDetails();
    setState(() {
      user = dataController.userResponse?.user;
      name = user?.name ?? "User Name";
    });
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final savedImage = File('${directory.path}/profile_image.png');
      await File(pickedFile.path).copy(savedImage.path);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', savedImage.path);
      setState(() {
        _image = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
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
            constraints: BoxConstraints(minHeight: screenHeight),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Profile Picture
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: boxColor,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(
                                Icons.person_outline,
                                size: 50,
                                color: textSecondaryColor,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // User Email
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: textSecondaryColor,
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Profile Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ProfileButton(
                          icon: Icons.person_outline,
                          text: "Update Profile",
                          onTap: () {
                            Get.to(() =>  const UpdateVendor())?.then((_) {
                              _loadProfileDetail();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ProfileButton(
                          icon: Icons.lock_outline,
                          text: "Change Password",
                          onTap: () {
                            Get.to(() => const ChangePasswordPage(user_id: ''));
                          },
                        ),
                        const SizedBox(height: 16),
                        ProfileButton(
                          icon: Icons.shopping_bag_outlined,
                          text: "Orders",
                          onTap: () {
                            Get.to(() => const VendorOrderPage());
                          },
                        ),
                        const SizedBox(height: 16),
                        // Logout Button
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'LOGOUT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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

  const ProfileButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: boxColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, 
                color: textSecondaryColor, size: 16),
          ],
        ),
      ),
    );
  }
}