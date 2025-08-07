import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverskin/models/products.dart';

class Cartprovider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  int _totalItems = 0;
  int _totalPrice = 0;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  int get totalItems => _totalItems;
  int get totalPrice => _totalPrice;

  // ignore: non_constant_identifier_names
  Cardprovider() {
    loadCartItems();
  }

 Future<void> loadCartItems() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsString = prefs.getStringList('cartItems');
    if (cartItemsString != null && cartItemsString.isNotEmpty) {
      _cartItems = cartItemsString.map((item) => json.decode(item)).cast<Map<String, dynamic>>().toList();
      _calculateTotalItems();
      _calculateTotalPrice();
      // _totalItems = _cartItems.length;
      // _totalPrice = _cartItems.fold(0, (total, item) => total + item['price']);
    }
    notifyListeners();
  }

  void addItem(Map<String, dynamic> newItem) {
    int existingItemIndex =
        _cartItems.indexWhere((item) => item['product']['product_id'] == newItem['product']['product_id']);

    if (existingItemIndex != -1) {
      // Item already in cart, update its values
      _cartItems[existingItemIndex]['quantity'] += newItem['quantity'];
      _cartItems[existingItemIndex]['product'] = newItem['product'];
    } else {
      _cartItems.add(newItem);
    }
   
    _saveCartItems();
    _calculateTotalItems();
    _calculateTotalPrice();
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    _saveCartItems();
    _calculateTotalItems();
    _calculateTotalPrice();
    notifyListeners();
  }

  void updateItemCount(int index, int count) {
    _cartItems[index]['quantity'] = count;
    _saveCartItems();
    _calculateTotalItems();
    _calculateTotalPrice();
    notifyListeners();
  }



  _calculateTotalItems() {
    _totalItems = _cartItems.fold<int>(0, (total, item) => total + item['quantity'] as int);
    notifyListeners();
  }

 void _calculateTotalPrice() {
  _totalPrice = _cartItems.fold<int>(0, (total, item) {
    // Convert the stored price string to int. Ensure proper error handling if needed.
    final productMap = item['product'] as Map<String, dynamic>;
    final product = Product.fromJson(productMap);
    final productPrice = int.tryParse(product.price ?? "0") ?? 0;
    final quantity = item['quantity'] as int;
    return total + (productPrice * quantity);
  });
  notifyListeners();
}


  Future<void> _saveCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsString =
        _cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('cartItems', cartItemsString);
  }


  void clearCart() {
    _cartItems.clear();
    _saveCartItems();
    _calculateTotalItems();
    _calculateTotalPrice();
    notifyListeners();
  }

}