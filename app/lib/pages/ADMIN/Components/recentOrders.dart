import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/order.dart';

class RecentOrders extends StatelessWidget {
  final List<Order> orders;
  
  const RecentOrders({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text("No recent orders found", style: TextStyle(color: textSecondaryColor)));
    }
    
    return Column(
      children: orders.take(3).map((order) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, color: accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${order.orderId}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Status: ${order.orderStatus}",
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(order.orderStatus),
                    ),
                  ),
                  Text(
                    "Rs. ${order.totalPrice}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textSecondaryColor),
          ],
        ),
      )).toList(),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'cod':
        return Colors.blue;
      case 'Online Paid':
        return Colors.green;
      case 'Cash Paid':
        return Colors.orange;
      case 'Cancled':
        return Colors.red;
          default:
        return Colors.grey;
    }
  }
}