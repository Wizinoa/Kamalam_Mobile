import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseSuccessScreen extends StatelessWidget {
  const PurchaseSuccessScreen({super.key});

  TextStyle poppins(
    double size,
    FontWeight weight,
    Color color,
  ) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F4),

      /// APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF4B0012),
                  Color(0xFFD5004F),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Text(
                      "Purchase Success",
                      style: poppins(
                        15,
                        FontWeight.w600,
                        Colors.white,
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
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(height: 18),

              /// TITLE
              Text(
                "Gold Purchased!",
                style: poppins(
                  28,
                  FontWeight.w700,
                  const Color(0xFF4B0012),
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Your investment is secured. 1.000 g has been added to your DigiGold wallet.",
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
                  border: Border.all(
                    color: const Color(0xFFD1EAD3),
                  ),
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
                        "DIGIGOLD WALLET UPDATED SUCCESSFULLY",
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

              /// GOLD CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5DA87),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ASSET ADDED",
                                style: poppins(
                                  10,
                                  FontWeight.w700,
                                  const Color(0xFF8A6A00),
                                ).copyWith(
                                  letterSpacing: 1.2,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "1.000 g",
                                style: poppins(
                                  34,
                                  FontWeight.w700,
                                  const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.hexagon_outlined,
                          color: Color(0xFF4B0012),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Purity",
                          style: poppins(
                            12,
                            FontWeight.w500,
                            const Color(0xFF6D5A1A),
                          ),
                        ),

                        Text(
                          "22KT Pure Gold",
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
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Current Rate",
                          style: poppins(
                            12,
                            FontWeight.w500,
                            const Color(0xFF6D5A1A),
                          ),
                        ),

                        Text(
                          "₹6,845.50 /g",
                          style: poppins(
                            12,
                            FontWeight.w700,
                            const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// IMAGE
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/img22.png",
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// TRANSACTION SUMMARY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F1F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEEDFE2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

                    _buildRow(
                      "Gold Value",
                      "₹6,845.50",
                    ),

                    const SizedBox(height: 12),

                    _buildRow(
                      "GST (3%)",
                      "₹205.37",
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 14),
                      child: Divider(),
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
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
                          "₹7,050.87",
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
                            "24 Oct, 02:45 PM",
                          ),
                        ),

                        Expanded(
                          child: _infoColumn(
                            "PAYMENT METHOD",
                            "HDFC Bank •••• 8821",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _infoColumn(
                      "TRANSACTION ID",
                      "TXN-9921-8842-AURO",
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
                    borderRadius:
                        BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4B0012),
                        Color(0xFFD5004F),
                      ],
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      "Download Receipt",
                      style: poppins(
                        14,
                        FontWeight.w700,
                        Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.transparent,
                      shadowColor:
                          Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(32),
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
                  text:
                      "By proceeding, you agree to the ",
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
                      ).copyWith(
                        decoration:
                            TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ACTION BUTTONS
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    Icons.share_outlined,
                    "Share",
                  ),
                  _actionButton(
                    Icons.history,
                    "View History",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// HOME BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {},
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
                    side: const BorderSide(
                      color: Color(0xFFD8B7C2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: poppins(
            13,
            FontWeight.w500,
            const Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: poppins(
            13,
            FontWeight.w700,
            const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _infoColumn(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
          style: poppins(
            12,
            FontWeight.w600,
            const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE5D7DB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF7A0023),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: poppins(
              13,
              FontWeight.w600,
              const Color(0xFF7A0023),
            ),
          ),
        ],
      ),
    );
  }
}