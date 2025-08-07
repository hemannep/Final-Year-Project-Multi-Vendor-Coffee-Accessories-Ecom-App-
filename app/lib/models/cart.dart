import 'package:silverskin/models/products.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  num get totalPrice => (double.tryParse(product.price ?? '0') ?? 0 * quantity);
}

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  double get totalPrice => items.fold(
      0, (total, item) => total + item.totalPrice);

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice.toStringAsFixed(2),
    };
  }
}