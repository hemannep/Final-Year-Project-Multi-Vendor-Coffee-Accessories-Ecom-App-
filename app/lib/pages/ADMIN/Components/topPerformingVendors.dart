import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/models/vendor.dart';

class TopPerformingVendors extends StatelessWidget {
  final List<Vendor> vendors;
  
  const TopPerformingVendors({super.key, required this.vendors});

  @override
  Widget build(BuildContext context) {
    if (vendors.isEmpty) {
      return const Center(child: Text("No top vendors found", style: TextStyle(color: textSecondaryColor)));
    }
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: secondaryColor,
                  child: Icon(Icons.store, color: Colors.white54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vendor.storeName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}