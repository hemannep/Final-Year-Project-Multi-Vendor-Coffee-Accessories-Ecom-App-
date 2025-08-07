import 'package:flutter/material.dart';
import 'package:silverskin/constant.dart';

void showOrderConfirmationDialog(BuildContext context, Function(String) onPaymentSelected) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: borderColor, width: 2),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Payment Method",
                style: headlineTextStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.money, color: accentColor),
                      title: const Text(
                        "Cash on Delivery",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      tileColor: primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onPaymentSelected("COD");
                      },
                    ),
                    const Divider(height: 1, color: borderColor),
                    ListTile(
                      leading: const Icon(Icons.payment, color: accentColor),
                      title: const Text(
                        "Online Payment",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      tileColor: primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onPaymentSelected("Online");
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: textSecondaryColor,
                    ),
                    child: const Text("CANCEL"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}