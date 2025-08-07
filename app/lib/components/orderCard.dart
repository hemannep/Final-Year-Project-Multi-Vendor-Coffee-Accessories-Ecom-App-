import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:silverskin/components/orderConfirmation.dart';
import 'package:silverskin/components/receiptComponent.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/order.dart';
import 'package:silverskin/pages/users/reviewPage.dart';
import 'package:silverskin/pages/users/shippingPage.dart';


class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onCancel;
  final VoidCallback? onRefresh;

  const OrderCard({
    super.key,
    required this.order,
    this.onCancel,
    this.onRefresh,
  });
  
  get http => null;

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cod':
        return Colors.blue;
      case 'online paid':
      case 'cash paid':
        return Colors.green;
      case 'payment due':
        return Colors.orange;
      case 'canceled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'cod':
        return 'Cash on Delivery';
      case 'online paid':
        return 'Online Paid';
      case 'cash paid':
        return 'Cash Paid';
      case 'payment due':
        return 'Payment Due';
      case 'canceled':
        return 'Canceled';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getShippingStatusColor(String? status) {
    if (status == null) return Colors.transparent;
    
    switch (status.toLowerCase()) {
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

  String _getShippingStatusText(String? status) {
    if (status == null) return '';
    
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Widget _buildOrderItem(Item item, bool isDelivered, int orderId) {
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'http://$ipAddress/silverskin-api${item.imageUrl ?? ''}',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: secondaryColor,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                  ),
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
                    style: const TextStyle(fontSize: 16, color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${item.quantity ?? 0}',
                    style: const TextStyle(color: textSecondaryColor),
                  ),
                  Text(
                    'Total Cost: Rs. ${item.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: textSecondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isDelivered && item.productId != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Get.to(() => ReviewPage(
                      productId: item.productId!,
                      productName: item.productName ?? 'Product',
                      orderId: orderId,
                      imageUrl: item.imageUrl ?? '',
                    ));
              },
              child: const Text('Rate & Review', style: TextStyle(color: accentColor)),
            ),
          ),
      ],
    );
  }

  Future<void> _updatePaymentStatus() async {
    showOrderConfirmationDialog(Get.context!, (paymentMethod) async {
      if (paymentMethod == "COD") {
        // Update order status to COD
        await _updateOrderStatus('COD');
      } else if (paymentMethod == "Online") {
        // Process online payment
        await _processOnlinePayment();
      }
    });
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/updateOrderStatus.php'),
        body: {
          'order_id': order.orderId.toString(),
          'new_status': newStatus,
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        onRefresh?.call();
        Get.showSnackbar(const GetSnackBar(
          message: 'Order status updated successfully',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(result['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Error: ${e.toString()}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _processOnlinePayment() async {
    final controller = Get.find<GetDataController>();
    final config = PaymentConfig(
      amount: (order.totalPrice ?? 0) * 100,
      productIdentity: order.orderId.toString(),
      productName: "Silver Skin Order #${order.orderId}",
    );

    KhaltiScope.of(Get.context!).pay(
      config: config,
      onSuccess: (value) async {
        await _updateOrderStatus('Online Paid');
        await controller.getOrders();
      },
      onFailure: (value) {
        Get.showSnackbar(GetSnackBar(
          message: 'Payment failed: ${value.message}',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus?.toLowerCase() ?? '';
    final shipping = order.shippingStatus?.toLowerCase();
    final isPaymentDue = status == 'payment due';
    final isDelivered = shipping == 'delivered';

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      backgroundColor: _getOrderStatusColor(status),
                      label: Text(
                        _getOrderStatusText(status),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (!isPaymentDue && shipping != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        backgroundColor: _getShippingStatusColor(shipping),
                        label: Text(
                          _getShippingStatusText(shipping),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Order date
            if (order.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Placed on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt!)}',
                style: const TextStyle(color: textSecondaryColor),
              ),
            ],

            const SizedBox(height: 12),

            // List of items
            if (order.items != null && order.items!.isNotEmpty) ...[
              for (final item in order.items!)
                _buildOrderItem(
                  item,
                  isDelivered,
                  int.tryParse(order.orderId?.toString() ?? '') ?? 0,
                ),
            ],

            const Divider(color: borderColor, height: 24),

            // Total and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rs. ${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    // Details button
                    if (!isPaymentDue) ...[
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ShippingPage()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Details', 
                              style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],

                    // Cancel button (for Payment Due and COD)
                    if (isPaymentDue || status == 'cod') ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showCancelDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],

                    // Update Payment button (for Payment Due only)
                    if (isPaymentDue) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _updatePaymentStatus,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Pay Now',
                              style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],

                    // Receipt button (for paid orders)
                    if (!isPaymentDue && (status == 'cash paid' || status == 'online paid')) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => ReceiptComponent.generateReceipt(order),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Receipt',
                              style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (onCancel != null) {
                onCancel!();
              }
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}