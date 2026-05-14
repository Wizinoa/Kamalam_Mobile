// instant_invoice.dart

// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InstantInvoice {
  static Future<void> generateReceipt({
    required BuildContext context,
    required String customerName,
    required String phone,
    required String metalType,
    required double weight,
    required double ratePerGram,
    required double metalValue,
    required double gst,
    required double totalAmount,
  }) async {
    try {
      final pdf = pw.Document();

      final now = DateTime.now();

      final invoiceNo = "SKJ-DG-${DateFormat('yyyyMMdd').format(now)}";

      final date = DateFormat("dd MMM yyyy").format(now);

      final time = DateFormat("hh:mm a").format(now);

      final txnId = "TXN${DateFormat('yyyyMMddHHmmss').format(now)}";

      final razorRef = "RZP${DateTime.now().millisecondsSinceEpoch}";

      String formatAmount(double value) {
        return "Rs. ${value.toStringAsFixed(2)}";
      }

      final headerGradient = pw.LinearGradient(
        colors: [PdfColor.fromHex("#4B0012"), PdfColor.fromHex("#D5004F")],
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            /// HEADER
            pw.Container(
              padding: const pw.EdgeInsets.all(22),
              decoration: pw.BoxDecoration(
                gradient: headerGradient,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Sri Kamalam Jewellers",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      pw.Text(
                        "158, Nethaji Rd, Madurai Main, Madurai",
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  pw.Text(
                    "DIGITAL ${metalType.toUpperCase()} RECEIPT",
                    style: pw.TextStyle(
                      color: PdfColors.amber,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 28),

            /// RECEIPT INFO
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _topInfo("RECEIPT NO.", invoiceNo),
                _topInfo("DATE", date),
                _topInfo("TIME", time),
              ],
            ),

            pw.SizedBox(height: 18),

            pw.Divider(),

            pw.SizedBox(height: 20),

            /// CUSTOMER DETAILS
            _sectionTitle("CUSTOMER DETAILS"),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#F5F5F5"),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        customerName,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),

                      pw.SizedBox(height: 4),

                      pw.Text(phone),
                    ],
                  ),

                  pw.Text(
                    "ID: APP25DGP615100",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 26),

            /// ITEM PURCHASED
            _sectionTitle("ITEM PURCHASED"),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#F5F5F5"),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      metalType == "gold"
                          ? "Digital Gold 22KT BIS Hallmarked"
                          : "Digital Silver 999 Pure Silver",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                        color: PdfColor.fromHex("#24304A"),
                      ),
                    ),
                  ),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Quantity",
                        style: const pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 10,
                        ),
                      ),

                      pw.SizedBox(height: 6),

                      pw.Text(
                        "${weight.toStringAsFixed(2)} g",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 28),

            /// PRICE BREAKDOWN
            _sectionTitle("PRICE BREAKDOWN"),

            _priceRow(
              "${metalType == "gold" ? "Gold" : "Silver"} Rate",
              "${formatAmount(ratePerGram)} / gram",
            ),

            _priceRow("Weight", "${weight.toStringAsFixed(2)} g"),

            _priceRow(
              "${metalType == "gold" ? "Gold" : "Silver"} Value",
              formatAmount(metalValue),
            ),

            _priceRow("GST @ 3%", formatAmount(gst)),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              child: pw.Divider(),
            ),

            _priceRow(
              "Total Amount Paid",
              formatAmount(totalAmount),
              isTotal: true,
            ),

            pw.SizedBox(height: 28),

            /// NOTE
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#FFF8E7"),
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColor.fromHex("#E4C770")),
              ),
              child: pw.Text(
                "${metalType == "gold" ? "Gold" : "Silver"} rate locked at $time on $date. Prices are subject to live market fluctuations. GST applicable as per Government norms.",
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex("#8A6A00"),
                ),
              ),
            ),

            pw.SizedBox(height: 28),

            /// PAYMENT DETAILS
            _sectionTitle("PAYMENT DETAILS"),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#F7F7F7"),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                children: [
                  _paymentRow("Payment Method", "UPI  Google Pay"),

                  pw.SizedBox(height: 12),

                  _paymentRow("Status", "PAID", valueColor: PdfColors.green),

                  pw.SizedBox(height: 12),

                  _paymentRow("Transaction ID", txnId),

                  pw.SizedBox(height: 12),

                  _paymentRow("Razorpay Ref", razorRef),
                ],
              ),
            ),

            pw.SizedBox(height: 34),

            pw.Divider(),

            pw.SizedBox(height: 12),

            pw.Center(
              child: pw.Text(
                "This is a computer-generated receipt.",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),

            pw.SizedBox(height: 14),

            pw.Center(
              child: pw.Text(
                "Thank you for investing with Sri Kamalam Jewellers",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColor.fromHex("#24304A"),
                ),
              ),
            ),
          ],
        ),
      );

      /// PDF BYTES
      final Uint8List bytes = await pdf.save();

      /// ANDROID DOWNLOADS FOLDER
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      /// CREATE FOLDER
      final folder = Directory("${directory.path}/SriKamalamReceipts");

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      /// FILE NAME
      final fileName =
          "SriKamalam_${metalType}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf";

      final file = File("${folder.path}/$fileName");

      /// SAVE PDF
      await file.writeAsBytes(bytes);

      /// SUCCESS
      /// OPEN PDF AUTOMATICALLY
      await OpenFilex.open(file.path);

      /// SUCCESS MESSAGE
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4B0012),
            duration: const Duration(seconds: 4),
            content: Text(
              "Receipt saved in SriKamalamReceipts folder",
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("PDF ERROR : $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed to save receipt\n$e"),
          ),
        );
      }
    }
  }

  static pw.Widget _topInfo(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),

        pw.SizedBox(height: 6),

        pw.Text(
          value,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  static pw.Widget _priceRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: isTotal ? 15 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),

          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isTotal ? 15 : 12,
              fontWeight: pw.FontWeight.bold,
              color: isTotal ? PdfColors.red : PdfColor.fromHex("#24304A"),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _paymentRow(
    String title,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            color: valueColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
