import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/pages/ADMIN/adminHomePage.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      checkLoginAndRole();
    });
  }

  checkLoginAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role') ?? 'user';

    if (isLoggedIn) {
      switch (role) {
        case 'admin':
          Get.offAll(() => const AdminHomePage()); // Direct widget navigation
          break;
        case 'vendor':
          Get.offAllNamed('/vendorHomePage'); 
          break;
        default:
          Get.offAllNamed('/home');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                height: 140,
                image: AssetImage("assets/logo.png"), 
              ),
              SizedBox(height: 20),
              Text(
                "Silver Skin",
                style: TextStyle(
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Brew Your Style",
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                color: textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}