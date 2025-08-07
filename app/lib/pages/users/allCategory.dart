import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/components/productCard.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/category.dart';
import 'package:silverskin/constant.dart';

class AllCategoryPage extends StatelessWidget {
  const AllCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var category = Get.arguments as Category;
    var dataController = Get.find<GetDataController>();

    var filteredProduct = dataController.productResponse?.products
            ?.where((element) => element.categoryId == category.categoryId)
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.categoryTitle ?? "",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor, // Your theme's primary color
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: gradientBackground),
        child: filteredProduct.isEmpty
            ? const Center(
                child: Text(
                  "No products found.",
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondaryColor,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredProduct.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: filteredProduct[index]);
                },
              ),
      ),
    );
  }
}
