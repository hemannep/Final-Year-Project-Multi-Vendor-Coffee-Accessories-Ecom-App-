import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:silverskin/components/productPopUp.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/cart.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/providers/cartProvider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final int? quantity;

  const ProductCard({super.key, required this.product, this.quantity});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 1;
  bool isWishlisted = false;
  double averageRating = 0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  @override
  void dispose() {
    // no controllers/timers to clean up here
    super.dispose();
  }

  Future<void> _loadRating() async {
    try {
      final dataController = Get.find<GetDataController>();
      final productId = int.tryParse(widget.product.product_id ?? '0') ?? 0;
      final result = await dataController.getReviews(productId);

      if (!mounted) return;
      setState(() {
        averageRating = result['average_rating'];
        reviewCount = result['review_count'];
      });
    } catch (e) {
      debugPrint("Error loading rating: $e");
      if (!mounted) return;
      setState(() {
        averageRating = 0;
        reviewCount = 0;
      });
      Get.showSnackbar(const GetSnackBar(
        message: "Failed to load reviews",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
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
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<GetDataController>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image
                GestureDetector(
                  onTap: () {
                    ProductModalUtils.showProductModal(
                        context, widget.product);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "http://$ipAddress/silverskin-api${widget.product.imageUrl ?? ""}",
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        width: 100,
                        height: 100,
                        color: secondaryColor,
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Details + Buttons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        widget.product.productName ?? "Product Name",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      // Price
                      Text(
                        "Rs. ${widget.product.price}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Rating
                      Row(
                        children: [
                          _buildRatingStars(averageRating),
                          const SizedBox(width: 4),
                          Text(
                            averageRating > 0
                                ? "${averageRating.toStringAsFixed(1)} ($reviewCount)"
                                : "No reviews",
                            style: const TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quantity + Add to Cart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Qty Controls
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (quantity > 1) quantity--;
                                  });
                                },
                                child: const Icon(
                                  Icons.remove_circle_outline,
                                  color: textColor,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() => quantity++);
                                },
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: textColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          // Add to Cart
                          ElevatedButton(
                            onPressed: () {
                              final cartProvider = Provider.of<Cartprovider>(
                                  context,
                                  listen: false);
                              cartProvider.addItem(
                                CartItem(
                                  product: widget.product,
                                  quantity: quantity,
                                ).toJson(),
                              );
                              Get.showSnackbar(const GetSnackBar(
                                message: "Added to cart!",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Add to Cart",
                                style: buttonTextStyle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Wishlist Icon
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
                final idString = widget.product.product_id ?? '';
                final pid = int.tryParse(idString);
                if (pid == null) {
                  Get.showSnackbar(const GetSnackBar(
                    message: "Invalid product ID.",
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }
                await dataController.addWishlist(pid);
                if (!mounted) return;
                setState(() {
                  isWishlisted = true;
                });
              },
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? accentColor : textColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
