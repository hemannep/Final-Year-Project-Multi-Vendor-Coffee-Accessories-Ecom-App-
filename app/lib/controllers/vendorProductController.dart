import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/constant.dart';

class VendorProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVendorProducts();
  }
Future<void> fetchVendorProducts() async {
  try {
    isLoading(true);
    errorMessage('');
    
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendor_id');
    
    if (vendorId == null) {
      errorMessage('Vendor not logged in');
      return;
    }

    final response = await http.post(
      Uri.parse('http://$ipAddress/silverskin-api/getVendorProducts.php'),
      body: {'vendor_id': vendorId.toString()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        products.assignAll(
          (data['products'] as List).map((item) => Product.fromJson(item)).toList(),
        );
      } else {
        errorMessage(data['message'] ?? 'Failed to load products');
      }
    } else {
      errorMessage('Server error: ${response.statusCode}');
    }
  } catch (e) {
    errorMessage('Failed to fetch products: ${e.toString()}');
    print('Error details: $e');
  } finally {
    isLoading(false);
  }
}
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/deleteProduct.php'),
        body: {'product_id': productId},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        products.removeWhere((p) => p.product_id == productId);
        return true;
      } else {
        errorMessage(data['message'] ?? 'Failed to delete product');
        return false;
      }
    } catch (e) {
      errorMessage('Failed to delete product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/updateProduct.php'),
        body: updatedProduct.toJson(),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final index = products.indexWhere((p) => p.product_id == updatedProduct.product_id);
        if (index != -1) {
          products[index] = updatedProduct;
        }
        return true;
      } else {
        errorMessage(data['message'] ?? 'Failed to update product');
        return false;
      }
    } catch (e) {
      errorMessage('Failed to update product: $e');
      return false;
    }
  }
}