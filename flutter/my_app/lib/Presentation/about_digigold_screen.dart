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

  // FAQ expanded state tracker
  final Map<int, bool> _expandedFaqs = {};

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

  // FAQ data list
  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I join the scheme?',
      'answer':
          'Joining the DigiGold scheme is simple! Tap the "Join DigiGold Scheme Now" button at the bottom of this screen. Complete your KYC verification, choose your savings amount (minimum ₹100), and make your first payment. You\'re all set to start your gold savings journey!',
    },
    {
      'question': 'Can I change my installment amount?',
      'answer':
          'Yes, DigiGold offers flexible savings! You can choose any amount starting from ₹100 for each installment. However, once a scheme is started, the installment amount is fixed for that scheme period. You can start a new scheme with a different amount anytime.',
    },
    {
      'question': 'What happens if I miss a payment?',
      'answer':
          'Missing a payment won\'t immediately cancel your scheme. You will receive reminders via SMS and notifications. We recommend completing your installments on time to enjoy the full 10% bonus benefit at scheme completion. Persistent non-payment may result in scheme forfeiture as per terms.',
    },
    {
      'question': 'Is my investment secure?',
      'answer':
          'Absolutely! Your investment is 100% secure. DigiGold is backed by certified 22K pure gold stored in insured vaults. All transactions are fully transparent, and your account details are protected with bank-grade encryption. Zero storage charges apply throughout the scheme period.',
    },
  ];

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.initialCarouselPage.clamp(0, _schemes.length - 1);
    _schemePage = safeIndex;
    _schemeController = PageController(initialPage: safeIndex);

    // Initialize all FAQs as collapsed
    for (int i = 0; i < _faqs.length; i++) {
      _expandedFaqs[i] = false;
    }
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
                      onPageChanged:
                          (index) => setState(() => _schemePage = index),
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
                          color: active
                              ? const Color(0xFFE1094A)
                              : Colors.grey.shade400,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "About DigiGold Scheme",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
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
                        _stepConnector(),
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
                        _stepConnector(),
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
                                "Visit\nStore",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        _stepConnector(),
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
                        _stepConnector(),
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
                                "Choose\nJewellery",
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
                      final childAspectRatio = cardWidth < 170 ? 1.05 : 1.2;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _featureCard(Icons.currency_rupee, "Minimum ₹100",
                              "Start small, dream big"),
                          _featureCard(Icons.calendar_today, "330 Days",
                              "Fixed scheme period"),
                          _featureCard(
                              Icons.savings, "Flexible Savings", "Save at your pace"),
                          _featureCard(
                              Icons.shield, "100% Secure", "Safe & transparent"),
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

                  // FAQ SECTION
                  const Text(
                    "Frequently Asked Questions",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  // Expandable FAQ items
                  ...List.generate(_faqs.length, (index) {
                    final faq = _faqs[index];
                    final isExpanded = _expandedFaqs[index] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isExpanded
                            ? Border.all(
                                color: const Color(0xFFE1094A).withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            // Question row (always visible)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedFaqs[index] = !isExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    // Question number badge
                                    Container(
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isExpanded
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF5A0015),
                                                  Color(0xFFE1094A),
                                                ],
                                              )
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFFE0E0E0),
                                                  Color(0xFFBDBDBD),
                                                ],
                                              ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isExpanded
                                                ? Colors.white
                                                : Colors.black54,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Question text
                                    Expanded(
                                      child: Text(
                                        faq['question']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isExpanded
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isExpanded
                                              ? const Color(0xFF2A0912)
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    // Arrow icon with animation
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: isExpanded
                                            ? const Color(0xFFE1094A)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Answer (expandable)
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                    48, 0, 14, 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Divider line
                                    Container(
                                      height: 1,
                                      color: const Color(0xFFE1094A)
                                          .withOpacity(0.15),
                                      margin:
                                          const EdgeInsets.only(bottom: 10),
                                    ),
                                    Text(
                                      faq['answer']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        height: 1.55,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // JOIN BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => KYCScreen()),
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

  Widget _featureCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB8902E),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF1E4C8),
            child: Icon(icon, color: const Color(0xFFB8902E)),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
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
}