import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silverskin/components/shippingDetailsCard.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/shipping.dart';

class ShippingPage extends StatefulWidget {
  const ShippingPage({super.key});

  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  final GetDataController _controller = Get.find<GetDataController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int? _editingShippingId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _controller.fetchShippingDetails(),
      if (_controller.userResponse == null) _controller.getMyDetails(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _addOrUpdateShipping() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_editingShippingId == null) {
          await _controller.addShippingDetails(
            address: _addressController.text,
            city: _cityController.text,
            state: _stateController.text,
            postalCode: _postalCodeController.text,
            country: _countryController.text,
          );
          Get.snackbar('Success', 'Address added successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        } else {
          await _controller.updateShippingDetails(
            shippingId: _editingShippingId!,
            address: _addressController.text,
            city: _cityController.text,
            state: _stateController.text,
            postalCode: _postalCodeController.text,
            country: _countryController.text,
          );
          Get.snackbar('Success', 'Address updated successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        }
        _clearForm();
        await _controller.fetchShippingDetails();
      } catch (e) {
        Get.snackbar('Error', e.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    }
  }

  void _clearForm() {
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _postalCodeController.clear();
    _countryController.clear();
    _phoneController.clear();
    _editingShippingId = null;
  }

  void _editShipping(Datum shipping) {
    _editingShippingId = shipping.shippingId;
    _addressController.text = shipping.address ?? '';
    _cityController.text = shipping.city ?? '';
    _stateController.text = shipping.state ?? '';
    _postalCodeController.text = shipping.postalCode ?? '';
    _countryController.text = shipping.country ?? '';
    _showAddEditDialog();
  }

  void _showAddEditDialog() {
    final userPhone = _controller.userResponse?.user?.phone ?? '';

    Get.dialog(
      Dialog(
        backgroundColor: boxColor.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: boxColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _editingShippingId == null ? 'Add Address' : 'Edit Address',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Street Address',
                      labelStyle: const TextStyle(color: textSecondaryColor),
                      prefixIcon:
                          const Icon(Icons.home_outlined, color: accentColor),
                      filled: true,
                      fillColor: boxColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    style: const TextStyle(color: textColor),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // City and State Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            labelStyle:
                                const TextStyle(color: textSecondaryColor),
                            prefixIcon: const Icon(Icons.location_city_outlined,
                                color: accentColor),
                            filled: true,
                            fillColor: boxColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: const TextStyle(color: textColor),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            labelStyle:
                                const TextStyle(color: textSecondaryColor),
                            prefixIcon: const Icon(Icons.map_outlined,
                                color: accentColor),
                            filled: true,
                            fillColor: boxColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: const TextStyle(color: textColor),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Postal Code and Country Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Postal Code',
                            labelStyle:
                                const TextStyle(color: textSecondaryColor),
                            prefixIcon: const Icon(
                                Icons.markunread_mailbox_outlined,
                                color: accentColor),
                            filled: true,
                            fillColor: boxColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: const TextStyle(color: textColor),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: InputDecoration(
                            labelText: 'Country',
                            labelStyle:
                                const TextStyle(color: textSecondaryColor),
                            prefixIcon: const Icon(Icons.flag_outlined,
                                color: accentColor),
                            filled: true,
                            fillColor: boxColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: const TextStyle(color: textColor),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController..text = userPhone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(color: textSecondaryColor),
                      prefixIcon:
                          const Icon(Icons.phone_outlined, color: accentColor),
                      filled: true,
                      fillColor: boxColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    style: const TextStyle(color: textColor),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                          _clearForm();
                        },
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: textSecondaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _addOrUpdateShipping,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'SAVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteShipping(int shippingId) async {
    // Check if this is the last shipping address
    if (_controller.shippingDetails.length == 1) {
      await Get.dialog<bool>(
        Dialog(
          backgroundColor: boxColor.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: boxColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cannot Delete Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You cannot delete this shipping address because there must be at least 1 shipping address available.',
                  style: TextStyle(color: textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: textSecondaryColor),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _editShipping(_controller.shippingDetails.first);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'EDIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // Original delete confirmation dialog for when there are multiple addresses
    final confirmed = await Get.dialog<bool>(
          Dialog(
            backgroundColor: boxColor.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: boxColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Confirm Delete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you sure you want to delete this address?',
                    style: TextStyle(color: textSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: textSecondaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (confirmed) {
      try {
        await _controller.deleteShippingDetails(shippingId);
        Get.snackbar('Success', 'Address deleted successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        await _controller.fetchShippingDetails();
      } catch (e) {
        Get.snackbar('Error', e.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shipping Addresses',
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: accentColor),
              )
            : Obx(() {
                final shippingList = _controller.shippingDetails;
                final canAddMore = shippingList.length < 3;
                final user = _controller.userResponse?.user;

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: accentColor,
                        onRefresh: _controller.fetchShippingDetails,
                        child: shippingList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_off_outlined,
                                      size: 60,
                                      color: textSecondaryColor,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No saved addresses',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        _clearForm();
                                        _showAddEditDialog();
                                      },
                                      child: const Text(
                                        'ADD YOUR FIRST ADDRESS',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                itemCount: shippingList.length,
                                itemBuilder: (context, index) {
                                  final shipping = shippingList[index];
                                  return ShippingCard(
                                    shippingData: shipping,
                                    userName: user?.name ?? 'User',
                                    userPhone: user?.phone ?? 'N/A',
                                    isDefault: shipping.isDefault ?? false,
                                    onEdit: () => _editShipping(shipping),
                                    onDelete: () =>
                                        _deleteShipping(shipping.shippingId!),
                                  );
                                },
                              ),
                      ),
                    ),
                    if (canAddMore && shippingList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _clearForm();
                              _showAddEditDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'ADD NEW ADDRESS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
