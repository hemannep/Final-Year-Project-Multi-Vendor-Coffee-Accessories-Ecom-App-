import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/pages/ADMIN/Components/addCategoryDialog';
import 'package:silverskin/pages/ADMIN/Components/adminProductCard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0;
  final List<String> _tabs = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress/silverskin-api/admin/getProducts.php'),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned status code ${response.statusCode}');
      }

      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse['success'] != true) {
        throw Exception(decodedResponse['message'] ?? 'Failed to load products');
      }

      setState(() {
        _products = (decodedResponse['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products. Please try again.';
        if (e is FormatException) {
          _errorMessage = 'Invalid server response format';
        }
      });
      debugPrint('Error loading products: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _updateProductStatus(String productId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/admin/updateProductStatus.php'),
        body: {
          'product_id': productId,
          'status': status,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to update status');
      }

      // Success snackbar from top, green background
      Get.snackbar(
        'Success',
        result['message'] ?? 'Status updated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      // Error snackbar from top, red background
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      debugPrint('Error updating product status: $e');
      return false;
    }
  }

  Future<bool> _deleteProduct(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/admin/deleteProduct.php'),
        body: {'product_id': productId},
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to delete product');
      }

      // Success snackbar from top, green background
      Get.snackbar(
        'Success',
        result['message'] ?? 'Product deleted',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      // Error snackbar from top, red background
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  List<Product> get _filteredProducts {
    final searchTerm = _searchController.text.toLowerCase();
    List<Product> filtered = _products;

    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((p) =>
          (p.productName?.toLowerCase().contains(searchTerm) ?? false) ||
          (p.categoryTitle?.toLowerCase().contains(searchTerm) ?? false) ||
          (p.vendor_id?.contains(searchTerm) ?? false) ||
          (p.productDescription?.toLowerCase().contains(searchTerm) ?? false)
      ).toList();
    }

    switch (_currentTabIndex) {
      case 1:
        return filtered.where((p) => p.onlineStatus?.toLowerCase() == 'private').toList();
      case 2:
        return filtered.where((p) => p.onlineStatus?.toLowerCase() == 'public').toList();
      case 3:
        return filtered.where((p) => p.onlineStatus?.toLowerCase() == 'rejected').toList();
      default:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Products',
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
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: textSecondaryColor),
                  prefixIcon: const Icon(Icons.search, color: accentColor),
                  filled: true,
                  fillColor: primaryColor.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(color: textColor),
                onChanged: (_) => setState(() {}),
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
                    child: ChoiceChip(
                      label: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: _currentTabIndex == index ? Colors.white : textColor,
                        ),
                      ),
                      selected: _currentTabIndex == index,
                      onSelected: (selected) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      },
                      selectedColor: accentColor,
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: borderColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildProductList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory, size: 64, color: textSecondaryColor),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No products found'
                  : 'No matching products',
              style: const TextStyle(fontSize: 18, color: textColor),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: accentColor,
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return AdminProductCard(
            product: product,
            onDelete: () async {
              final success = await _deleteProduct(product.product_id ?? '');
              if (success) _loadProducts();
            },
            onStatusChanged: (productId, status) async {
              final success = await _updateProductStatus(productId, status);
              if (success) _loadProducts();
            },
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    ).then((_) => _loadProducts());
  }
}
