import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Presentation/instant_confirm_screen.dart';
import 'package:my_app/Providers/gold_Provider.dart';
import 'package:my_app/Presentation/terms_and_conditions.dart';
import 'package:provider/provider.dart';

class BuyGoldScreen extends StatefulWidget {
  final String metalType;

  const BuyGoldScreen({super.key, required this.metalType});

  @override
  State<BuyGoldScreen> createState() => _BuyGoldScreenState();
}

class _BuyGoldScreenState extends State<BuyGoldScreen> {
  static const double _gstRate = 0.03;
  static const double _minWeight = 0.5;
  static const double _maxWeight = 500.0;

  double _weight = 1.0;
  double _metalRatePerGram = 27308;

  // ── Helpers ──
  bool get _isSilver => widget.metalType == 'silver';

  String get _screenTitle => _isSilver ? "Silver Purchase" : "Gold Purchase";
  String get _rateLabel => _isSilver ? "SILVER RATE — 999" : "GOLD RATE — 22KT";
  String get _metalImage =>
      _isSilver ? "assets/images/img10.png" : "assets/images/img11.png";
  Color get _iconBgColor =>
      _isSilver ? const Color(0xFFE8E8E8) : const Color(0xFFF4DA92);
  String get _walletInfoText => _isSilver
      ? "Silver is added to your DigiSilver wallet instantly after payment. Pure 999 digital silver only — no jewellery."
      : "Gold is added to your DigiGold wallet instantly after payment. Pure 22KT digital gold only — no jewellery.";
  String get _metalValueLabel =>
      "${_isSilver ? 'Silver' : 'Gold'} value (${_weight}g × ${_formatINR(_metalRatePerGram)})";

  double get _metalValue => _weight * _metalRatePerGram;
  double get _gst => _metalValue * _gstRate;
  double get _totalPayable => _metalValue + _gst;

  TextStyle _poppins(double size, FontWeight w, Color c) {
    return GoogleFonts.poppins(fontSize: size, fontWeight: w, color: c);
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

  void _increment() {
    if (_weight < _maxWeight) {
      setState(() {
        _weight = double.parse((_weight + 0.5).toStringAsFixed(1));
      });
    }
  }

  void _decrement() {
    if (_weight > _minWeight) {
      setState(() {
        _weight = double.parse((_weight - 0.5).toStringAsFixed(1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoldPriceProvider>(
      builder: (context, goldProvider, child) {
        // ── Pick gold or silver rate ──
        final metalData = _isSilver
            ? goldProvider.silverData
            : goldProvider.goldData;
        if (metalData != null) {
          _metalRatePerGram = metalData.sellPrice.toDouble();
        }

        final displayDate = metalData?.date ?? "12 May 2026";
        final displayTime = metalData?.time ?? "10:45 AM";

        return Scaffold(
          backgroundColor: Colors.white,

          /// APP BAR
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
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // ── CHANGED: dynamic title ──
                        Text(
                          _screenTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
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
            child: Column(
              children: [
                /// BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      children: [
                        /// RATE CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8EEDC),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── CHANGED: dynamic rate label ──
                                        Text(
                                          _rateLabel,
                                          style: _poppins(
                                            10,
                                            FontWeight.w700,
                                            const Color(0xFF98856A),
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              _formatINR(_metalRatePerGram),
                                              style: _poppins(
                                                22,
                                                FontWeight.w700,
                                                const Color(0xFF1B1B1B),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                                bottom: 7,
                                              ),
                                              child: Text(
                                                "/ gram",
                                                style: _poppins(
                                                  13,
                                                  FontWeight.w500,
                                                  const Color(0xFF8E8E8E),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "$displayDate • $displayTime",
                                          style: _poppins(
                                            11,
                                            FontWeight.w500,
                                            const Color(0xFF8A8A8A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ── CHANGED: dynamic icon bg + image ──
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: _iconBgColor,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Image.asset(_metalImage),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// WEIGHT BUTTON
                        Container(
                          height: 42,
                          width: 175,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4B0012), Color(0xFFD5004F)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Weight (g)",
                            style: _poppins(13, FontWeight.w600, Colors.white),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          "ENTER WEIGHT",
                          style: _poppins(
                            11,
                            FontWeight.w700,
                            const Color(0xFF969696),
                          ).copyWith(letterSpacing: 1.6),
                        ),

                        const SizedBox(height: 22),

                        /// STEPPER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _stepButton(icon: Icons.remove, onTap: _decrement),

                            const SizedBox(width: 28),

                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _weight % 1 == 0
                                        ? _weight.toInt().toString()
                                        : _weight.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF7A1030),
                                    ),
                                  ),
                                  TextSpan(
                                    text: " g",
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7A1030),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 28),

                            _stepButton(icon: Icons.add, onTap: _increment),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// SLIDER
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF7A1030),
                            inactiveTrackColor: const Color(0xFFEBD6DD),
                            thumbColor: const Color(0xFF7A1030),
                            overlayColor: const Color(0x227A1030),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _weight,
                            min: _minWeight,
                            max: _maxWeight,
                            divisions: 19,
                            onChanged: (val) {
                              setState(() {
                                _weight = double.parse(val.toStringAsFixed(1));
                              });
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "0.5g",
                                style: _poppins(
                                  10,
                                  FontWeight.w600,
                                  Colors.grey,
                                ),
                              ),
                              Text(
                                "500g",
                                style: _poppins(
                                  10,
                                  FontWeight.w600,
                                  Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        /// PAY CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "YOU PAY",
                                style: _poppins(
                                  11,
                                  FontWeight.w700,
                                  const Color(0xFF9B9B9B),
                                ).copyWith(letterSpacing: 1.5),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatINR(_totalPayable),
                                    style: _poppins(
                                      24,
                                      FontWeight.w700,
                                      const Color(0xFF6B001A),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 6,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      "Incl. taxes",
                                      style: _poppins(
                                        11,
                                        FontWeight.w500,
                                        Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // ── CHANGED: dynamic metal value label ──
                              _buildRow(
                                _metalValueLabel,
                                _formatINR(_metalValue),
                              ),

                              const SizedBox(height: 12),

                              _buildRow("GST (3%)", _formatINR(_gst)),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(height: 1),
                              ),

                              _buildRow(
                                "Total Payable",
                                _formatINR(_totalPayable),
                                isBold: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// INFO CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF8F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD5E9D7)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 22,
                                width: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF3A9142),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(width: 10),

                              // ── CHANGED: dynamic wallet info text ──
                              Expanded(
                                child: Text(
                                  _walletInfoText,
                                  style: _poppins(
                                    11,
                                    FontWeight.w600,
                                    const Color(0xFF377246),
                                  ).copyWith(height: 1.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// BANNER
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            _isSilver
                                ? "assets/images/img25.png"
                                : "assets/images/img22.png",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                /// BOTTOM SECTION
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// BUY BUTTON
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
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmPurchaseScreen(
                                    weight: _weight,
                                    goldRatePerGram: _metalRatePerGram,
                                    goldValue: _metalValue,
                                    gst: _gst,
                                    totalPayable: _totalPayable,
                                    // ── CHANGED: pass metalType forward ──
                                     metalType: widget.metalType,
                                  ),
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
                              "Buy Now",
                              style: _poppins(
                                14,
                                FontWeight.w700,
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// CANCEL BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD21B58)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: _poppins(
                              14,
                              FontWeight.w600,
                              const Color(0xFF6B001A),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// TERMS & CONDITIONS
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "By proceeding, you agree to the ",
                          style: _poppins(
                            11,
                            FontWeight.w500,
                            const Color(0xFF8A8A8A),
                          ),
                          children: [
                            TextSpan(
                              text: "Terms & Conditions",
                              style: _poppins(
                                11,
                                FontWeight.w700,
                                const Color(0xFF6B001A),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stepButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD8A8B7)),
        ),
        child: Icon(icon, color: const Color(0xFF6B001A)),
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? const Color(0xFF6B001A) : const Color(0xFF666666),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
