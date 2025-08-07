import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/pages/vendor/vendorDashboard.dart';

import 'package:silverskin/pages/vendor/vendorOrderPage.dart';
import 'package:silverskin/pages/vendor/vendorProductPage.dart';
import 'package:silverskin/pages/vendor/vendorProfile.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  final screens = [
    const VendorDashboardPage(),
     const VendorProductPage(),
     const VendorOrderPage(),
    const VendorProfilePage(),
    
  ];
  var activePage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[activePage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activePage,
        onTap: (page) {
          setState(() {
            activePage = page;
          });
        },
       selectedItemColor: const Color.fromARGB(255, 255, 245, 60), // Orange for active items
        unselectedItemColor: primaryColor, //  // Lighter white for inactive items
        backgroundColor: accentColor, // Dark background for nav bar
        type: BottomNavigationBarType.fixed, // Light white for inactive items
        showSelectedLabels: true,
        showUnselectedLabels: true,
               items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: "My Products",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
