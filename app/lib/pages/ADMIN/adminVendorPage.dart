import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminVendorsPage extends StatefulWidget {
  const AdminVendorsPage({super.key});

  @override
  State<AdminVendorsPage> createState() => _AdminVendorsPageState();
}

class _AdminVendorsPageState extends State<AdminVendorsPage> {
  final GetDataController dataController = Get.find<GetDataController>();
  List<Vendor> _vendors = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0;
  final List<String> _tabs = ['Active Vendors', 'Pending Approval', 'Rejected Vendors'];

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/getVendors.php"),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _vendors = (data['vendors'] as List)
                .map((vendor) => Vendor.fromJson(vendor))
                .toList();
          });
        }
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error fetching vendors: ${e.toString()}",
        duration: const Duration(seconds: 2),
        backgroundColor: accentColor,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

Future<void> _updateVendorStatus(String vendorId, String status) async {
  try {
    print('Updating vendor $vendorId to status $status');
    
    final response = await http.post(
      Uri.parse("http://$ipAddress/silverskin-api/admin/updateVendorStatus.php"),
      body: json.encode({
        'vendor_id': vendorId,
        'status': status,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Check for empty response
    if (response.body.isEmpty) {
      throw Exception('Server returned empty response');
    }

    // Parse JSON
    final Map<String, dynamic> data;
    try {
      data = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid JSON response', response.body);
    }

    // Check response structure
    if (data.containsKey('success')) {
      if (data['success'] == true) {
        Get.showSnackbar(GetSnackBar(
          message: data['message'] ?? 'Status updated successfully',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ));
        await _fetchVendors(); // Refresh the list
      } else {
        throw Exception(data['message'] ?? 'Update failed');
      }
    } else {
      throw FormatException('Missing success field in response', response.body);
    }
  } on FormatException catch (e) {
    print('JSON Format Error: ${e.message}');
    print('Source: ${e.source}');
    Get.showSnackbar(const GetSnackBar(
      message: 'Server response format error',
      duration: Duration(seconds: 3),
      backgroundColor: Colors.orange,
    ));
  } catch (e) {
    print('Error updating vendor status: $e');
    Get.showSnackbar(GetSnackBar(
      message: 'Error: ${e.toString()}',
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
    ));
  }
}
  void _showDeleteConfirmation(Vendor vendor) {
    Get.defaultDialog(
      title: "Delete Vendor",
      middleText: "Are you sure you want to delete ${vendor.storeName}? This will also remove all their products and cannot be undone.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: textColor,
      onConfirm: () {
        Get.back();
        _deleteVendor(vendor.vendorId, vendor.userId!);
      },
      onCancel: () => Get.back(),
    );
  }

  Future<void> _deleteVendor(String vendorId, String userId) async {
    try {
      // First delete the vendor record
      final vendorResponse = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/deleteVendor.php"),
        body: json.encode({'vendor_id': vendorId}),
        headers: {'Content-Type': 'application/json'},
      );
      
      final vendorData = json.decode(vendorResponse.body);
      if (!vendorData['success']) {
        throw Exception(vendorData['message']);
      }

      // Then delete the user
      final userResponse = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/deleteUser.php"),
        body: json.encode({'user_id': userId}),
        headers: {'Content-Type': 'application/json'},
      );
      
      final userData = json.decode(userResponse.body);
      if (userData['success']) {
        Get.showSnackbar(const GetSnackBar(
          message: "Vendor deleted successfully",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ));
        _fetchVendors();
      } else {
        throw Exception(userData['message']);
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error deleting vendor: ${e.toString()}",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showVendorDetails(Vendor vendor) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: secondaryColor,
                  child: Icon(
                    Icons.store,
                    size: 40,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  vendor.storeName ?? 'Unknown Store',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Chip(
                  label: Text(
                    vendor.status?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _getStatusColor(vendor.status),
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: _getStatusColor(vendor.status).withOpacity(0.2),
                  side: BorderSide(color: _getStatusColor(vendor.status)),
                ),
              ),
              const SizedBox(height: 30),
              _buildDetailRow(Icons.person, "Owner", vendor.name ?? 'Not provided'),
              _buildDetailRow(Icons.email, "Email", vendor.email ?? 'Not provided'),
              _buildDetailRow(Icons.phone, "Phone", vendor.phone ?? 'Not provided'),
              _buildDetailRow(Icons.store, "Store Name", vendor.storeName ?? 'Not provided'),
              _buildDetailRow(Icons.description, "Description", vendor.storeDescription ?? 'Not provided'),
              _buildDetailRow(Icons.location_on, "Address", vendor.address ?? 'Not provided'),
              const SizedBox(height: 20),
              if (vendor.status == 'Waiting for Approval') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateVendorStatus(vendor.vendorId, 'Online'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateVendorStatus(vendor.vendorId, 'Rejected'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (vendor.status == 'Rejected') ...[
                ElevatedButton(
                  onPressed: () => _updateVendorStatus(vendor.vendorId, 'Waiting for Approval'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    'Move to Pending',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Center(
                child: TextButton(
                  onPressed: () => _showDeleteConfirmation(vendor),
                  child: const Text(
                    "Delete Vendor",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'waiting for approval':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: textSecondaryColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: label == "Description" || label == "Address" ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Vendor> get _filteredVendors {
    if (_searchController.text.isNotEmpty) {
      return _vendors.where((vendor) =>
        vendor.storeName?.toLowerCase().contains(_searchController.text.toLowerCase()) == true ||
        vendor.name?.toLowerCase().contains(_searchController.text.toLowerCase()) == true ||
        vendor.email?.toLowerCase().contains(_searchController.text.toLowerCase()) == true
      ).toList();
    }

    switch (_currentTabIndex) {
      case 0: // Active Vendors
        return _vendors.where((v) => v.status == 'Online').toList();
      case 1: // Pending Approval
        return _vendors.where((v) => v.status == 'Waiting for Approval').toList();
      case 2: // Rejected Vendors
        return _vendors.where((v) => v.status == 'Rejected').toList();
      default:
        return _vendors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Vendors',
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
            onPressed: _fetchVendors,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: gradientBackground,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: accentColor))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search vendors...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        filled: true,
                        fillColor: boxColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: _currentTabIndex == index 
                                  ? accentColor.withOpacity(0.2) 
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _currentTabIndex = index;
                              });
                            },
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: _currentTabIndex == index ? accentColor : textSecondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: accentColor,
                      onRefresh: _fetchVendors,
                      child: _filteredVendors.isEmpty
                          ? const Center(
                              child: Text(
                                "No vendors found",
                                style: TextStyle(color: textSecondaryColor),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredVendors.length,
                              itemBuilder: (context, index) {
                                final vendor = _filteredVendors[index];
                                return _buildVendorCard(vendor);
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: boxColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showVendorDetails(vendor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: secondaryColor,
                    child: Icon(
                      Icons.store,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.storeName ?? 'Unknown Store',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vendor.name ?? 'Unknown Owner',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      vendor.status?.toUpperCase() ?? 'UNKNOWN',
                      style: TextStyle(
                        color: _getStatusColor(vendor.status),
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getStatusColor(vendor.status).withOpacity(0.2),
                    side: BorderSide(color: _getStatusColor(vendor.status)),
                  ),
                ],
              ),
              if (_currentTabIndex == 1) // Pending Approval tab
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _updateVendorStatus(vendor.vendorId, 'Online'),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                          child: const Text(
                            'Approve',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _updateVendorStatus(vendor.vendorId, 'Rejected'),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_currentTabIndex == 2) // Rejected tab
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _updateVendorStatus(vendor.vendorId, 'Waiting for Approval'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: const Text(
                        'Move to Pending',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}