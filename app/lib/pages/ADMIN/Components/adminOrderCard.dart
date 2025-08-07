import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/order.dart';
import 'package:silverskin/models/shipping.dart';
import 'package:silverskin/models/vendor.dart';
import 'package:http/http.dart' as http;

class AdminOrderCard extends StatelessWidget {
  final Order order;
  final Map<int, Vendor> vendorsForOrder;
  final Function(int, String) onUpdateStatus;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.vendorsForOrder,
    required this.onUpdateStatus,
  });

  Future<void> _showShippingDetails(int userId) async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/getShipping.php"),
        body: {'user_id': userId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null && data['data'].isNotEmpty) {
          final shipping = ShippingResponse.fromJson(data);
          _showShippingDialog(shipping.data?.first);
        } else {
          Get.showSnackbar(const GetSnackBar(
            message: "No shipping details found",
            duration: Duration(seconds: 2),
          ));
        }
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error fetching shipping details: ${e.toString()}",
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _showShippingDialog(Datum? shipping) {
    Get.dialog(
      AlertDialog(
        title: const Text("Shipping Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.userName ?? 'Customer',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildShippingDetailRow("Phone", order.userPhone),
              _buildShippingDetailRow("Email", order.userEmail),
              const Divider(height: 20),
              if (shipping != null) ...[
                _buildShippingDetailRow("Address", shipping.address),
                _buildShippingDetailRow("City", shipping.city),
                _buildShippingDetailRow("State", shipping.state),
                _buildShippingDetailRow("Postal Code", shipping.postalCode),
                _buildShippingDetailRow("Country", shipping.country),
              ] else ...[
                const Text("No shipping details found"),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? "Not available"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<Vendor?, List<Item>> itemsByVendor = {};
    if (order.items != null) {
      for (var item in order.items!) {
        final vendor = vendorsForOrder[item.productId!];
        if (!itemsByVendor.containsKey(vendor)) {
          itemsByVendor[vendor] = [];
        }
        itemsByVendor[vendor]!.add(item);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor,
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.userName ?? 'Customer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Order #${order.orderId}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                      Text(
                        "Phone: ${order.userPhone ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                      Text(
                        "Email: ${order.userEmail ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      backgroundColor: _orderStatusColor(order.orderStatus),
                      label: Text(
                        _orderStatusText(order.orderStatus),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      backgroundColor: _shippingStatusColor(order.shippingStatus),
                      label: Text(
                        _shippingStatusText(order.shippingStatus),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.createdAt != null)
              Text(
                "Placed on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt!)}",
                style: const TextStyle(color: textSecondaryColor),
              ),
            const SizedBox(height: 12),
            ...itemsByVendor.entries.map((entry) {
              final vendor = entry.key;
              final items = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vendor != null)
                    Text(
                      "Vendor: ${vendor.storeName}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  const SizedBox(height: 8),
                  ...items.map((item) => _buildOrderItem(item)),
                  const SizedBox(height: 12),
                ],
              );
            }),
            const Divider(color: borderColor, height: 24),
            Text(
              "Order Total: Rs. ${order.totalPrice}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (order.orderStatus?.toLowerCase() != 'rejected' && 
                    order.orderStatus?.toLowerCase() != 'canceled') ...[
                  if (order.shippingStatus == 'Pending' || order.shippingStatus == 'Processing')
                    ElevatedButton(
                      onPressed: () => onUpdateStatus(order.orderId!, 'mark_shipped'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        'Order Received',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => _showShippingDetails(order.userId!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'Shipping Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (order.shippingStatus == 'Shipped')
                    ElevatedButton(
                      onPressed: () => onUpdateStatus(order.orderId!, 'mark_delivered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        'Order Delivered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ] else ...[
                  Text(
                    'Order ${order.orderStatus}',
                    style: TextStyle(
                      color: order.orderStatus?.toLowerCase() == 'rejected' 
                          ? Colors.red 
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Item item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "http://$ipAddress/silverskin-api${item.imageUrl ?? ''}",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
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
                Text(
                  item.productName ?? 'Unknown Product',
                  style: const TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text("Quantity: ", style: TextStyle(color: textSecondaryColor)),
                    Text(
                      "${item.quantity ?? 0}",
                      style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Price: ", style: TextStyle(color: textSecondaryColor)),
                    Text(
                      "Rs. ${item.price ?? 0}",
                      style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _orderStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'cod':
        return Colors.blue;
      case 'online paid':
        return Colors.green;
      case 'cash paid':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _orderStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'cod':
        return 'Cash on Delivery';
      case 'online paid':
        return 'Online Paid';
      case 'cash paid':
        return 'Cash Paid';
      case 'canceled':
        return 'Canceled';
      case 'rejected':
        return 'Rejected';
      default:
        return status ?? 'Payment Processing';
    }
  }

  Color _shippingStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _shippingStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      default:
        return status ?? 'Pending';
    }
  }
}