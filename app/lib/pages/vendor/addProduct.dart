import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/addProductController.dart';
import 'package:silverskin/controllers/getDataController.dart';

class AddProductPage extends StatelessWidget {
  final String vendor_id;

  const AddProductPage({super.key, required this.vendor_id});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    var controller = Get.put(AddProductController(vendor_id: vendor_id));
    var dataController = Get.find<GetDataController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: SafeArea(
              child: GetBuilder<AddProductController>(
                builder: (_) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Form Container
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: boxColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                // Vendor ID Field (Read-Only)
                                _buildTextField(
                                  controller: TextEditingController(text: vendor_id),
                                  label: "Vendor ID",
                                  enabled: false,
                                  icon: Icons.store_outlined,
                                ),
                                const SizedBox(height: 16),

                                // Product Name Field
                                _buildTextField(
                                  controller: controller.productNameController,
                                  label: "Product Name",
                                  icon: Icons.shopping_bag_outlined,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter the product name'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Product Description Field
                                _buildTextField(
                                  controller: controller.descriptionController,
                                  label: "Product Description",
                                  icon: Icons.description_outlined,
                                  maxLines: 5,
                                  minLines: 3,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter the product description'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Product Price Field
                                _buildTextField(
                                  controller: controller.productPriceController,
                                  label: "Product Price",
                                  icon: Icons.attach_money_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter the product price'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Stock Field
                                _buildTextField(
                                  controller: controller.stockController,
                                  label: "Stock Quantity",
                                  icon: Icons.inventory_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter the stock quantity'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Category Dropdown
                                DropdownButtonFormField<String>(
                                  onChanged: (value) {
                                    controller.selectedCategory = value;
                                    controller.update();
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Category",
                                    labelStyle: const TextStyle(color: textSecondaryColor),
                                    prefixIcon: const Icon(Icons.category_outlined, color: accentColor),
                                    filled: true,
                                    fillColor: boxColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  dropdownColor: boxColor,
                                  value: controller.selectedCategory,
                                  validator: (value) =>
                                      value == null ? "Please select a category" : null,
                                  items: dataController.categoriesResponse?.categories
                                      ?.map((element) => DropdownMenuItem(
                                            value: element.categoryId ?? "",
                                            child: Text(
                                              element.categoryTitle ?? "",
                                              style: const TextStyle(color: textColor),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 24),

                                // Select Image Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text(
                                      'SELECT IMAGE',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Image Preview
                                if (controller.imagePreview != null)
                                  Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: accentColor),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        controller.imagePreview!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // Image Error
                                if (controller.imageError != null)
                                  Text(
                                    controller.imageError!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 24),

                                // Add Product Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.addProduct,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text(
                                      'ADD PRODUCT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create a text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int minLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textSecondaryColor),
        prefixIcon: Icon(icon, color: accentColor),
        filled: true,
        fillColor: boxColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: const TextStyle(color: textColor),
    );
  }
}