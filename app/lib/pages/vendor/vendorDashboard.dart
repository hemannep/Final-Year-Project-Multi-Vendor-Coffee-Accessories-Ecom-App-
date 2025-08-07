import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/stats.dart';
import 'package:silverskin/pages/users/changePassword.dart';
import 'package:silverskin/pages/vendor/addProduct.dart';
import 'package:silverskin/pages/vendor/updateVendor.dart';
import 'package:silverskin/pages/vendor/vendorOrderPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  final GetDataController dataController = Get.find<GetDataController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorStats();
  }

  Future<void> _loadVendorStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorIdString = prefs.getString('vendor_id');
      final vendorId =
          vendorIdString != null ? int.tryParse(vendorIdString) : null;

      if (vendorId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: "Vendor not logged in",
          duration: Duration(seconds: 2),
          backgroundColor: accentColor,
        ));
        return;
      }

      await dataController.getVendorStats(vendorId.toString());
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error loading stats: ${e.toString()}",
        duration: const Duration(seconds: 2),
        backgroundColor: accentColor,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vendor Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
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
    final stats = dataController.statsResponse?.stats ?? [];

    if (stats.isEmpty) {
      return const Center(
        child: Text(
          "No statistics available",
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      color: accentColor,
      onRefresh: _loadVendorStats,
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(Get.context!).size.height,
          decoration: const BoxDecoration(
            gradient: gradientBackground,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main Stats Row
              Row(
                children: [
                  _buildStatCard(stats[0],
                      icon: Icons.coffee_maker_outlined,
                      iconColor: Colors.orange[400]),
                  const SizedBox(width: 16),
                  _buildStatCard(stats[1],
                      icon: Icons.currency_rupee,
                      iconColor: Colors.green[400],
                      isCurrency: true),
                ],
              ),
              const SizedBox(height: 16),

              // Secondary Stats Row
              Row(
                children: [
                  _buildStatCard(stats[2],
                      icon: Icons.trending_up, iconColor: Colors.blue[400]),
                  const SizedBox(width: 16),
                  _buildStatCard(stats[3],
                      icon: Icons.pending_actions,
                      iconColor: Colors.purple[400]),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              // Quick Actions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 22, // Increased font size for the title
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height: 20), // Increased space between title and actions
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 20, // Increased horizontal spacing
                mainAxisSpacing: 20, // Increased vertical spacing
                childAspectRatio:
                    1.5, // Slightly bigger aspect ratio for larger buttons
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActionButton(
                    icon: Icons.add,
                    label: "Add Product",
                    onPressed: () =>
                        Get.to(() => const AddProductPage(vendor_id: '')),
                  ),
                  _buildActionButton(
                    icon: Icons.list_alt,
                    label: "View Orders",
                    onPressed: () => Get.to(() => const VendorOrderPage()),
                  ),
                  _buildActionButton(
                    icon: Icons.shopping_bag_outlined,
                    label: "Update Store",
                    onPressed: () => Get.to(() =>  const UpdateVendor()),
                  ),
                  _buildActionButton(
                    icon: Icons.password,
                    label: "Change Password",
                    onPressed: () => Get.to(() => const ChangePasswordPage(
                          user_id: '',
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(Stat stat,
      {required IconData icon, Color? iconColor, bool isCurrency = false}) {
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor ?? accentColor, size: 28),
              const SizedBox(height: 16),
              Text(
                isCurrency ? stat.value ?? '0' : stat.value ?? '0',
                style: const TextStyle(
                  fontSize: 24,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
