import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Presentation/instant_purchase_screen.dart';
import 'package:my_app/Presentation/terms_and_conditions.dart';

class ConfirmPurchaseScreen extends StatefulWidget {
  final double weight;
  final double goldRatePerGram;
  final double totalPayable;
  final double goldValue;
  final double gst;

  const ConfirmPurchaseScreen({
    super.key,
    this.weight = 1.0,
    this.goldRatePerGram = 27308.0,
    this.totalPayable = 28127.0,
    this.goldValue = 27308.0,
    this.gst = 819.0,
  });

  @override
  State<ConfirmPurchaseScreen> createState() => _ConfirmPurchaseScreenState();
}

class _ConfirmPurchaseScreenState extends State<ConfirmPurchaseScreen> {
  int _selectedPayment = 0;

  TextStyle _poppins(double size, FontWeight weight, Color color) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
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
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Text(
                      "Confirm Purchase",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      /// BODY
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// GOLD SUMMARY CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFE3A3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEAB7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset("assets/images/img11.png"),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.weight.toStringAsFixed(3)} g Gold",
                                style: _poppins(
                                  16,
                                  FontWeight.w700,
                                  const Color(0xFF1A1A1A),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "22KT Pure Digital Gold",
                                style: _poppins(
                                  12,
                                  FontWeight.w600,
                                  const Color(0xFFBF8C00),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Opacity(
                          opacity: 0.10,
                          child: Image.asset(
                            "assets/images/img11.png",
                            height: 56,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ORDER SUMMARY
                  Text(
                    "ORDER SUMMARY",
                    style: _poppins(
                      11,
                      FontWeight.w600,
                      const Color(0xFF9A9A9A),
                    ).copyWith(letterSpacing: 1.3),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          "Gold weight",
                          "${widget.weight.toStringAsFixed(3)} g",
                        ),

                        const SizedBox(height: 14),

                        _buildSummaryRow(
                          "Gold value",
                          _formatINR(widget.goldValue),
                        ),

                        const SizedBox(height: 14),

                        _buildSummaryRow("GST (3%)", _formatINR(widget.gst)),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Payable",
                              style: _poppins(
                                16,
                                FontWeight.w700,
                                const Color(0xFF4B0012),
                              ),
                            ),
                            Text(
                              _formatINR(widget.totalPayable),
                              style: _poppins(
                                17,
                                FontWeight.w700,
                                const Color(0xFF4B0012),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  const SizedBox(height: 20),

                  /// INFO TEXT CONTAINER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD8E5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEEF3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFFD5004F),
                                size: 18,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              "Important Information",
                              style: _poppins(
                                14,
                                FontWeight.w700,
                                const Color(0xFF4B0012),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "• Gold will be credited instantly to your DigiGold wallet after successful payment.",
                          style: _poppins(
                            12,
                            FontWeight.w500,
                            const Color(0xFF666666),
                          ).copyWith(height: 1.6),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "• Purchased gold is 100% secure and backed by 22KT purity assurance.",
                          style: _poppins(
                            12,
                            FontWeight.w500,
                            const Color(0xFF666666),
                          ).copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// SSL CONTAINER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFAF2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCDEAD4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: Color(0xFF118B50),
                          size: 18,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "SSL Encrypted Secure Transaction",
                          style: _poppins(
                            12,
                            FontWeight.w600,
                            const Color(0xFF0B7A45),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          /// BOTTOM SECTION
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// PAY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4C0012), Color(0xFFD5004F)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurchaseSuccessScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        "Pay ${_formatINR(widget.totalPayable)}",
                        style: _poppins(18, FontWeight.w700, Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// TERMS
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "By proceeding, you agree to the ",
                    style: _poppins(
                      11,
                      FontWeight.w400,
                      const Color(0xFF777777),
                    ),
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: _poppins(
                          11,
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
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: _poppins(13, FontWeight.w500, const Color(0xFF666666)),
        ),
        Text(
          value,
          style: _poppins(13, FontWeight.w600, const Color(0xFF1A1A1A)),
        ),
      ],
    );
  }
}
