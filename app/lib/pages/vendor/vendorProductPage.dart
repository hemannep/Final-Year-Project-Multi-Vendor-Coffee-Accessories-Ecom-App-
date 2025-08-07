import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverskin/pages/vendor/Components/vendorProductCard.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/pages/vendor/addProduct.dart';
import 'package:http/http.dart' as http;

class VendorProductPage extends StatefulWidget {
  const VendorProductPage({super.key});

  @override
  State<VendorProductPage> createState() => _VendorProductPageState();
}

class _VendorProductPageState extends State<VendorProductPage> {
  final GetDataController _dataController = Get.find<GetDataController>();
  List<Product> _vendorProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVendorProducts();
  }

  Future<void> _loadVendorProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getString('vendor_id');

      if (vendorId == null || vendorId.isEmpty) {
        throw Exception('Vendor not logged in');
      }

      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/getVendorProducts.php'),
        body: {'vendor_id': vendorId},
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _vendorProducts = (data['products'] as List)
              .map((product) => Product.fromJson(product))
              .toList();
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _deleteProduct(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/deleteProduct.php'),
        body: {'product_id': productId},
      );

      final result = json.decode(response.body);
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/updateProduct.php'),
        body: {
          'product_id': product.product_id ?? '',
          'product_name': product.productName ?? '',
          'product_description': product.productDescription ?? '',
          'price': product.price ?? '0',
          'stock': product.stock ?? '0',
          'category_id': product.categoryId ?? '1',
        },
      );

      final result = json.decode(response.body);
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateProductStatus(String productId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/updateProductStatus.php'),
        body: {
          'product_id': productId,
          'status': status,
        },
      );

      final result = json.decode(response.body);
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Products',
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
            icon: const Icon(Icons.add, color: accentColor),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final vendorId = prefs.getString('vendor_id') ?? '';
              await Get.to(() => AddProductPage(vendor_id: vendorId));
              _loadVendorProducts();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: accentColor),
            onPressed: _loadVendorProducts,
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
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_vendorProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory, size: 64, color: textSecondaryColor),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final vendorId = prefs.getString('vendor_id') ?? '';
                  await Get.to(() => AddProductPage(vendor_id: vendorId));
                  _loadVendorProducts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ADD YOUR FIRST PRODUCT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: accentColor,
      onRefresh: _loadVendorProducts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _vendorProducts.length,
        itemBuilder: (context, index) {
          final product = _vendorProducts[index];
          return VendorProductCard(
            product: product,
            onDelete: () async {
              final success = await _deleteProduct(product.product_id ?? '');
              if (success) {
                setState(() {
                  _vendorProducts.removeAt(index);
                });
                Get.snackbar(
                  'Success',
                  'Product deleted successfully',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete product',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            onUpdate: (updatedProduct) async {
              final success = await _updateProduct(updatedProduct);
              if (success) {
                setState(() {
                  _vendorProducts[index] = updatedProduct;
                });
                Get.snackbar(
                  'Success',
                  'Product updated successfully',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to update product',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            onStatusChanged: (String status) async {
              final success = await _updateProductStatus(product.product_id ?? '', status);
              if (success) {
                _loadVendorProducts();
                Get.snackbar(
                  'Success',
                  'Product status updated',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to update status',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
          );
        },
      ),
    );
  }
}