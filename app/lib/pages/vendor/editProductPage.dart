import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/products.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  final Function(Product) onUpdate;

  const EditProductPage({
    super.key,
    required this.product,
    required this.onUpdate,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  final GetDataController _dataController = Get.find<GetDataController>();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.productName);
    _priceController = TextEditingController(text: widget.product.price);
    _stockController = TextEditingController(text: widget.product.stock);
    _descController = TextEditingController(text: widget.product.productDescription);
    _selectedCategory = widget.product.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Product',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: accentColor),
            onPressed: _saveChanges,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            children: [
              // Product Image
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "http://$ipAddress/silverskin-api${widget.product.imageUrl ?? ''}",
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_not_supported, 
                          color: textSecondaryColor, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
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
                    // Product Name Field
                    _buildTextField(
                      controller: _nameController,
                      label: "Product Name",
                      icon: Icons.shopping_bag_outlined,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter the product name' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Price Field
                    _buildTextField(
                      controller: _priceController,
                      label: "Product Price",
                      icon: Icons.attach_money_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(value!) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Stock Field
                    _buildTextField(
                      controller: _stockController,
                      label: "Stock Quantity",
                      icon: Icons.inventory_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (int.tryParse(value!) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Description Field
                    _buildTextField(
                      controller: _descController,
                      label: "Product Description",
                      icon: Icons.description_outlined,
                      maxLines: 5,
                      minLines: 3,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter the product description' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
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
                      value: _selectedCategory,
                      validator: (value) =>
                          value == null ? "Please select a category" : null,
                      items: _dataController.categoriesResponse?.categories
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
                    
                    // Save Changes Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'SAVE CHANGES',
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
      ),
    );
  }

  // Reusable text field widget (matches your theme)
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

  void _saveChanges() {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedCategory == null) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final updatedProduct = Product(
      product_id: widget.product.product_id,
      vendor_id: widget.product.vendor_id,
      productName: _nameController.text,
      productDescription: _descController.text,
      price: _priceController.text,
      stock: _stockController.text,
      categoryId: _selectedCategory!,
      imageUrl: widget.product.imageUrl,
      createdAt: widget.product.createdAt,
      onlineStatus: widget.product.onlineStatus,
    );
    
    widget.onUpdate(updatedProduct);
    Get.back();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }
}