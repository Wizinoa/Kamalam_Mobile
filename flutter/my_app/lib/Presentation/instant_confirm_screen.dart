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
  final String metalType; // ── ADDED ──

  const ConfirmPurchaseScreen({
    super.key,
    this.weight = 1.0,
    this.goldRatePerGram = 27308.0,
    this.totalPayable = 28127.0,
    this.goldValue = 27308.0,
    this.gst = 819.0,
    this.metalType = 'gold', // ── ADDED ──
  });

  @override
  State<ConfirmPurchaseScreen> createState() => _ConfirmPurchaseScreenState();
}

class _ConfirmPurchaseScreenState extends State<ConfirmPurchaseScreen> {
  // ── ADDED: single source of truth ──
  bool get _isSilver => widget.metalType == 'silver';

  // ── ADDED: all dynamic strings/values derived from _isSilver ──
  String get _screenTitle => _isSilver ? "Confirm Silver Purchase" : "Confirm Gold Purchase";
  String get _metalImage => _isSilver ? "assets/images/img10.png" : "assets/images/img11.png";
  Color get _cardBgColor => _isSilver ? const Color(0xFFF2F2F2) : const Color(0xFFFFF8EC);
  Color get _cardBorderColor => _isSilver ? const Color(0xFFD6D6D6) : const Color(0xFFFFE3A3);
  Color get _iconBgColor => _isSilver ? const Color(0xFFE0E0E0) : const Color(0xFFFFEAB7);
  String get _weightLabel => _isSilver ? "Silver weight" : "Gold weight";
  String get _valueLabel => _isSilver ? "Silver value" : "Gold value";
  String get _summaryWeightText => "${widget.weight.toStringAsFixed(3)} g ${_isSilver ? 'Silver' : 'Gold'}";
  String get _purityText => _isSilver ? "999 Pure Digital Silver" : "22KT Pure Digital Gold";
  Color get _purityTextColor => _isSilver ? const Color(0xFF6B6B6B) : const Color(0xFFBF8C00);
  String get _infoBullet1 => _isSilver
      ? "• Silver will be credited instantly to your DigiSilver wallet after successful payment."
      : "• Gold will be credited instantly to your DigiGold wallet after successful payment.";
  String get _infoBullet2 => _isSilver
      ? "• Purchased silver is 100% secure and backed by 999 purity assurance."
      : "• Purchased gold is 100% secure and backed by 22KT purity assurance.";

  TextStyle _poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
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
                      onTap: () => Navigator.pop(context),
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

                    // ── CHANGED: dynamic title ──
                    Text(
                      _screenTitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
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
                  /// SUMMARY CARD — fully dynamic
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // ── CHANGED: dynamic bg and border ──
                      color: _cardBgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _cardBorderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            // ── CHANGED: dynamic icon bg ──
                            color: _iconBgColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            // ── CHANGED: dynamic image ──
                            child: Image.asset(_metalImage),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── CHANGED: dynamic weight + metal name ──
                              Text(
                                _summaryWeightText,
                                style: _poppins(16, FontWeight.w700, const Color(0xFF1A1A1A)),
                              ),

                              const SizedBox(height: 4),

                              // ── CHANGED: dynamic purity label + color ──
                              Text(
                                _purityText,
                                style: _poppins(12, FontWeight.w600, _purityTextColor),
                              ),
                            ],
                          ),
                        ),

                        // ── CHANGED: dynamic opacity image ──
                        Opacity(
                          opacity: 0.10,
                          child: Image.asset(_metalImage, height: 56),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ORDER SUMMARY
                  Text(
                    "ORDER SUMMARY",
                    style: _poppins(11, FontWeight.w600, const Color(0xFF9A9A9A))
                        .copyWith(letterSpacing: 1.3),
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
                        // ── CHANGED: dynamic row labels ──
                        _buildSummaryRow(
                          _weightLabel,
                          "${widget.weight.toStringAsFixed(3)} g",
                        ),

                        const SizedBox(height: 14),

                        _buildSummaryRow(
                          _valueLabel,
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
                              style: _poppins(16, FontWeight.w700, const Color(0xFF4B0012)),
                            ),
                            Text(
                              _formatINR(widget.totalPayable),
                              style: _poppins(17, FontWeight.w700, const Color(0xFF4B0012)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

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
                              style: _poppins(14, FontWeight.w700, const Color(0xFF4B0012)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ── CHANGED: dynamic info bullets ──
                        Text(
                          _infoBullet1,
                          style: _poppins(12, FontWeight.w500, const Color(0xFF666666))
                              .copyWith(height: 1.6),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _infoBullet2,
                          style: _poppins(12, FontWeight.w500, const Color(0xFF666666))
                              .copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// SSL CONTAINER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFAF2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCDEAD4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user, color: Color(0xFF118B50), size: 18),
                        const SizedBox(width: 10),
                        Text(
                          "SSL Encrypted Secure Transaction",
                          style: _poppins(12, FontWeight.w600, const Color(0xFF0B7A45)),
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
                        style: _poppins(15, FontWeight.w700, Colors.white),
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
                    style: _poppins(11, FontWeight.w400, const Color(0xFF777777)),
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: _poppins(11, FontWeight.w700, const Color(0xFF5D0017))
                            .copyWith(decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsAndConditionsScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
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
        Text(label, style: _poppins(13, FontWeight.w500, const Color(0xFF666666))),
        Text(value, style: _poppins(13, FontWeight.w600, const Color(0xFF1A1A1A))),
      ],
    );
  }
}