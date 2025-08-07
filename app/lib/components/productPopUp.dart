import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/cart.dart';
import 'package:silverskin/models/products.dart';
import 'package:http/http.dart' as http;
import 'package:silverskin/models/vendor.dart';
import 'package:silverskin/pages/users/allVendor.dart';
import 'package:silverskin/pages/users/reviewPage.dart';
import 'package:silverskin/providers/cartProvider.dart';

class ProductModalUtils {
  static void showProductModal(BuildContext context, Product product) async {
    String storeName = await fetchVendorName(product.vendor_id ?? "");

    showModalBottomSheet(
      context: context,
      backgroundColor: primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: borderColor, width: 2),
      ),
      isScrollControlled: true,
      builder: (context) {
        return ProductModalContent(
          product: product,
          store_name: storeName,
          vendorId: product.vendor_id ?? "",
        );
      },
    );
  }

  static Future<String> fetchVendorName(String vendorId) async {
    try {
      var response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/getVendorDetails.php",
        ),
        body: {"vendor_id": vendorId},
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['success'] == true && result['vendor'] != null) {
          return result['vendor']['store_name'] ?? "Vendor Not Found";
        }
      }
      return "Vendor Not Found";
    } catch (e) {
      return "Error Fetching Vendor";
    }
  }
}

class ProductModalContent extends StatefulWidget {
  final Product product;
  final String store_name;
  final String vendorId;

  const ProductModalContent({
    required this.product,
    required this.store_name,
    required this.vendorId,
    super.key,
  });

  @override
  _ProductModalContentState createState() => _ProductModalContentState();
}

class _ProductModalContentState extends State<ProductModalContent> {
  int quantity = 1;
  double averageRating = 0;
  int reviewCount = 0;

  bool _isDescriptionExpanded = false;
  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    try {
      final dataController = Get.find<GetDataController>();
      // Convert product_id from String? to int
      final productId = int.tryParse(widget.product.product_id ?? '0') ?? 0;
      final result = await dataController.getReviews(productId);
      setState(() {
        averageRating = result['average_rating'];
        reviewCount = result['review_count'];
      });
    } catch (e) {
      // Handle error
      debugPrint("Error loading rating: $e");
      setState(() {
        averageRating = 0;
        reviewCount = 0;
      });
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index + 0.5 <= rating
              ? Icons.star
              : index + 1 <= rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Reviews",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRatingStars(averageRating),
            const SizedBox(width: 8),
            Text(
              averageRating > 0
                  ? "${averageRating.toStringAsFixed(1)} ($reviewCount reviews)"
                  : "No reviews yet",
              style: const TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Get.to(() => ReviewPage(
                  productId:
                      int.tryParse(widget.product.product_id ?? '0') ?? 0,
                  productName: widget.product.productName ?? "",
                  orderId: 0, // 0 means just viewing reviews
                  imageUrl: widget.product.imageUrl ?? "",
                ));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "View All Reviews",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "http://$ipAddress/silverskin-api${widget.product.imageUrl ?? ''}",
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 200,
                      color: secondaryColor,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Product Name
            Text(
              widget.product.productName ?? "Product Name",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),

            // Product Price
            Text(
              "Rs. ${widget.product.price}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 10),

            // Store Name
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                final dataController = Get.find<GetDataController>();

                var vendor = dataController.vendors.firstWhere(
                  (v) => v.vendorId == widget.product.vendor_id,
                  orElse: () =>
                      Vendor(vendorId: widget.product.vendor_id ?? ''),
                );

                if (vendor.storeName == null) {
                  final vendorName = await ProductModalUtils.fetchVendorName(
                      widget.product.vendor_id ?? '');
                  vendor = vendor.copyWith(storeName: vendorName);
                }

                Get.to(() => const AllVendorPage(), arguments: vendor);
              },
              child: Row(
                children: [
                  const Icon(Icons.store, color: textSecondaryColor, size: 20),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.store_name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: textSecondaryColor),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Rating Section
            _buildRatingSection(),
            const SizedBox(height: 15),

            // Product Description
            const Text(
              "Description:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),

// Collapsible description
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: ConstrainedBox(
                constraints: _isDescriptionExpanded
                    ? const BoxConstraints()
                    : const BoxConstraints(maxHeight: 48), // approx. 2 lines
                child: Text(
                  widget.product.productDescription ??
                      "No description available.",
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondaryColor,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),

// "See More"/"See Less" toggle
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                }),
                child: Text(
                  _isDescriptionExpanded ? "See Less" : "See More",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ),

            // ──────────── Action Buttons ────────────
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Row(
                children: [
                  // Add to Cart
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final cartProvider =
                            Provider.of<Cartprovider>(context, listen: false);
                        CartItem newItem = CartItem(
                          product: widget.product,
                          quantity: quantity,
                        );
                        cartProvider.addItem(newItem.toJson());
                        Get.showSnackbar(
                          const GetSnackBar(
                            message: "Added to cart!",
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.add_shopping_cart_outlined,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.1),
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrement
                        InkWell(
                          onTap: () => setState(
                              () => quantity = quantity > 1 ? quantity - 1 : 1),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Icon(Icons.remove, size: 18, color: textColor),
                          ),
                        ),

                        // Quantity Display
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),

                        // Increment
                        InkWell(
                          onTap: () => setState(() => quantity++),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add, size: 18, color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
