import 'package:silverskin/constant.dart';
import 'package:silverskin/models/products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductInCart extends StatefulWidget {
  final Product product;
  final int? quantity;
  final VoidCallback? onDelete;
  final Function(int newQuantity)? onQuantityChanged;

  const ProductInCart({
    super.key,
    required this.product,
    this.quantity,
    this.onDelete,
    this.onQuantityChanged,
  });

  @override
  State<ProductInCart> createState() => _ProductInCartState();
}

class _ProductInCartState extends State<ProductInCart> {
  late int currentQuantity;

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.quantity ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final int pricePerItem =
        int.tryParse(widget.product.price ?? '0') ?? 0;
    final int totalPrice = pricePerItem * currentQuantity;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 140,
      decoration: BoxDecoration(
        gradient: gradientBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "http://$ipAddress/silverskin-api${widget.product.imageUrl ?? ''}",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: textColor,
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Details & Controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name
                  Text(
                    widget.product.productName ?? "Product Name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  // Quantity label
                  Text(
                    "$currentQuantity items",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textSecondaryColor,
                    ),
                  ),

                  // Price label
                  Text(
                    "Rs. $totalPrice (Rs. ${widget.product.price} each)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textSecondaryColor,
                    ),
                  ),

                  // ───── Controls Row ─────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity adjusters
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            padding: const EdgeInsets.all(4),
                            onPressed: () {
                              if (currentQuantity > 1) {
                                setState(() => currentQuantity--);
                                widget.onQuantityChanged
                                    ?.call(currentQuantity);
                              } else {
                                Get.showSnackbar(
                                  const GetSnackBar(
                                    message: "Minimum quantity reached",
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          ),

                          // Fixed-width quantity text
                          SizedBox(
                            width: 24,
                            child: Text(
                              '$currentQuantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textSecondaryColor,
                              ),
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.add),
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            padding: const EdgeInsets.all(4),
                            onPressed: () {
                              setState(() => currentQuantity++);
                              widget.onQuantityChanged
                                  ?.call(currentQuantity);
                            },
                          ),
                        ],
                      ),

                      // Delete button
                      ElevatedButton(
                        onPressed: widget.onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ), // ─ end Controls Row ─
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
