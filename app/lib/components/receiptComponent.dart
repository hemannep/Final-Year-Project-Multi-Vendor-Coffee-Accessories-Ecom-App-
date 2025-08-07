import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:silverskin/models/order.dart';
import 'package:silverskin/controllers/getDataController.dart';

class ReceiptComponent {
  static Future<void> generateReceipt(Order order) async {
    try {
      final controller = Get.find<GetDataController>();

      // Ensure user details are loaded
      await controller.getMyDetails();
      final user = controller.userResponse?.user;

      // Fetch vendor names for items
      final vendorNames = <String, String>{};
      for (var item in order.items ?? []) {
        if (item.vendorId != null) {
          final vName = await controller.fetchVendorName(item.vendorId.toString());
          vendorNames[item.vendorId.toString()] = vName;
        }
      }

      // Build PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'Silver Skin',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Order Receipt',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.grey300),
                pw.SizedBox(height: 20),

                // Order & Customer Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Order #${order.orderId}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      DateFormat('MMM dd, yyyy hh:mm a')
                          .format(order.createdAt ?? DateTime.now()),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Payment: ${order.orderStatus == 'Cash Paid' ? 'Cash' : 'Online (Khalti)'}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 12),

                // Customer details
                pw.Text(
                  'Customer:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(user?.name ?? order.userName ?? '—'),
                pw.Text(user?.phone ?? order.userPhone ?? '—'),
                pw.Text(user?.email ?? order.userEmail ?? '—'),
                pw.SizedBox(height: 20),

                // Items Table Header
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          'Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // Items List
                for (var item in order.items ?? [])
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.productName ?? 'Product',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              if (item.vendorId != null)
                                pw.Text(
                                  'Vendor: ${vendorNames[item.vendorId.toString()] ?? '—'}',
                                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                                ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            '${item.quantity}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Rs.${((item.price ?? 0) / (item.quantity ?? 1)).toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Rs.${item.price}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 20),

                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 200,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Subtotal: Rs.${order.totalPrice}', style: const pw.TextStyle(fontSize: 14)),
                          pw.SizedBox(height: 4),
                          pw.Text('Tax: Rs.0', style: const pw.TextStyle(fontSize: 14)),
                          pw.Divider(thickness: 0.5),
                          pw.Text('Total: Rs.${order.totalPrice}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Text(
                    'Thank you for shopping with us!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.blue800),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save & open
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/${user?.name ?? order.userName}_${order.orderId}.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      Get.snackbar('Success', 'Receipt generated successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate receipt: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
