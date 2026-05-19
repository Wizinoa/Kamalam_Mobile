import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/Providers/terms_provider.dart';
import 'package:my_app/Models/terms_models.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0;
  late TabController _tabController;

  static const _headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedTab = _tabController.index;
        });
      }
    });
    
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TermsProvider>(context, listen: false);
      if (provider.termsList.isEmpty && provider.privacyList.isEmpty) {
        provider.fetchAll();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _Header(
            onBack: () => Navigator.maybePop(context),
            gradient: _headerGradient,
          ),
          Expanded(
            child: Consumer<TermsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.termsError != null || provider.privacyError != null) {
                  return _ErrorView(
                    termsError: provider.termsError,
                    privacyError: provider.privacyError,
                    onRetry: () => provider.fetchAll(),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SegmentedTabs(
                        selected: selectedTab,
                        onChanged: (value) {
                          setState(() => selectedTab = value);
                          _tabController.animateTo(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _IntroCard(showingPrivacy: selectedTab == 1),
                      const SizedBox(height: 14),
                      selectedTab == 0
                          ? _buildTermsList(provider.termsList)
                          : _buildPrivacyList(provider.privacyList),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          'Last updated: ${_getLastUpdatedDate()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsList(List<TermsModel> terms) {
    if (terms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No terms and conditions available',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return Column(
      children: terms.map((term) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ExpandedTile(
            icon: _getIconForTitle(term.title),
            title: term.title,
            description: term.content,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrivacyList(List<TermsModel> privacy) {
    if (privacy.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No privacy policy available',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return Column(
      children: privacy.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ExpandedTile(
            icon: _getIconForTitle(item.title),
            title: item.title,
            description: item.content,
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForTitle(String title) {
    // Map titles to appropriate icons
    if (title.contains('Eligibility') || title.contains('Usage')) {
      return Icons.person;
    } else if (title.contains('Company')) {
      return Icons.apartment;
    } else if (title.contains('Legal') || title.contains('Compliance')) {
      return Icons.shield_outlined;
    } else if (title.contains('Account')) {
      return Icons.handshake_outlined;
    } else if (title.contains('Prohibited')) {
      return Icons.block_outlined;
    } else if (title.contains('Information') && title.contains('Collect')) {
      return Icons.lock_outline;
    } else if (title.contains('Use Data')) {
      return Icons.visibility_outlined;
    } else if (title.contains('Sharing') || title.contains('Disclosure')) {
      return Icons.share_outlined;
    } else if (title.contains('Security')) {
      return Icons.security_outlined;
    } else if (title.contains('Privacy Rights')) {
      return Icons.manage_accounts_outlined;
    } else {
      return Icons.description_outlined;
    }
  }

  static String _getLastUpdatedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}

class _ErrorView extends StatelessWidget {
  final String? termsError;
  final String? privacyError;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.termsError,
    required this.privacyError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE11B4C),
            ),
            const SizedBox(height: 16),
            Text(
              termsError ?? privacyError ?? 'Failed to load content',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11B4C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
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
          const SizedBox(width: 12),
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

class _ExpandedTile extends StatelessWidget {
  const _ExpandedTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

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
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          children: [
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