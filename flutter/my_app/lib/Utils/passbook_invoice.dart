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

/// =============================
/// PASSBOOK INVOICE
/// =============================

class PassbookInvoice {
  static Future<void> generateReceipt({
    required BuildContext context,

    /// CUSTOMER
    required String customerName,
    required String phone,

    /// METAL
    required String metalType,

    /// PAYMENT VALUES
    required double weight,
    required double ratePerGram,
    required double metalValue,
    required double gst,
    required double totalAmount,

    /// TRANSACTION
    required String transactionId,
    required String paymentMethod,
    required String paymentStatus,
    required DateTime createdAt,
    required String schemeId,
  }) async {
    try {
      final pdf = pw.Document();

      final invoiceNo =
          "#SKJ-SC-${DateFormat('yyyyMMdd').format(createdAt)}";

      final date = DateFormat("dd MMM yyyy").format(createdAt);

      final time = DateFormat("hh:mm a").format(createdAt);

      final razorRef =
          "RZP${createdAt.millisecondsSinceEpoch}";

      String formatAmount(double value) {
        return "Rs.${value.toStringAsFixed(2)}";
      }

        final headerGradient = pw.LinearGradient(
        colors: [PdfColor.fromHex("#4B0012"), PdfColor.fromHex("#D5004F")],
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(26),

          build: (context) => [
            /// HEADER
            pw.Container(
              padding: const pw.EdgeInsets.all(22),
              decoration: pw.BoxDecoration(
                gradient: headerGradient,
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Sri Kamalam Jewellers",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.Text(
                        "DIGIGOLD SCHEME PAYMENT RECEIPT",
                        style: pw.TextStyle(
                          color: PdfColors.amber,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    "158, Nethaji Rd, Near Modern Restaurant, Valayal Kadai, Madurai Main, Madurai - 625 001 | 0452 235 0270",
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            /// RECEIPT INFO
            pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                _topInfo("RECEIP NO.", invoiceNo),
                _topInfo("DATE", date),
                _topInfo("TIME", time),
              ],
            ),

            pw.SizedBox(height: 18),

            pw.Divider(),

            pw.SizedBox(height: 18),

            /// CUSTOMER DETAILS
            _sectionTitle("CUSTOMER DETAILS"),

            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              color: PdfColor.fromHex("#F3F3F3"),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    customerName,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),

                  pw.Text(
                    "+91 $phone",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            /// SCHEME DETAILS
            _sectionTitle("SCHEME DETAILS"),

            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              color: PdfColor.fromHex("#F3F3F3"),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _schemeBox(
                        "Scheme Name",
                        customerName,
                      ),

                      _schemeBox(
                        "Scheme ID",
                        schemeId,
                      ),

                      _schemeBox(
                        "Installment No",
                        "05 of 12",
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 14),

                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _schemeBox(
                        "Date of Joining",
                        "15 Jan 2024",
                      ),

                      _schemeBox(
                        "Date of Maturity",
                        "15 Jan 2025",
                      ),

                      _schemeBox(
                        "Scheme Duration",
                        "12 Months",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            /// THIS PAYMENT
            _sectionTitle("THIS PAYMENT"),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              color: PdfColor.fromHex("#F3F3F3"),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      metalType == "gold"
                          ? "DigiGold Scheme Installment 22 Karat - BIS Hallmark - Pure Gold Savings"
                          : "DigiSilver Scheme Installment 999 Pure Silver",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: PdfColor.fromHex("#24304A"),
                      ),
                    ),
                  ),

                  pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        metalType == "gold"
                            ? "Gold Credited"
                            : "Silver Credited",
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey,
                        ),
                      ),

                      pw.SizedBox(height: 4),

                      pw.Text(
                        "${weight.toStringAsFixed(3)} g",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 15,
                          color: PdfColor.fromHex("#24304A"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            /// PRICE BREAKDOWN
            _sectionTitle("PRICE BREAKDOWN"),

            _priceRow(
              "${metalType == "gold" ? "Gold" : "Silver"} Rate (${metalType == "gold" ? "22KT" : "999"}) At Payment Time",
              "${formatAmount(ratePerGram)} / gram",
            ),

            _priceRow(
              "Amount Paid (this installment)",
              formatAmount(metalValue),
            ),

            _priceRow(
              "${metalType == "gold" ? "Gold" : "Silver"} Credited (this installment)",
              "${weight.toStringAsFixed(3)} g",
            ),

            _priceRow(
              "GST @ 3%",
              formatAmount(gst),
            ),

            pw.Container(
              height: 1,
              color: PdfColor.fromHex("#D3E2FF"),
            ),

            pw.SizedBox(height: 6),

            _priceRow(
              "Total Amount Paid",
              formatAmount(totalAmount),
              isTotal: true,
            ),

            pw.Divider(),

            pw.SizedBox(height: 20),

            /// GOLD RATE NOTE
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#FFF7DF"),
                border: pw.Border.all(
                  color: PdfColor.fromHex("#E5D08A"),
                ),
              ),
              child: pw.Text(
                "Gold Rate Reference: Rate applied at $time on $date. Rates are subject to market fluctuations. GST @ 3% as per Govt. of India norms.",
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromHex("#7D6513"),
                ),
              ),
            ),

            pw.SizedBox(height: 24),

            /// PAYMENT DETAILS
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              color: PdfColor.fromHex("#F7F7F7"),
              child: pw.Column(
                children: [
                  _paymentRow(
                    "Payment Method",
                    paymentMethod.toUpperCase(),
                  ),

                  pw.SizedBox(height: 12),

                  _paymentRow(
                    "STATUS",
                    paymentStatus.toUpperCase(),
                    valueColor:
                        paymentStatus.toLowerCase() ==
                                "success"
                            ? PdfColors.green
                            : PdfColors.red,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 28),

            /// TRANSACTION DETAILS
            _paymentRow(
              "Transaction ID",
              transactionId,
            ),

            pw.SizedBox(height: 10),

            _paymentRow(
              "Razorpay Ref",
              razorRef,
            ),

            pw.SizedBox(height: 30),

            pw.Divider(),

            pw.SizedBox(height: 12),

            pw.Center(
              child: pw.Text(
                "This is a computer-generated receipt and does not require a physical signature.",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey,
                ),
              ),
            ),

            pw.SizedBox(height: 14),

            pw.Center(
              child: pw.Text(
                "\"Thank you for investing with Sri Kamalam Jewellers\"",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                  color: PdfColor.fromHex("#24304A"),
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Center(
              child: pw.Text(
                "www.srikamalam.com • bd@wizinoa.com",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey,
                ),
              ),
            ),
          ],
        ),
      );

      final Uint8List bytes = await pdf.save();

      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory =
            await getApplicationDocumentsDirectory();
      }

      final folder = Directory(
        "${directory.path}/SriKamalamReceipts",
      );

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName =
          "SriKamalam_${metalType}_${DateFormat('yyyyMMdd_HHmmss').format(createdAt)}.pdf";

      final file = File("${folder.path}/$fileName");

      await file.writeAsBytes(bytes);

      await OpenFilex.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF1E2A4A),
            content: Text(
              "Receipt saved successfully",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("PDF ERROR : $e");
    }
  }

  static pw.Widget _topInfo(
    String title,
    String value,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey,
          ),
        ),

        pw.SizedBox(height: 5),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 11,
          ),
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
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  static pw.Widget _schemeBox(
    String title,
    String value,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey,
          ),
        ),

        pw.SizedBox(height: 5),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  static pw.Widget _priceRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),

          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: pw.FontWeight.bold,
              color: isTotal
                  ? PdfColors.red
                  : PdfColor.fromHex("#24304A"),
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
      mainAxisAlignment:
          pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
        ),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            color: valueColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}