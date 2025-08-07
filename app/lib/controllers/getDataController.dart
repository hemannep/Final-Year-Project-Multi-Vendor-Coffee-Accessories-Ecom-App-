import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/adminStats.dart';
import 'package:silverskin/models/category.dart';
import 'package:silverskin/models/order.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/models/review.dart';
import 'package:silverskin/models/shipping.dart';
import 'package:silverskin/models/stats.dart';
import 'package:silverskin/models/users.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:silverskin/models/vendor.dart';
import 'package:silverskin/pages/users/orderPage.dart';
import 'package:silverskin/providers/cartProvider.dart';

class GetDataController extends GetxController {
  
  CategoriesResponse? categoriesResponse;
  ProductResponse? productResponse;
  final Rx<OrderResponse?> _orderResponse = Rx<OrderResponse?>(null);
  OrderResponse? get orderResponse => _orderResponse.value;
  UserResponse? userResponse;
  VendorStatResponse? statsResponse;
  Vendor? vendorResponse;
  AdminStatResponse? adminStatsResponse;

  var wishlist = <Product>[].obs;
  final RxList<Datum> shippingDetails = <Datum>[].obs;
  final RxList<Vendor> vendors = <Vendor>[].obs;

  @override
  onInit() {
    super.onInit();
    getCategories();
    getProduct();
    getOrders();
    getMyDetails();
    getVendorStats(vendors.toString());
    fetchWishlist();
    fetchVendors();
  }

  void updateData() {
    update();
  }

  Future<void> createOrder({bool isCod = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final selectedShippingId = prefs.getInt("selected_shipping_id");
    final cartProvider = Provider.of<Cartprovider>(Get.context!, listen: false);

    try {
      var response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/createOrder.php'),
        body: {
          "user_id": userId.toString(),
          "total_price": cartProvider.totalPrice.toString(),
          "cart": jsonEncode(cartProvider.cartItems),
          "is_cod": isCod ? "1" : "0",
          if (selectedShippingId != null)
            "shipping_id": selectedShippingId.toString(),
        },
      );

      var result = jsonDecode(response.body);
      if (result['success']) {
        if (!isCod) {
          makePayment(result['order_id'].toString());
        } else {
          cartProvider.clearCart();
          getOrders();
          update();
          Get.showSnackbar(const GetSnackBar(
            message: "Order placed successfully!",
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            snackPosition: SnackPosition.TOP,
          ));
          Get.to(() => const OrderPage());
        }
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: "Failed to create order. Please try again.",
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  void makePayment(String orderId) async {
    final cartProvider = Provider.of<Cartprovider>(Get.context!, listen: false);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getInt("user_id").toString();

      var config = PaymentConfig(
          amount: cartProvider.totalPrice * 100,
          productIdentity: orderId,
          productName: "Silver Skin Order #$orderId");

      KhaltiScope.of(Get.context!).pay(
        config: config,
        onSuccess: (value) async {
          var response = await http.post(
            Uri.parse('http://$ipAddress/silverskin-api/makePayment.php'),
            body: {
              "user_id": userId,
              "order_id": orderId,
              "amount": (value.amount / 100).toString(),
              "other_details": value.toString(),
            },
          );

          var result = jsonDecode(response.body);
          if (result['success']) {
            cartProvider.clearCart();
            getOrders();
            update();
            Get.showSnackbar(const GetSnackBar(
              message: "Payment successful! Order completed.",
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              snackPosition: SnackPosition.TOP,
            ));
            Get.to(() => const OrderPage());
          } else {
            Get.showSnackbar(GetSnackBar(
              message: result['message'],
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              snackPosition: SnackPosition.TOP,
            ));
          }
        },
        onFailure: (value) {
          Get.showSnackbar(GetSnackBar(
            message: "Payment failed: ${value.message}",
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            snackPosition: SnackPosition.TOP,
          ));
        },
      );
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: "Payment processing error",
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/showOrders.php'),
        body: {'user_id': userId.toString()},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is! Map<String, dynamic>) {
          throw const FormatException('Invalid response format');
        }

        final result = OrderResponse.fromJson(jsonData);

        if (result.success != true) {
          throw Exception(result.message ?? 'Failed to load orders');
        }

        _orderResponse.value = result;
      } else {
        throw HttpException('Server error: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      _orderResponse.value = null;
      Get.showSnackbar(GetSnackBar(
        message: 'Data error: ${e.message}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    } on TimeoutException catch (_) {
      _orderResponse.value = null;
      Get.showSnackbar(const GetSnackBar(
        message: 'Request timed out',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    } on HttpException catch (e) {
      _orderResponse.value = null;
      Get.showSnackbar(GetSnackBar(
        message: e.message,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    } on Exception catch (e) {
      _orderResponse.value = null;
      Get.showSnackbar(GetSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> getVendorStats(String vendorId) async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/getVendorStats.php"),
        body: {'vendor_id': vendorId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          statsResponse = VendorStatResponse.fromJson(data);
          update();
        } else {
          throw Exception(data['message'] ?? 'Failed to load vendor stats');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Error loading stats: ${e.toString()}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> getProduct() async {
    try {
      var response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/getProducts.php",
        ),
      );

      var result = productResponseFromJson(response.body);

      if (result.success ?? false) {
        productResponse = result;
        update();
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result.message,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: 'Failed to load products',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
      print(e);
    }
  }

  Future<void> getMyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
          Uri(
            scheme: "http",
            host: ipAddress,
            path: "/silverskin-api/getMyDetails.php",
          ),
          body: {"user_id": prefs.getInt("user_id").toString()});

      var result = userResponseFromJson(response.body);

      if (result.success ?? false) {
        userResponse = result;
        update();
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result.message,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: 'Failed to load user details',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
      print(e);
    }
  }

  Future<void> getCategories() async {
    try {
      var response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/getCategories.php",
        ),
      );

      var result = categoriesResponseFromJson(response.body);
      if (result.success ?? false) {
        categoriesResponse = result;
        update();
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result.message,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: 'Failed to load categories',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
      print(e);
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: "User not logged in",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ));
        return false;
      }

      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/cancelOrder.php'),
        body: {
          'order_id': orderId.toString(),
          'user_id': userId.toString(),
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        return true;
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'] ?? "Failed to cancel order",
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "Error cancelling order: ${e.toString()}",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ));
      return false;
    }
  }

  Future<void> fetchWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt("user_id");

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: "User not logged in.",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      var response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/getWishlist.php",
        ),
        body: {
          "user_id": userId.toString(),
        },
      );

      var result = jsonDecode(response.body);

      if (result['success'] == true) {
        wishlist.assignAll((result['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList());
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: "Failed to fetch wishlist. Please try again.",
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> addWishlist(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt("user_id");

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: "User not logged in.",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      var response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/addWishlist.php",
        ),
        body: {
          "user_id": userId.toString(),
          "product_id": productId.toString(),
        },
      );

      var result = jsonDecode(response.body);

      if (result['success'] == true) {
        await fetchWishlist();
        Get.showSnackbar(GetSnackBar(
          message: result['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: "Failed to add to wishlist. Please try again.",
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt("user_id");

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: "User not logged in.",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      var response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/removeWishlist.php",
        ),
        body: {
          "user_id": userId.toString(),
          "product_id": productId,
        },
      );

      var result = jsonDecode(response.body);

      if (result['success'] == true) {
        wishlist.removeWhere((product) => product.product_id == productId);
        Get.showSnackbar(GetSnackBar(
          message: result['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'],
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: "Failed to remove from wishlist. Please try again.",
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> fetchShippingDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: 'User not logged in',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/getShipping.php'),
        body: {'user_id': userId.toString()},
      );

      if (response.statusCode == 200) {
        final result = ShippingResponse.fromJson(jsonDecode(response.body));
        if (result.success == true) {
          shippingDetails.assignAll(result.data ?? []);
        } else {
          Get.showSnackbar(GetSnackBar(
            message: result.message ?? 'Failed to fetch shipping details',
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            snackPosition: SnackPosition.TOP,
          ));
        }
      } else {
        Get.showSnackbar(GetSnackBar(
          message: 'Server error: ${response.statusCode}',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Failed to load shipping details: ${e.toString()}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> addShippingDetails({
    required String address,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: 'User not logged in',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      if (shippingDetails.length >= 3) {
        Get.showSnackbar(const GetSnackBar(
          message: 'Maximum 3 shipping addresses allowed',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/createShipping.php'),
        body: {
          'user_id': userId.toString(),
          'address': address,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        await fetchShippingDetails();
        Get.showSnackbar(const GetSnackBar(
          message: 'Shipping address added successfully',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'] ?? 'Failed to add shipping address',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Failed to add shipping address: ${e.toString()}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> updateShippingDetails({
    required int shippingId,
    required String address,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: 'User not logged in',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/updateShipping.php'),
        body: {
          'shipping_id': shippingId.toString(),
          'user_id': userId.toString(),
          'address': address,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        await fetchShippingDetails();
        Get.showSnackbar(const GetSnackBar(
          message: 'Shipping address updated successfully',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'] ?? 'Failed to update shipping address',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Failed to update shipping address: ${e.toString()}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> deleteShippingDetails(int shippingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        Get.showSnackbar(const GetSnackBar(
          message: 'User not logged in',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }

      final response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/deleteShipping.php'),
        body: {
          'shipping_id': shippingId.toString(),
          'user_id': userId.toString(),
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        await fetchShippingDetails();
        Get.showSnackbar(const GetSnackBar(
          message: 'Shipping address deleted successfully',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      } else {
        Get.showSnackbar(GetSnackBar(
          message: result['message'] ?? 'Failed to delete shipping address',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Failed to delete shipping address: ${e.toString()}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<void> fetchVendors() async {
    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress/silverskin-api/getVendors.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          vendors.assignAll(
            (data['vendors'] as List)
                .map((vendorJson) => Vendor.fromJson(vendorJson))
                .toList(),
          );
        } else {
          Get.showSnackbar(GetSnackBar(
            message: data['message'] ?? 'Failed to fetch vendors',
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            snackPosition: SnackPosition.TOP,
          ));
        }
      } else {
        Get.showSnackbar(GetSnackBar(
          message:
              'Failed to fetch vendors, status code: ${response.statusCode}',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          snackPosition: SnackPosition.TOP,
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Error fetching vendors: $e',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<String> fetchVendorName(String vendorId) async {
    if (vendorId.isEmpty) return "Vendor Information";

    try {
      final dataController = Get.find<GetDataController>();
      final existingVendor = dataController.vendors.firstWhere(
        (v) => v.vendorId == vendorId,
        orElse: () => Vendor(vendorId: vendorId),
      );

      if (existingVendor.storeName != null) {
        return existingVendor.storeName!;
      }

      var response = await http.post(
        Uri.parse('http://$ipAddress/silverskin-api/getVendorDetails.php'),
        body: {"vendor_id": vendorId},
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['success'] == true && result['vendor'] != null) {
          final vendor = Vendor.fromJson(result['vendor']);
          dataController.vendors.add(vendor);
          return vendor.storeName ?? "Vendor";
        }
      }
      return "Vendor";
    } catch (e) {
      return "Vendor Info";
    }
  }

  Future<void> getAdminStats() async {
    try {
      final response = await http.post(
        Uri.parse("http://$ipAddress/silverskin-api/admin/getAdminStats.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          adminStatsResponse = AdminStatResponse.fromJson(data);
          update();
        } else {
          throw Exception(data['message'] ?? 'Failed to load admin stats');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Error loading stats: ${e.toString()}',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        snackPosition: SnackPosition.TOP,
      ));
    }
  }

  Future<Map<String, dynamic>> getReviews(int productId) async {
    try {
      final id = productId is int
          ? productId
          : int.tryParse(productId.toString() ?? '0') ?? 0;
      final response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/getReviews.php",
        ),
        body: {"product_id": id.toString()},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return {
            'reviews': (result['reviews'] as List)
                .map((json) => Review.fromJson(json))
                .toList(),
            'average_rating':
                double.tryParse(result['average_rating']?.toString() ?? '0') ??
                    0.0,
            'review_count':
                int.tryParse(result['review_count']?.toString() ?? '0') ?? 0,
          };
        }
      }
      throw Exception("Failed to load reviews");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> submitReview({
    required int productId,
    required int orderId,
    required double rating,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/reviewProduct.php",
        ),
        body: {
          "user_id": userId.toString(),
          "product_id": productId.toString(),
          "order_id": orderId.toString(),
          "rating": rating.toString(),
          "comment": comment,
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] != true) {
          throw Exception(result['message'] ?? "Failed to submit review");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<bool> canUserReview(int orderId, int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null) {
        return false;
      }

      final response = await http.post(
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/canReview.php",
        ),
        body: {
          "user_id": userId.toString(),
          "order_id": orderId.toString(),
          "product_id": productId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['can_review'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
