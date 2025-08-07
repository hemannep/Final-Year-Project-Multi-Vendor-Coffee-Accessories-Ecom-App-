import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';

class ShippingCard extends StatelessWidget {
  final dynamic shippingData;
  final String userName;
  final String userPhone;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShippingCard({
    super.key,
    required this.shippingData,
    required this.userName,
    required this.userPhone,
    required this.isDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Row(
              children: [
                const Icon(Icons.person, color: textSecondaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.phone, color: textSecondaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  userPhone,
                  style: const TextStyle(color: textSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Default Address Badge
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEFAULT ADDRESS',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            
            // Address Details
            _buildDetailRow(Icons.location_on, shippingData.address ?? ''),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDetailRow(Icons.location_city, shippingData.city ?? ''),
                const SizedBox(width: 16),
                _buildDetailRow(Icons.map, shippingData.state ?? ''),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDetailRow(Icons.numbers, shippingData.postalCode ?? ''),
                const SizedBox(width: 16),
                _buildDetailRow(Icons.flag, shippingData.country ?? ''),
              ],
            ),
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: accentColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: accentColor),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: textSecondaryColor, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: textColor),
        ),
      ],
    );
  }
}