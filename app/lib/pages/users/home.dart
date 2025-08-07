import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/pages/users/cartPage.dart';
import 'package:silverskin/pages/users/firstPage.dart';
import 'package:silverskin/pages/users/orderPage.dart';
import 'package:silverskin/pages/users/profilePage.dart';
import 'package:silverskin/pages/users/wishlistPage.dart';
import 'package:silverskin/providers/cartProvider.dart'; // ← your Cartprovider

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final screens = const [
    FirstPage(),
    CartPage(),
    WishListPage(),
    OrderPage(),
    ProfilePage(),
  ];
  var activePage = 0;

  @override
  Widget build(BuildContext context) {
    // Listen to cartProvider so badge updates automatically
    final cartProvider = Provider.of<Cartprovider>(context);
    final totalItems = cartProvider.totalItems;

    return Scaffold(
      body: screens[activePage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activePage,
        onTap: (page) => setState(() => activePage = page),
        selectedItemColor: const Color.fromARGB(255, 255, 245, 60),
        unselectedItemColor: primaryColor,
        backgroundColor: accentColor,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          // Cart icon with badge
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                if (totalItems > 0)
                  Positioned(
                    right: -6,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$totalItems',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Cart",
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Orders",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
