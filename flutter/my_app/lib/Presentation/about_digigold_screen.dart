import 'package:flutter/material.dart';
import 'package:my_app/Presentation/kyc_screen.dart';


class AboutDigigoldScreen extends StatefulWidget {
  const AboutDigigoldScreen({super.key, required this.scheme});

  final AboutSchemeData scheme;

  @override
  State<AboutDigigoldScreen> createState() => _AboutDigigoldScreenState();
}

class _AboutDigigoldScreenState extends State<AboutDigigoldScreen> {
  late final PageController _schemeController;

  int _schemePage = 0;

  final Map<int, bool> _expandedFaqs = {};

  late final List<AboutSchemeData> _schemes;

  // FAQ data list
  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I join the scheme?',
      'answer':
          'Joining the DigiGold scheme is simple! Tap the "Join DigiGold Scheme Now" button at the bottom of this screen. Complete your KYC verification, choose your savings amount and make your first payment.',
    },
    {
      'question': 'Can I change my installment amount?',
      'answer':
          'Yes, DigiGold offers flexible savings. You can choose any amount starting from the minimum scheme amount.',
    },
    {
      'question': 'What happens if I miss a payment?',
      'answer':
          'You will receive reminders via SMS and notifications. We recommend completing your installments on time.',
    },
    {
      'question': 'Is my investment secure?',
      'answer':
          'Absolutely! Your investment is secure and protected with safe storage and encrypted transactions.',
    },
  ];

  @override
  void initState() {
    super.initState();

    _schemes = [widget.scheme];

    _schemeController = PageController(initialPage: 0);

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
    final currentScheme = _schemes[_schemePage];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: Column(
        children: [
          /// HEADER
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

          /// BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP BANNER WITH PAGEVIEW
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _schemeController,
                      itemCount: _schemes.length,
                      onPageChanged: (index) {
                        setState(() {
                          _schemePage = index;
                        });
                      },
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

                                    const SizedBox(height: 10),

                                    Text(
                                      "• ${scheme.point1}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "• ${scheme.point2}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "• ${scheme.point3}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
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

                  const SizedBox(height: 10),

                  /// PAGE INDICATOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_schemes.length, (index) {
                      final active = index == _schemePage;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFE1094A)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  /// ABOUT
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
                            children: [
                              const Text(
                                "About DigiGold Scheme",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Start from ₹${currentScheme.minAmount}. "
                                "Lock-in period ${currentScheme.lockInPeriod} days. "
                                "Total scheme duration ${currentScheme.durationDays} days.",
                                style: const TextStyle(
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

                  const SizedBox(height: 20),

                  /// PROCESS JOIN
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
                              _stepIcon(Icons.person_add),
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
                              _stepIcon(Icons.currency_rupee),
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
                              _stepIcon(Icons.credit_card),
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

                  /// PROCESS REDEEM
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
                              _stepIcon(Icons.store),
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
                              _stepIcon(Icons.description),
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
                              _stepIcon(Icons.diamond),
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

                  /// FEATURES
                  const Text(
                    "Key Features",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _featureCard(
                        Icons.currency_rupee,
                        "Minimum ₹${currentScheme.minAmount}",
                        "Start saving easily",
                      ),

                      _featureCard(
                        Icons.calendar_today,
                        "${currentScheme.durationDays} Days",
                        "Scheme duration",
                      ),

                      _featureCard(
                        Icons.lock_clock,
                        "${currentScheme.lockInPeriod} Days",
                        "Lock-in period",
                      ),

                      _featureCard(
                        Icons.shield,
                        "100% Secure",
                        "Safe investment",
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// BENEFITS
                  const Text(
                    "Benefits",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  _benefit("10%", "Bonus on Completion"),

                  _benefit("₹0", "Zero Making Charges"),

                  _benefit("★", "Exclusive Collection"),

                  const SizedBox(height: 20),

                  /// FAQ
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

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isExpanded
                              ? const Color(0xFFE1094A).withOpacity(0.25)
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),

                        child: Column(
                          children: [
                            /// QUESTION
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedFaqs[index] = !isExpanded;
                                });
                              },

                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),

                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// NUMBER BADGE
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),

                                      height: 28,
                                      width: 28,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: isExpanded
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF5A0015),
                                                  Color(0xFFE1094A),
                                                ],
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  Colors.grey.shade300,
                                                  Colors.grey.shade400,
                                                ],
                                              ),
                                      ),

                                      child: Center(
                                        child: Text(
                                          "${index + 1}",
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

                                    const SizedBox(width: 12),

                                    /// QUESTION TEXT
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 3),

                                        child: Text(
                                          faq['question']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            fontWeight: isExpanded
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isExpanded
                                                ? const Color(0xFF2A0912)
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    /// ARROW
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),

                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),

                                        height: 28,
                                        width: 28,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isExpanded
                                              ? const Color(
                                                  0xFFE1094A,
                                                ).withOpacity(0.08)
                                              : Colors.grey.shade100,
                                        ),

                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 20,
                                          color: isExpanded
                                              ? const Color(0xFFE1094A)
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// ANSWER
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),

                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,

                              firstChild: const SizedBox.shrink(),

                              secondChild: Container(
                                width: double.infinity,

                                padding: const EdgeInsets.fromLTRB(
                                  54,
                                  0,
                                  14,
                                  16,
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      height: 1,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      color: const Color(
                                        0xFFE1094A,
                                      ).withOpacity(0.12),
                                    ),

                                    Text(
                                      faq['answer']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        height: 1.6,
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
                  const SizedBox(height: 10),

                  /// JOIN BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KYCScreen(
                            isSilverScheme: currentScheme.isSilverScheme,
                            schemeId: currentScheme.schemeId,
                            name: currentScheme.name,
                          ),
                        ),
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
        border: Border.all(color: const Color(0xFFB8902E), width: 1),
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

  Widget _stepIcon(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF5A0015), Color(0xFFE6003A)],
        ),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _benefit(String label, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 10),

          Text(text),
        ],
      ),
    );
  }
}


class AboutSchemeData {
  final String backgroundImage;
  final String sideImage;
  final String label;
  final String title;
  final String point1;
  final String point2;
  final String point3;
  final String schemeId;
  final String name;
  final bool isSilverScheme;
  final int minAmount;
  final int durationDays;
  final int lockInPeriod;

  const AboutSchemeData({
    required this.backgroundImage,
    required this.sideImage,
    required this.label,
    required this.title,
    required this.point1,
    required this.point2,
    required this.point3,
    required this.schemeId,
    required this.name,
    required this.isSilverScheme,
    required this.minAmount,
    required this.durationDays,
    required this.lockInPeriod,
  });
}
