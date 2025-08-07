// lib/pages/users/cartPage.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:silverskin/components/orderConfirmation.dart';
import 'package:silverskin/components/productInCart.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/products.dart';
import 'package:silverskin/pages/users/allProduct.dart';
import 'package:silverskin/providers/cartProvider.dart';
import 'package:silverskin/constant.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<GetDataController>();
    final cartProvider   = Provider.of<Cartprovider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: secondaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: cartProvider.cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                      size: 60, color: textSecondaryColor),
                    const SizedBox(height: 16),
                    const Text("Your Cart is Empty",
                      style: TextStyle(fontSize: 18, color: textColor)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Get.to(() => const AllProductPage()),
                      child: const Text('Explore All the Products',
                        style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (ctx, i) {
                        final p = cartProvider.cartItems[i];
                        final product = Product.fromJson(p['product']);
                        final qty     = p['quantity'] as int;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProductInCart(
                            product: product,
                            quantity: qty,
                            onDelete: () {
                              cartProvider.removeItem(i);
                              Get.showSnackbar(const GetSnackBar(
                                message: "Item removed from cart!",
                                backgroundColor: Colors.green,
                                snackPosition: SnackPosition.TOP,
                                duration: Duration(seconds: 1),
                              ));
                            },
                            onQuantityChanged: (newQty) {
                              cartProvider.updateItemCount(i, newQty);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: boxColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('Your Total Amount:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                        const SizedBox(height: 8),
                        Text("Rs. ${cartProvider.totalPrice}",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: accentColor)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showOrderConfirmationDialog(
                                context,
                                (paymentMethod) {
                                  // unified createOrder handles both flows
                                  dataController.createOrder(
                                    isCod: paymentMethod == "COD",
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: const Text('ORDER NOW',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
