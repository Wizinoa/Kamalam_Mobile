import 'package:flutter/material.dart';


class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool agree = false;
  int selectedTab = 0;

  static const _headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
  );


  static const _registrationItems = <_TermsItem>[
    _TermsItem(
      icon: Icons.person,
      title: 'Eligibility & Usage',
      description:
          'You must provide accurate details and use the app only for lawful investment activity. Misuse of features may lead to account restrictions.',
    ),
    _TermsItem(
      icon: Icons.apartment,
      title: 'Company Information',
      description:
          'Our platform is operated under applicable Indian laws and works with regulated partners for digital gold services and transaction processing.',
    ),
    _TermsItem(
      icon: Icons.shield_outlined,
      title: 'Legal Compliance',
      description:
          'By registering, you agree to comply with KYC norms, AML requirements, and all applicable financial and tax regulations.',
    ),
    _TermsItem(
      icon: Icons.handshake_outlined,
      title: 'Account Creation',
      description:
          'You are responsible for account credentials and all activities performed through your account, including safeguarding OTP and login access.',
    ),
    _TermsItem(
      icon: Icons.block_outlined,
      title: 'Prohibited Activities',
      description:
          'Fraud, impersonation, abusive use, or attempts to disrupt platform operations are prohibited and may result in immediate suspension.',
    ),
  ];

  static const _privacyItems = <_TermsItem>[
    _TermsItem(
      icon: Icons.lock_outline,
      title: 'Information We Collect',
      description:
          'We collect profile details, KYC information, transaction history, and device data necessary to verify identity and deliver secure services.',
    ),
    _TermsItem(
      icon: Icons.visibility_outlined,
      title: 'How We Use Data',
      description:
          'Your data helps us complete transactions, improve support, prevent fraud, and personalize communication relevant to your account.',
    ),
    _TermsItem(
      icon: Icons.share_outlined,
      title: 'Data Sharing & Disclosure',
      description:
          'We share limited data only with verified partners, payment providers, or legal authorities when required by law or service delivery.',
    ),
    _TermsItem(
      icon: Icons.security_outlined,
      title: 'Security & Protection',
      description:
          'We use encryption, secure infrastructure, and controlled access practices to protect your personal and financial information.',
    ),
    _TermsItem(
      icon: Icons.manage_accounts_outlined,
      title: 'Your Privacy Rights',
      description:
          'You can request profile updates, data access, or account closure by contacting support, subject to legal retention requirements.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final showingPrivacy = selectedTab == 1;
    final visibleItems = showingPrivacy ? _privacyItems : _registrationItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _Header(
            onBack: () => Navigator.maybePop(context),
            gradient: _headerGradient,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SegmentedTabs(
                    selected: selectedTab,
                    onChanged: (value) {
                      setState(() => selectedTab = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _IntroCard(showingPrivacy: showingPrivacy),
                  const SizedBox(height: 14),
                  ...visibleItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CollapsedTile(item: item),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'Last updated: January 15, 2024',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                  const SizedBox(height: 14),              
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.gradient});

  final VoidCallback onBack;
  final Gradient gradient;

  @override

  
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        18,
      ),
      decoration: BoxDecoration(gradient: gradient),
      child: Row(
        children: [
          _CircleButton(onTap: onBack),
          SizedBox(width: 12),
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  static const _gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              text: 'For Registration',
              selected: selected == 0,
              onTap: () => onChanged(0),
              gradient: _gradient,
            ),
          ),
          Expanded(
            child: _TabButton(
              text: 'Privacy Policy',
              selected: selected == 1,
              onTap: () => onChanged(1),
              gradient: _gradient,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.gradient,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.showingPrivacy});

  final bool showingPrivacy;

  @override
  Widget build(BuildContext context) {
    final title = showingPrivacy
        ? 'How we protect your privacy'
        : 'What are these terms?';
    final description = showingPrivacy
        ? 'This policy explains what information we collect,\nwhy we collect it, and how we keep your\npersonal and financial data protected.'
        : 'These terms explain how you can use our\ndigital gold platform, your rights, and our\nresponsibilities to keep your investments safe.';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0DE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFD6B449), Color(0xFFB8890D)],
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedTile extends StatelessWidget {
  const _CollapsedTile({required this.item});

  final _TermsItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DDE3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          childrenPadding: const EdgeInsets.fromLTRB(68, 0, 14, 14),
          iconColor: const Color(0xFF6B7280),
          collapsedIconColor: const Color(0xFF9CA3AF),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFD6B449), Color(0xFFB8890D)],
              ),
            ),
            child: Icon(item.icon, color: Colors.white, size: 21),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          children: [
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x33FFFFFF),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _TermsItem {
  const _TermsItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
