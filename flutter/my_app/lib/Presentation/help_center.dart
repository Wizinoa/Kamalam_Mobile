// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class helpcenter extends StatefulWidget {
  const helpcenter({super.key});

  @override
  State<helpcenter> createState() => _helpcenterState();
}

class _helpcenterState extends State<helpcenter> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Track which topic index is expanded (-1 = none)
  int _expandedIndex = -1;

  final List<({IconData icon, String title, List<({String question, String answer})> faqs})>
      _allTopics = const [
    (
      icon: Icons.description,
      title: 'Savings Schemes',
      faqs: [
        (
          question: 'What is a Digigold Savings Scheme?',
          answer:
              'A Digigold Savings Scheme allows you to save gold digitally in small installments. You can choose monthly or weekly plans and accumulate gold over time without worrying about storage or purity.'
        ),
        (
          question: 'How do I enroll in a savings scheme?',
          answer:
              'Go to the Savings section in the app, select a scheme that suits your budget, and complete KYC if not already done. You can start with as little as ₹100 per installment.'
        ),
        (
          question: 'Can I withdraw my savings anytime?',
          answer:
              'Yes, you can redeem your accumulated gold at any time. Redemption options include physical gold delivery, jewellery exchange, or cash equivalent based on current market price.'
        ),
      ]
    ),
    (
      icon: Icons.app_registration,
      title: 'Digigold App User Guide',
      faqs: [
        (
          question: 'How do I register on the Digigold App?',
          answer:
              'Download the app, enter your mobile number, and verify via OTP. Then complete your profile by providing basic KYC details like PAN and Aadhaar to unlock all features.'
        ),
        (
          question: 'How do I buy gold through the app?',
          answer:
              'Tap the "Buy Gold" option on the home screen, enter the amount in rupees or grams, select your payment method (UPI, Net Banking, or Card), and confirm the transaction.'
        ),
        (
          question: 'Is my account secure?',
          answer:
              'Yes. The app uses 256-bit encryption and two-factor authentication. You can also enable biometric login (fingerprint/face ID) from the Security Settings for additional protection.'
        ),
      ]
    ),
    (
      icon: Icons.person,
      title: 'FAQ',
      faqs: [
        (
          question: 'Is Digigold safe and regulated?',
          answer:
              'Yes. Digigold is backed by certified 22K gold stored in insured vaults. All transactions are monitored and comply with applicable financial regulations in India.'
        ),
        (
          question: 'What are the charges or fees?',
          answer:
              'There are no hidden charges. A nominal GST of 3% applies on gold purchases as per government norms. No storage or maintenance fees are charged on your gold balance.'
        ),
        (
          question: 'How do I contact customer support?',
          answer:
              'You can reach our support team via live chat in the app, email at support@digigold.in, or call our helpline at 1800-XXX-XXXX, available 24/7.'
        ),
      ]
    ),
  ];

  TextStyle _poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.2,
    );
  }

  List<({IconData icon, String title, List<({String question, String answer})> faqs})>
      get _filteredTopics {
    if (_searchQuery.trim().isEmpty) return _allTopics;
    final query = _searchQuery.toLowerCase();
    return _allTopics
        .where((item) => item.title.toLowerCase().contains(query))
        .toList();
  }

  void _callNumber() async {
  final Uri phoneUri = Uri(scheme: 'tel', path: '8610676308');

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot open dialer')),
    );
  }
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 246, 246),
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                const SizedBox(width: 18),
                Text(
                  "Help Center",
                  style: _poppins(13, FontWeight.w600, Colors.white),
                ),
              ],
            ),
          ),

          // ── BODY ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _expandedIndex = -1; // collapse all on new search
                        });
                      },
                      style: _poppins(
                          12, FontWeight.w500, const Color(0xFF2A2A2A)),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        hintText: "Search for help, FAQs...",
                        hintStyle:
                            _poppins(12, FontWeight.w400, Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📦 Popular Topics Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Text(
                            "Popular Topics",
                            style: _poppins(
                                13, FontWeight.w700, const Color(0xFF1F1F1F)),
                          ),
                        ),

                        if (_filteredTopics.isEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Text(
                              'No topics found',
                              style: _poppins(
                                  12, FontWeight.w400, Colors.grey.shade600),
                            ),
                          )
                        else
                          ...List.generate(_filteredTopics.length, (index) {
                            final topic = _filteredTopics[index];
                            final isExpanded = _expandedIndex == index;

                            return Column(
                              children: [
                                // ── Topic Row (tap to expand) ──────
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _expandedIndex =
                                          isExpanded ? -1 : index;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(topic.icon,
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            topic.title,
                                            style: _poppins(
                                              13,
                                              FontWeight.w500,
                                              const Color(0xFF2A2A2A),
                                            ),
                                          ),
                                        ),
                                        AnimatedRotation(
                                          turns: isExpanded ? 0.5 : 0,
                                          duration: const Duration(
                                              milliseconds: 250),
                                          child: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ── Expanded FAQ Content ───────────
                                AnimatedCrossFade(
                                  firstChild: const SizedBox(width: double.infinity),
                                  secondChild: Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      children: List.generate(
                                          topic.faqs.length, (faqIndex) {
                                        final faq = topic.faqs[faqIndex];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      14, 12, 14, 6),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 2),
                                                    child: Icon(
                                                      Icons.help_outline,
                                                      size: 15,
                                                      color: Color(0xFFE1094A),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      faq.question,
                                                      style: _poppins(
                                                        12,
                                                        FontWeight.w600,
                                                        const Color(
                                                            0xFF1F1F1F),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      37, 0, 14, 12),
                                              child: Text(
                                                faq.answer,
                                                style: _poppins(
                                                  11,
                                                  FontWeight.w400,
                                                  Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                            if (faqIndex !=
                                                topic.faqs.length - 1)
                                              Divider(
                                                height: 1,
                                                color: Colors.grey.shade200,
                                                indent: 14,
                                                endIndent: 14,
                                              ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                  crossFadeState: isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration:
                                      const Duration(milliseconds: 300),
                                ),

                                if (index != _filteredTopics.length - 1)
                                  Divider(
                                      indent: 60,
                                      color: Colors.grey.shade300),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔥 Support Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0F172A),
                          Color(0xFF1E293B),
                          Color(0xFF3B2F1F),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Still need help?",
                          style: _poppins(13, FontWeight.w700, Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Our support team is available 24/7 to assist you with your queries.",
                          textAlign: TextAlign.center,
                          style:
                              _poppins(12, FontWeight.w400, Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _callNumber, // ✅ open dialer
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD4AF37),
                                  Color(0xFFFFD54F)
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.headset_mic,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  "Contact Support",
                                  style: _poppins(
                                      13, FontWeight.w700, Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}