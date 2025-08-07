import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:silverskin/constant.dart';

class AddProductController extends GetxController {
  final String vendor_id;

  AddProductController({required this.vendor_id}) {
    vendorIdController = TextEditingController(text: vendor_id);
  }

  final formKey = GlobalKey<FormState>();

  late TextEditingController vendorIdController;
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final productPriceController = TextEditingController();
  final stockController = TextEditingController();

  String? selectedCategory;
  Uint8List? imagePreview;
  XFile? imageFile;
  String? imageError;

  // Pick image
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    imageFile = await picker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      imagePreview = await imageFile!.readAsBytes();
      imageError = null;
    } else {
      imageError = "Please select an image";
    }

    update();
  }

  // Add product
  Future<void> addProduct() async {
    if (!formKey.currentState!.validate()) return;
    if (imageFile == null) {
      imageError = "Please select an image";
      update();
      return;
    }

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri(
          scheme: "http",
          host: ipAddress,
          path: "/silverskin-api/addProduct.php",
        ),
      );

      request.fields['vendor_id'] = vendorIdController.text;
      request.fields['product_name'] = productNameController.text;
      request.fields['product_description'] = descriptionController.text;
      request.fields['price'] = productPriceController.text;
      request.fields['stock'] = stockController.text;
      request.fields['category'] = selectedCategory ?? "";

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile!.path,
      ));

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var result = json.decode(responseData.body);

      if (result['success'] == true) {
        Get.snackbar(
          "Success",
          result['message'] ?? "Product added successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearFields();
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? "Failed to add product",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearFields() {
    productNameController.clear();
    descriptionController.clear();
    productPriceController.clear();
    stockController.clear();
    selectedCategory = null;
    imageFile = null;
    imagePreview = null;
    imageError = null;
    update();
  }
}
