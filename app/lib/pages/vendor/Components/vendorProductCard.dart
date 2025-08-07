import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/pages/users/reviewPage.dart';
import 'package:silverskin/pages/vendor/editProductPage.dart';

class VendorProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final Function(Product) onUpdate;
  final Function(String) onStatusChanged;

  const VendorProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onUpdate,
    required this.onStatusChanged,
  });

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'public':
        return Colors.green;
      case 'private':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStatusOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Product Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.public, color: Colors.green),
              title: const Text('Make Public'),
              subtitle: const Text('Visible to all users'),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged('Public');
              },
            ),
            ListTile(
              leading: const Icon(Icons.private_connectivity, color: Colors.orange),
              title: const Text('Make Private'),
              subtitle: const Text('Only visible to vendor'),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged('Private');
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: accentColor)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "http://$ipAddress/silverskin-api${product.imageUrl ?? ''}",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: secondaryColor,
                      child: const Icon(Icons.image_not_supported, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.productName ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: _getStatusColor(product.onlineStatus),
                            ),
                            onPressed: () => _showStatusOptions(context),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          product.onlineStatus?.toUpperCase() ?? 'UNKNOWN',
                          style: TextStyle(
                            color: _getStatusColor(product.onlineStatus),
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: _getStatusColor(product.onlineStatus).withOpacity(0.2),
                        side: BorderSide(color: _getStatusColor(product.onlineStatus)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rs. ${product.price}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stock: ${product.stock}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Category: ${product.categoryTitle ?? 'Unknown'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.productDescription ?? 'No description available',
              style: const TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (product.onlineStatus?.toLowerCase() == 'rejected')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'This product was rejected by admin',
                  style: TextStyle(
                    color: _getStatusColor('rejected'),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Get.to(() => ReviewPage(
                      productId: int.tryParse(product.product_id ?? '0') ?? 0,
                      productName: product.productName ?? 'Product',
                      orderId: 0, // 0 means vendor view
                      imageUrl: product.imageUrl ?? '',
                    ));
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: accentColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reviews, size: 16, color: accentColor),
                      SizedBox(width: 4),
                      Text("View Reviews", style: TextStyle(color: accentColor)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: product.onlineStatus?.toLowerCase() == 'rejected'
                          ? null
                          : () => _editProduct(context),
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: product.onlineStatus?.toLowerCase() == 'rejected'
                            ? Colors.grey
                            : accentColor,
                      ),
                      label: Text(
                        "Edit",
                        style: TextStyle(
                          color: product.onlineStatus?.toLowerCase() == 'rejected'
                              ? Colors.grey
                              : accentColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: product.onlineStatus?.toLowerCase() == 'rejected'
                              ? Colors.grey
                              : accentColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(BuildContext context) {
    Get.to(() => EditProductPage(
      product: product,
      onUpdate: onUpdate,
    ));
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: primaryColor,
        title: const Text("Confirm Delete", style: TextStyle(color: textColor)),
        content: const Text(
          "Are you sure you want to delete this product?",
          style: TextStyle(color: textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: accentColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}