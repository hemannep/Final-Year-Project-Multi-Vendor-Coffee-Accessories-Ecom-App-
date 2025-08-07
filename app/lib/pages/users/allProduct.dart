// lib/pages/users/allProduct.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/category.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/components/productCard.dart';

class AllProductPage extends StatefulWidget {
  const AllProductPage({super.key});

  @override
  State<AllProductPage> createState() => _AllProductPageState();
}

class _AllProductPageState extends State<AllProductPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final Category? category = Get.arguments as Category?;
    final dataController = Get.find<GetDataController>();

    // Start from either all products or category‑filtered
    List<Product> products =
        dataController.productResponse?.products?.toList() ?? [];
    if (category != null) {
      products = products
          .where((p) => p.categoryId == category.categoryId)
          .toList();
    } else {
      products.shuffle();
    }

    // Apply search filter on top
    final List<Product> displayed = searchQuery.isNotEmpty
        ? products
            .where((p) =>
                p.productName
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false)
            .toList()
        : products;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category?.categoryTitle ?? 'All Products',
          style: const TextStyle(color: textColor),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: gradientBackground),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: textSecondaryColor),
                  prefixIcon: const Icon(Icons.search, color: accentColor),
                  filled: true,
                  fillColor: boxColor.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                style: const TextStyle(color: textColor),
              ),
            ),

            // Products List
            Expanded(
              child: displayed.isEmpty
                  ? Center(
                      child: Text(
                        searchQuery.isNotEmpty
                            ? "No products match \"$searchQuery\"."
                            : "No products found.",
                        style: const TextStyle(
                          fontSize: 16,
                          color: textSecondaryColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      itemCount: displayed.length,
                      itemBuilder: (context, i) =>
                          ProductCard(product: displayed[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
