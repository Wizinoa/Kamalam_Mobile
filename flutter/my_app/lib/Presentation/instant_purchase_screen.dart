import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Presentation/home_screen.dart';
import 'package:my_app/Presentation/terms_and_conditions.dart';
import 'package:my_app/Utils/instant_invoice.dart';

class PurchaseSuccessScreen extends StatelessWidget {
  final double weight;
  final double goldRatePerGram;
  final double totalPayable;
  final double goldValue;
  final double gst;
  final String metalType;
  final String customerName;
  final String phone;
  final String email;
  final String paymentMethod;
  final String transactionId;
  final String razorpayOrderId;
  final DateTime? date;  // Changed from DATE to date (lowercase is convention)

  const PurchaseSuccessScreen({
    super.key,
    this.weight = 1.0,
    this.goldRatePerGram = 27308.0,
    this.totalPayable = 28127.0,
    this.goldValue = 27308.0,
    this.gst = 819.0,
    this.metalType = 'gold',
    this.customerName = '',
    this.phone = '',
    this.email = '',
    this.paymentMethod = 'UPI',
    this.transactionId = '',
    this.razorpayOrderId = '',
    this.date,  // Changed from DATE to date
  });

  bool get _isSilver => metalType.toLowerCase() == 'silver';

  String get _metalName => _isSilver ? "Silver" : "Gold";
  String get _walletName => _isSilver ? "DigiSilver" : "DigiGold";
  String get _purityText =>
      _isSilver ? "999 Pure Digital Silver" : "22KT Pure Digital Gold";

  TextStyle poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  String _formatINR(double value) {
    final formatted = value.toStringAsFixed(0);
    final chars = formatted.split('');
    final result = StringBuffer();
    int count = 0;

    for (int i = chars.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        result.write(',');
      }
      result.write(chars[i]);
      count++;
    }
    return "₹${result.toString().split('').reversed.join()}";
  }

  String _formatDate(DateTime dt) =>
      DateFormat('dd MMM yyyy').format(dt.toLocal());

  String _formatTime(DateTime dt) =>
      DateFormat('hh:mm a').format(dt.toLocal());

  String _getFormattedDateTime() {
    final transactionDate = date ?? DateTime.now();
    return "${_formatDate(transactionDate)} & ${_formatTime(transactionDate)}";
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4B0012),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context) async {
    // Show loading dialog that blocks interaction
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD5004F),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Generating Receipt...",
                    style: poppins(
                      16,
                      FontWeight.w600,
                      const Color(0xFF4B0012),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please wait while we prepare your receipt",
                    style: poppins(
                      12,
                      FontWeight.w400,
                      const Color(0xFF777777),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      await InstantInvoice.generateReceipt(
        context: context,
        customerName: customerName.isNotEmpty ? customerName : "Customer",
        phone: phone.isNotEmpty ? phone : "N/A",
        metalType: metalType,
        weight: weight,
        ratePerGram: goldRatePerGram,
        metalValue: goldValue,
        gst: gst,
        totalAmount: totalPayable,
        transactionId: transactionId.isNotEmpty
            ? transactionId
            : "TXN-${DateTime.now().millisecondsSinceEpoch}",
        paymentMethod: paymentMethod,
        razorpayOrderId: razorpayOrderId,
         transactionDate: date,  
      );

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        _showMessage(context, "Receipt downloaded successfully!");
      }
    } catch (e) {
      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        _showMessage(
          context,
          "Failed to download receipt: ${e.toString()}",
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F3F4),

        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF3A0A13), Color(0xFFC6003A)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Purchase Success",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
            child: Column(
              children: [
                /// SUCCESS ICON
                Container(
                  height: 72,
                  width: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7A0023),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 34),
                ),

                const SizedBox(height: 18),

                /// TITLE
                Text(
                  "$_metalName Purchased!",
                  style: poppins(24, FontWeight.w700, const Color(0xFF4B0012)),
                ),

                const SizedBox(height: 8),

                /// SUBTITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Your investment is secured. ${weight.toStringAsFixed(3)} g has been added to your $_walletName wallet.",
                    textAlign: TextAlign.center,
                    style: poppins(
                      13,
                      FontWeight.w500,
                      const Color(0xFF777777),
                    ).copyWith(height: 1.5),
                  ),
                ),

                const SizedBox(height: 20),

                /// SUCCESS BADGE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F6EA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD1EAD3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF2D8C42),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "$_walletName WALLET UPDATED SUCCESSFULLY",
                          style: poppins(
                            11,
                            FontWeight.w700,
                            const Color(0xFF2D8C42),
                          ).copyWith(letterSpacing: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// METAL CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isSilver
                        ? const Color(0xFFE8E8E8)
                        : const Color(0xFFF5DA87),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ASSET ADDED",
                                  style: poppins(
                                    10,
                                    FontWeight.w700,
                                    _isSilver
                                        ? const Color(0xFF6B6B6B)
                                        : const Color(0xFF8A6A00),
                                  ).copyWith(letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${weight.toStringAsFixed(3)} g",
                                  style: poppins(
                                    28,
                                    FontWeight.w700,
                                    const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isSilver
                                ? Icons.circle_outlined
                                : Icons.hexagon_outlined,
                            color: const Color(0xFF4B0012),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Purity",
                            style: poppins(
                              12,
                              FontWeight.w500,
                              _isSilver
                                  ? const Color(0xFF6B6B6B)
                                  : const Color(0xFF6D5A1A),
                            ),
                          ),
                          Text(
                            _purityText,
                            style: poppins(
                              12,
                              FontWeight.w700,
                              const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Rate",
                            style: poppins(
                              12,
                              FontWeight.w500,
                              _isSilver
                                  ? const Color(0xFF6B6B6B)
                                  : const Color(0xFF6D5A1A),
                            ),
                          ),
                          Text(
                            _formatINR(goldRatePerGram),
                            style: poppins(
                              12,
                              FontWeight.w700,
                              const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          _isSilver
                              ? "assets/images/img24.png"
                              : "assets/images/img23.png",
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// CUSTOMER DETAILS CARD
                if (customerName.isNotEmpty || phone.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFB8D8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 18,
                              color: Color(0xFF005B9F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Customer Details",
                              style: poppins(
                                13,
                                FontWeight.w700,
                                const Color(0xFF005B9F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (customerName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Name:",
                                  style: poppins(
                                    12,
                                    FontWeight.w500,
                                    const Color(0xFF666666),
                                  ),
                                ),
                                Text(
                                  customerName,
                                  style: poppins(
                                    12,
                                    FontWeight.w600,
                                    const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Phone:",
                                  style: poppins(
                                    12,
                                    FontWeight.w500,
                                    const Color(0xFF666666),
                                  ),
                                ),
                                Text(
                                  phone,
                                  style: poppins(
                                    12,
                                    FontWeight.w600,
                                    const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (email.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Email:",
                                style: poppins(
                                  12,
                                  FontWeight.w500,
                                  const Color(0xFF666666),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  email,
                                  textAlign: TextAlign.right,
                                  style: poppins(
                                    12,
                                    FontWeight.w600,
                                    const Color(0xFF1A1A1A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                if (customerName.isNotEmpty || phone.isNotEmpty)
                  const SizedBox(height: 18),

                /// TRANSACTION SUMMARY
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F1F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEDFE2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 18,
                            color: Color(0xFF7A0023),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Transaction Summary",
                            style: poppins(
                              13,
                              FontWeight.w700,
                              const Color(0xFF7A0023),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildRow("$_metalName Value", _formatINR(goldValue)),
                      const SizedBox(height: 12),
                      _buildRow("GST (3%)", _formatINR(gst)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Paid",
                            style: poppins(
                              15,
                              FontWeight.w700,
                              const Color(0xFF4B0012),
                            ),
                          ),
                          Text(
                            _formatINR(totalPayable),
                            style: poppins(
                              24,
                              FontWeight.w700,
                              const Color(0xFF7A0023),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _infoColumn(
                              "DATE & TIME",
                              _getFormattedDateTime(), // Fixed: Using the formatted date time
                            ),
                          ),
                          SizedBox(width: 50),
                          Expanded(
                            child: _infoColumn("PAYMENT METHOD", paymentMethod),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _infoColumn(
                        "TRANSACTION ID",
                        transactionId.isNotEmpty
                            ? transactionId
                            : "TXN-${DateTime.now().millisecondsSinceEpoch}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// DOWNLOAD BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4B0012), Color(0xFFD5004F)],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _handleDownload(context),
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        "Download Receipt",
                        style: poppins(14, FontWeight.w700, Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// TERMS
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "By proceeding, you agree to the ",
                    style: poppins(
                      10,
                      FontWeight.w500,
                      const Color(0xFF777777),
                    ),
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: poppins(
                          10,
                          FontWeight.w700,
                          const Color(0xFF5D0017),
                        ).copyWith(decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TermsAndConditionsScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// HOME BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.home_outlined,
                      color: Color(0xFF4B0012),
                    ),
                    label: Text(
                      "Go Home",
                      style: poppins(
                        14,
                        FontWeight.w600,
                        const Color(0xFF4B0012),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD8B7C2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: poppins(13, FontWeight.w500, const Color(0xFF666666)),
        ),
        Text(
          value,
          style: poppins(13, FontWeight.w700, const Color(0xFF1A1A1A)),
        ),
      ],
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: poppins(
            10,
            FontWeight.w700,
            const Color(0xFF9A9A9A),
          ).copyWith(letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: poppins(12, FontWeight.w600, const Color(0xFF1A1A1A)),
        ),
      ],
    );
  }
}