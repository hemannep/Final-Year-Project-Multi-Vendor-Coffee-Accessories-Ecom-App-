import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/components/wishListCard.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';



class WishListPage extends StatelessWidget {
  const WishListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GetDataController dataController = Get.find<GetDataController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Wishlist",
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
        decoration: const BoxDecoration(gradient: gradientBackground),
        child: Obx(() {
          // Debugging: Print the wishlist data
          print("Wishlist Data: ${dataController.wishlist}");

          if (dataController.wishlist.isEmpty) {
            return const Center(
              child: Text(
                "Your Wishlist is Empty",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textSecondaryColor,
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataController.wishlist.length,
              itemBuilder: (context, index) {
                final product = dataController.wishlist[index];
                return WishlistProductCard(product: product);
              },
            );
          }
        }),
      ),
    );
  }
}