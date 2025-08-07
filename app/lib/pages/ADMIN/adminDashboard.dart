import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/adminStats.dart';
import 'package:silverskin/models/order.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/models/vendor.dart';
import 'package:silverskin/pages/ADMIN/Components/recentOrders.dart';
import 'package:silverskin/pages/ADMIN/Components/topPerformingVendors.dart';
import 'package:silverskin/pages/ADMIN/Components/topSellingProducts.dart';
import 'package:silverskin/pages/ADMIN/adminOrderPage.dart';
import 'package:silverskin/pages/ADMIN/adminProductPage.dart';
import 'package:silverskin/pages/ADMIN/adminUserPage.dart';
import 'package:silverskin/pages/ADMIN/adminVendorPage.dart';
import 'package:http/http.dart' as http;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GetDataController dataController = Get.find<GetDataController>();
  bool _isLoading = true;
  List<Order> _recentOrders = [];
  List<Product> _topProducts = [];
  List<Vendor> _topVendors = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        dataController.getAdminStats(),
        _fetchRecentOrders(),
        _fetchTopProducts(),
        _fetchTopVendors(),
      ]);
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error loading data: ${e.toString()}",
        duration: const Duration(seconds: 2),
        backgroundColor: accentColor,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRecentOrders() async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/getRecentOrders.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _recentOrders = (data['orders'] as List)
                .map((order) => Order.fromJson(order))
                .toList();
          });
        }
      }
    } catch (e) {
      print("Error fetching recent orders: $e");
    }
  }

  Future<void> _fetchTopProducts() async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/getTopProducts.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _topProducts = (data['products'] as List)
                .map((product) => Product.fromJson(product))
                .toList();
          });
        }
      }
    } catch (e) {
      print("Error fetching top products: $e");
    }
  }

  Future<void> _fetchTopVendors() async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/getTopVendors.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _topVendors = (data['vendors'] as List)
                .map((vendor) => Vendor.fromJson(vendor))
                .toList();
          });
        }
      }
    } catch (e) {
      print("Error fetching top vendors: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: accentColor),
            onPressed: _loadAdminData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: gradientBackground,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: accentColor))
            : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final stats = dataController.adminStatsResponse?.stats ?? [];

    return RefreshIndicator(
      color: accentColor,
      onRefresh: _loadAdminData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Stats Row 1
            Row(
              children: [
                _buildStatCard(stats[0],
                    icon: Icons.people_outline, iconColor: Colors.blue[400]),
                const SizedBox(width: 16),
                _buildStatCard(stats[1],
                    icon: Icons.store_outlined, iconColor: Colors.orange[400]),
              ],
            ),
            const SizedBox(height: 16),

            // Summary Stats Row 2
            Row(
              children: [
                _buildStatCard(stats[2],
                    icon: Icons.shopping_cart_outlined,
                    iconColor: Colors.green[400]),
                const SizedBox(width: 16),
                _buildStatCard(stats[3],
                    icon: Icons.attach_money_outlined,
                    iconColor: Colors.purple[400]),
              ],
            ),
            const SizedBox(height: 16),

            // Lifetime Stats Row
            Row(
              children: [
                _buildStatCard(stats[4],
                    icon: Icons.history_outlined, iconColor: Colors.teal[400]),
                const SizedBox(width: 16),
                _buildStatCard(stats[5],
                    icon: Icons.monetization_on_outlined,
                    iconColor: Colors.red[400]),
              ],
            ),
            const SizedBox(height: 24),

            // Top Selling Section
            _buildSectionTitle("Top Selling Products"),
            TopSellingProducts(products: _topProducts),
            const SizedBox(height: 24),

            // Top Vendors Section
            _buildSectionTitle("Top Performing Vendors"),
            TopPerformingVendors(vendors: _topVendors),
            const SizedBox(height: 24),

            // Recent Orders Section
            _buildSectionTitle("Recent Orders"),
            RecentOrders(orders: _recentOrders),
            const SizedBox(height: 24),

            // Quick Actions
            _buildSectionTitle("Quick Actions"),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(AdminStat stat,
      {IconData? icon, Color? iconColor, bool isCurrency = false}) {
    return Expanded(
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? accentColor, size: 28),
                const Spacer(),
                if (stat.change != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (stat.change ?? 0) >= 0
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (stat.change ?? 0) >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 16,
                          color: (stat.change ?? 0) >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${stat.change?.abs()}%",
                          style: TextStyle(
                            fontSize: 12,
                            color: (stat.change ?? 0) >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isCurrency ? 'Rs. ${stat.value ?? '0'}' : stat.value ?? '0',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
              ),
            ),
            if (stat.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                stat.subtitle ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionButton(
          icon: Icons.shopping_bag_outlined,
          label: "Manage Orders",
          onTap: () => Get.to(() => const AdminOrdersPage()),
        ),
        _buildActionButton(
          icon: Icons.people_outline,
          label: "Manage Users",
          onTap: () => Get.to(() => const AdminUsersPage()),
        ),
        _buildActionButton(
          icon: Icons.store_outlined,
          label: "Manage Vendors",
          onTap: () => Get.to(() => const AdminVendorsPage()),
        ),
        _buildActionButton(
          icon: Icons.shopping_bag_outlined,
          label: "Manage Products",
          onTap: () => Get.to(() => const AdminProductsPage()),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: accentColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
