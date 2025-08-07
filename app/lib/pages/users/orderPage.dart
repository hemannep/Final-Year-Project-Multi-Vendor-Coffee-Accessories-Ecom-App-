import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/components/orderCard.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  final GetDataController _controller = Get.find<GetDataController>();
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  // Tabs
  final List<String> _statusTabs = [

    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Canceled',
    'Rejected',
  ];

  // Only these orderStatus values are valid
  static const List<String> _allowedOrderStatuses = [
    'cod',
    'online paid',
    'cash paid',
    'canceled',
    'rejected',
    'payment due',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      await _controller.getOrders();
      final all = _controller.orderResponse?.orders;
      if (all == null || all.isEmpty) {
        _errorMessage = "You haven't placed any orders yet";
      }
    } catch (e) {
      _errorMessage = "Failed to load orders: ${e.toString()}";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: accentColor,
          unselectedLabelColor: textSecondaryColor,
          indicatorColor: accentColor,
          tabs: _statusTabs.map((s) => Tab(text: s)).toList(),
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

    // 1) Grab and pre‑filter fetched orders by allowed orderStatus
    final allOrders = _controller.orderResponse?.orders ?? [];
    final allowedOrders = allOrders.where((order) {
      final os = order.orderStatus?.toLowerCase() ?? '';
      return _allowedOrderStatuses.contains(os);
    }).toList();

    return RefreshIndicator(
      color: accentColor,
      onRefresh: _loadOrders,
      child: TabBarView(
        controller: _tabController,
        children: _statusTabs.map((status) {
          final key = status.toLowerCase();
          List ordersForTab;

          if (key == 'all') {
            // All except canceled & rejected
            ordersForTab = allowedOrders.where((o) {
              final os = o.orderStatus?.toLowerCase() ?? '';
              return os != 'canceled' && os != 'rejected';
            }).toList();

          } else if (['pending', 'processing', 'shipped', 'delivered'].contains(key)) {
            // shipping-status tabs, exclude canceled & rejected
            ordersForTab = allowedOrders.where((o) {
              final ship = o.shippingStatus?.toLowerCase() ?? '';
              final os   = o.orderStatus?.toLowerCase()    ?? '';
              return ship == key && os != 'canceled' && os != 'rejected';
            }).toList();

          } else if (key == 'canceled') {
            // only canceled orders
            ordersForTab = allowedOrders.where((o) =>
              o.orderStatus?.toLowerCase() == 'canceled'
            ).toList();

          } else if (key == 'rejected') {
            // only rejected orders
            ordersForTab = allowedOrders.where((o) =>
              o.orderStatus?.toLowerCase() == 'rejected'
            ).toList();

          } else {
            ordersForTab = [];
          }

          if (ordersForTab.isEmpty) {
            return Center(
              child: Text(
                'No $status orders',
                style: const TextStyle(color: textColor, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: ordersForTab.length,
              itemBuilder: (ctx, i) {
                final ord = ordersForTab[i];
                return OrderCard(
                  order: ord,
                  onCancel: () async {
                    final success = await _controller.cancelOrder(ord.orderId!);
                    if (success) await _loadOrders();
                  },
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
