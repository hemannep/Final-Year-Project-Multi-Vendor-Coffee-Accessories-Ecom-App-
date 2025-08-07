import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VendorOrderPage extends StatefulWidget {
  const VendorOrderPage({super.key});

  @override
  _VendorOrderPageState createState() => _VendorOrderPageState();
}

class _VendorOrderPageState extends State<VendorOrderPage>
    with SingleTickerProviderStateMixin {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  final List<String> _statusTabs = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Canceled',
    'Rejected'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _fetchVendorOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendorOrders() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = int.tryParse(prefs.getString('vendor_id') ?? '') ??
          prefs.getInt('vendor_id');

      if (vendorId == null) {
        setState(() => _errorMessage = "Vendor not logged in");
        return;
      }

      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/vendorOrders.php"),
        body: {'vendor_id': vendorId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _orders = (data['orders'] as List)
                .map((order) => Order.fromJson(order))
                .toList();
            if (_orders.isEmpty) {
              _errorMessage = "No orders found";
            }
          });
        } else {
          setState(() => _errorMessage = data['message']);
        }
      } else {
        setState(() => _errorMessage = "Failed to load orders");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _dispatchOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = int.tryParse(prefs.getString('vendor_id') ?? '') ??
          prefs.getInt('vendor_id');

      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/vendorUpdateOrder.php"),
        body: {
          'vendor_id': vendorId.toString(),
          'order_id': orderId,
        },
      );

      final data = json.decode(response.body);
      if (data['success']) {
        await _fetchVendorOrders();
        Get.showSnackbar(GetSnackBar(
          message: data['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ));
      } else {
        Get.showSnackbar(GetSnackBar(
          message: data['message'],
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error: ${e.toString()}",
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = int.tryParse(prefs.getString('vendor_id') ?? '') ??
          prefs.getInt('vendor_id');

      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/vendorCancelOrder.php"),
        body: {
          'vendor_id': vendorId.toString(),
          'order_id': orderId,
        },
      );

      final data = json.decode(response.body);
      if (data['success']) {
        await _fetchVendorOrders();
        Get.showSnackbar(GetSnackBar(
          message: data['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ));
      } else {
        Get.showSnackbar(GetSnackBar(
          message: data['message'],
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error: ${e.toString()}",
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vendor Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: accentColor,
          unselectedLabelColor: textSecondaryColor,
          indicatorColor: accentColor,
          tabs: _statusTabs.map((status) => Tab(text: status)).toList(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: gradientBackground),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: textColor, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      color: accentColor,
      onRefresh: _fetchVendorOrders,
      child: TabBarView(
        controller: _tabController,
        children: _statusTabs.map((status) {
          final filteredOrders = _orders.where((order) {
            final orderStatus = order.orderStatus?.toLowerCase();
              
            // For Rejected and Canceled tabs, only show orders with matching order_status
            if (status.toLowerCase() == 'rejected') {
              return orderStatus == 'rejected';
            } else if (status.toLowerCase() == 'canceled') {
              return orderStatus == 'canceled';
            } 
            // For other tabs, only show orders with payment status (COD, Cash Paid, Online Paid)
            // and matching shipping status
            else {
              return (orderStatus == 'cod' || 
                      orderStatus == 'cash paid' || 
                      orderStatus == 'online paid') &&
                  order.shippingStatus?.toLowerCase() == status.toLowerCase();
            }
          }).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Text(
                'No $status orders',
                style: const TextStyle(color: textColor, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchVendorOrders,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return VendorOrderCard(
                  order: filteredOrders[index],
                  onDispatch: status == 'Pending' ? _dispatchOrder : null,
                  onCancel: status == 'Pending' ? _cancelOrder : null,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class VendorOrderCard extends StatelessWidget {
  final Order order;
  final Function(String)? onDispatch;
  final Function(String)? onCancel;

  const VendorOrderCard({
    super.key,
    required this.order,
    this.onDispatch,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final vendorTotal = order.items?.fold<double>(
          0.0,
          (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 0)),
        ) ??
        0.0;

    final isCanceled = order.orderStatus?.toLowerCase() == 'canceled';

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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      backgroundColor: _orderStatusColor(order.orderStatus),
                      label: Text(
                        _orderStatusText(order.orderStatus),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
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

            if (order.createdAt != null)
              Text(
                "Placed on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt!)}",
                style: const TextStyle(color: textSecondaryColor),
              ),

            const SizedBox(height: 12),

            if (order.items?.isNotEmpty ?? false)
              ...order.items!.map((item) => _buildOrderItem(item)),

            const Divider(color: borderColor, height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                

                if (!isCanceled) ...[
                  if (onCancel != null)
                    InkWell(
                      onTap: () => _showCancelConfirmation(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Reject Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (onDispatch != null)
                    InkWell(
                      onTap: () => onDispatch!(order.orderId.toString()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Dispatch",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
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

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Order"),
        content: const Text("Are you sure you want to reject this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call(order.orderId.toString());
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
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
                Text(
                  "Qty: ${item.quantity ?? 0} ",
                  style: const TextStyle(color: textSecondaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your Total: Rs. ${item.price?.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
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