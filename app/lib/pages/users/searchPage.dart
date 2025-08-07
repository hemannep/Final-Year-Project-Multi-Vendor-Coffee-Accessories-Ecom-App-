import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/components/productCard.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/products.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";
  List<Product> recentSearches = [];

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<GetDataController>();

    List<Product> filteredProducts = searchQuery.isNotEmpty
        ? controller.productResponse?.products
                ?.where((product) =>
                    product.productName
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false)
                .toList() ??
            []
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: true,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                onSubmitted: (value) {
                  Product? product = controller.productResponse?.products
                      ?.firstWhereOrNull((p) => p.productName?.toLowerCase() == value.toLowerCase());
                  if (product != null && !recentSearches.any((p) => p.product_id == product.product_id)) {
                    setState(() => recentSearches.add(product));
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: boxColor.withOpacity(0.8),
                  hintText: "Search products...",
                  hintStyle: const TextStyle(color: textSecondaryColor),
                  prefixIcon: const Icon(Icons.search, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: const TextStyle(color: textColor),
              ),
            ),

            // Recent Searches Section
            if (recentSearches.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Recent Searches",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Wrap(
                  spacing: 10,
                  children: recentSearches.map((product) {
                    return Chip(
                      label: Text(
                        product.productName ?? "",
                        style: const TextStyle(color: textColor),
                      ),
                      backgroundColor: boxColor.withOpacity(0.8),
                      deleteIcon: const Icon(Icons.close, color: textSecondaryColor),
                      onDeleted: () => setState(() => recentSearches.remove(product)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Filtered Products List
            Expanded(
              child: searchQuery.isEmpty
                  ? const Center(
                      child: Text(
                        "Search for products to see results",
                        style: TextStyle(
                          fontSize: 16,
                          color: textSecondaryColor,
                        ),
                      ),
                    )
                  : filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            "No products found",
                            style: TextStyle(
                              fontSize: 16,
                              color: textSecondaryColor,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ProductCard(product: filteredProducts[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}