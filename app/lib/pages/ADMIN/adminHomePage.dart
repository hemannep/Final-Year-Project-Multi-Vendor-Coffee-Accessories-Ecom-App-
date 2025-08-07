
import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/pages/ADMIN/adminDashboard.dart';
import 'package:silverskin/pages/ADMIN/adminOrderPage.dart';
import 'package:silverskin/pages/ADMIN/adminProductPage.dart';
import 'package:silverskin/pages/ADMIN/adminProfile.dart';


class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  var screens = [
    const AdminDashboardPage(),
    const AdminOrdersPage(),
    const AdminProductsPage(),
    const AdminProfilePage(),
    
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
                icon: Icon(Icons.add_box),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                label: "Products",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ]));
  }
}