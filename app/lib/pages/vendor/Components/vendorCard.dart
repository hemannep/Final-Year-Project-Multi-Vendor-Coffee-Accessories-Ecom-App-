import 'package:flutter/material.dart';
import 'package:silverskin/models/vendor.dart';
import 'package:silverskin/constant.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;

  const VendorCard({
    super.key,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Takes full available width
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Match ProductCard margin
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.store, size: 30, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.storeName ?? 'Vendor Store',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        if (vendor.name != null)
                          Text(
                            'Owner: ${vendor.name!}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Store Description
              if (vendor.storeDescription != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    vendor.storeDescription!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textSecondaryColor,
                    ),
                  ),
                ),

              // Contact Information
              if (vendor.email != null || vendor.phone != null || vendor.address != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (vendor.email != null)
                        _buildContactRow(Icons.email, vendor.email!),
                      if (vendor.phone != null)
                        _buildContactRow(Icons.phone, vendor.phone!),
                      if (vendor.address != null)
                        _buildContactRow(Icons.location_on, vendor.address!),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textSecondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}