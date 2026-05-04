import 'package:flutter/material.dart';
import 'package:my_app/Presentation/kyc_screen.dart';

class AboutDigigoldScreen extends StatefulWidget {
  const AboutDigigoldScreen({super.key, this.initialCarouselPage = 0});

  final int initialCarouselPage;

  @override
  State<AboutDigigoldScreen> createState() => _AboutDigigoldScreenState();
}

class _AboutDigigoldScreenState extends State<AboutDigigoldScreen> {
  late final PageController _schemeController;
  int _schemePage = 0;

  static const _schemes = [
    (
      backgroundImage: 'assets/images/img13.png',
      sideImage: 'assets/images/img9.png',
      label: 'DigiGold Savings',
      title: '22K Pure Gold',
      points: (
        'Start from ₹100',
        'Up to 5% annual benefit',
        'Zero storage charges',
      ),
    ),
    (
      backgroundImage: 'assets/images/img14.png',
      sideImage: 'assets/images/img10.png',
      label: 'DigiSilver Savings',
      title: 'Pure Silver',
      points: (
        'Start from ₹100',
        'Affordable silver savings',
        'Zero storage charges',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.initialCarouselPage.clamp(0, _schemes.length - 1);
    _schemePage = safeIndex;
    _schemeController = PageController(initialPage: safeIndex);
  }

  @override
  void dispose() {
    _schemeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Join DigiGold Scheme",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP BANNER
                  SizedBox(
                    height: 150,
                    child: PageView.builder(
                      controller: _schemeController,
                      itemCount: _schemes.length,
                      onPageChanged: (index) => setState(() => _schemePage = index),
                      itemBuilder: (context, index) {
                        final scheme = _schemes[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  scheme.backgroundImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: -8,
                                bottom: 12,
                                child: Image.asset(
                                  scheme.sideImage,
                                  width: 92,
                                  height: 92,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scheme.label,
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      scheme.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${scheme.points.$1}\n${scheme.points.$2}\n${scheme.points.$3}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_schemes.length, (index) {
                      final active = index == _schemePage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 16 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFE1094A) : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // ABOUT
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🟡 ICON
                        Container(
                          height: 36,
                          width: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFD4A93A), Color(0xFFB8902E)],
                            ),
                          ),
                          child: const Icon(
                            Icons.info,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// 📄 TEXT CONTENT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              /// 🔹 TITLE
                              Text(
                                "About DigiGold Scheme",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 8),

                              /// 🔹 DESCRIPTION
                              Text(
                                "DigiGold Scheme is a flexible savings plan designed to help you invest in digital gold systematically. Save small amounts regularly and redeem them for beautiful jewellery at the end of your scheme period.",
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // PROCESS JOIN
                  const Text(
                    "Process to Join",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // STEP 1
                        Expanded(
                          child: Column(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF5A0015),
                                    Color(0xFFE6003A),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.person_add,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Join\nNow",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                          ),
                        ),

                        // DOTTED LINE
                        _stepConnector(),

                        // STEP 2
                        Expanded(
                          child: Column(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF5A0015),
                                    Color(0xFFE6003A),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.currency_rupee,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Enter\nAmount",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                          ),
                        ),

                        // DOTTED LINE
                        _stepConnector(),

                        // STEP 3
                        Expanded(
                          child: Column(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF5A0015),
                                    Color(0xFFE6003A),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.credit_card,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Make\nPayment",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // PROCESS REDEEM
                  const Text(
                    "Process to Redeem",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // STEP 1
                        Expanded(
                          child: Column(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF5A0015),
                                    Color(0xFFE6003A),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.store,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "visit\nStore",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                          ),
                        ),

                        // DOTTED LINE
                        _stepConnector(),

                        // STEP 2
                        Expanded(
                          child: Column(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF5A0015),
                                    Color(0xFFE6003A),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.description,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Provide\nDetails",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                          ),
                        ),

                        // DOTTED LINE
                        _stepConnector(),

                        // STEP 3
                        Expanded(
                          child: Column(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF5A0015),
                                    Color(0xFFE6003A),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "choose\nJewellery",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FEATURES
                  const Text(
                    "Key Features",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 12) / 2;
                      // Give cards more vertical room on smaller widths to avoid overflow.
                      final childAspectRatio = cardWidth < 170 ? 1.05 : 1.2;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                        children: [
                      // CARD 1
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFB8902E),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFFF1E4C8),
                              child: Icon(
                                Icons.currency_rupee,
                                color: Color(0xFFB8902E),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Minimum ₹100",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Start small, dream big",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CARD 2 (WITH GOLD BORDER)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFB8902E),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFFF1E4C8),
                              child: Icon(
                                Icons.calendar_today,
                                color: Color(0xFFB8902E),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "330 Days",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Fixed scheme period",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CARD 3
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFB8902E),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFFF1E4C8),
                              child: Icon(
                                Icons.savings,
                                color: Color(0xFFB8902E),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Flexible Savings",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Save at your pace",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CARD 4 (WITH BORDER)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFB8902E),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFFF1E4C8),
                              child: Icon(
                                Icons.shield,
                                color: Color(0xFFB8902E),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "100% Secure",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Safe & transparent",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // BENEFITS
                  const Text(
                    "Benefits",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  _benefit("10%", "Bonus on Completion"),
                  _benefit("₹0", "Zero Making Charges"),
                  _benefit("★", "Exclusive Collection"),

                  const SizedBox(height: 20),

                  // FAQ
                  const Text(
                    "Frequently Asked Questions",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  _faq("How do I join the scheme?"),
                  _faq("Can I change my installment amount?"),
                  _faq("What happens if I miss a payment?"),
                  _faq("Is my investment secure?"),

                  const SizedBox(height: 20),

                  // BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KYCScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5A0015), Color(0xFFE1094A)],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Join DigiGold Scheme Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                      const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepConnector() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dotCount = (constraints.maxWidth / 8).floor().clamp(6, 20);
            return Row(
              children: List.generate(
                dotCount,
                (index) => Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: index % 2 == 0
                        ? const Color(0xFFE6003A)
                        : Colors.transparent,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _benefit(String l, String t) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Text(
          l,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Text(t),
      ],
    ),
  );

  Widget _faq(String t) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t, style: const TextStyle(fontSize: 12)),
        const Icon(Icons.keyboard_arrow_down),
      ],
    ),
  );
}
