import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/components/productCard.dart';
import 'package:silverskin/pages/vendor/Components/vendorCard.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/vendor.dart';
import 'package:silverskin/constant.dart';

class AllVendorPage extends StatelessWidget {
  const AllVendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = Get.arguments as Vendor;
    final dataController = Get.find<GetDataController>();
    final vendorProducts = dataController.productResponse?.products
            ?.where((p) => p.vendor_id == vendor.vendorId)
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          vendor.storeName ?? "",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: gradientBackground),
        child: SingleChildScrollView(              // ① make the whole page scrollable :contentReference[oaicite:0]{index=0}
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Vendor Card ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: VendorCard(vendor: vendor),
                ),

                // ─── Section Title ───
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Products by ${vendor.storeName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),

                // ─── Product List ───
                const SizedBox(height: 8),
                if (vendorProducts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Text(
                      "No products found.",
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondaryColor,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: vendorProducts.length,
                    shrinkWrap: true,                           // ② wrap to content height :contentReference[oaicite:1]{index=1}
                    physics: const NeverScrollableScrollPhysics(), // ③ disable inner scrolling
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ProductCard(product: vendorProducts[index]),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
