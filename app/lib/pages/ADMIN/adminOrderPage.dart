import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/order.dart';
import 'package:silverskin/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:silverskin/pages/ADMIN/Components/adminOrderCard.dart';
import 'dart:convert';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> 
    with SingleTickerProviderStateMixin {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<int, Vendor> _vendorCache = {};
  late TabController _tabController;
  final List<String> _statusTabs = [
    'Pending', 
    'Processing', 
    'Shipped', 
    'Delivered', 
    'Rejected', 
    'Canceled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/getAdminOrders.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _orders = (data['orders'] as List)
                .map((order) => Order.fromJson(order))
                .toList();
          });
          await _prefetchVendorDetails();
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

  Future<void> _prefetchVendorDetails() async {
    for (var order in _orders) {
      if (order.items == null) continue;
      
      for (var item in order.items!) {
        if (item.productId == null) continue;
        
        try {
          final response = await http.post(
            Uri.parse("http://$ipAddress/silverskin-api/getVendorByProduct.php"),
            body: {'product_id': item.productId.toString()},
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] && data['vendor'] != null) {
              _vendorCache[item.productId!] = Vendor.fromJson(data['vendor']);
            }
          }
        } catch (e) {
          print("Error fetching vendor for product ${item.productId}: $e");
        }
      }
    }
  }

  Future<void> _updateShippingStatus(int orderId, String action) async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/updateOrderStatus.php"),
        body: {
          'order_id': orderId.toString(),
          'action': action,
        },
      );

      final data = json.decode(response.body);
      if (data['success']) {
        await _fetchOrders();
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
          'Admin Orders',
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
      return const Center(child: CircularProgressIndicator(color: accentColor));
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
      onRefresh: _fetchOrders,
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
            onRefresh: () => _fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final vendorsForOrder = _vendorCache;
                
                return AdminOrderCard(
                  order: order,
                  vendorsForOrder: vendorsForOrder,
                  onUpdateStatus: _updateShippingStatus,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}