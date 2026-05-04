// ignore_for_file: unused_element_parameter, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:my_app/Presentation/home_screen.dart';
import 'package:my_app/Utils/back_screen.dart';
import 'package:my_app/Utils/bottom_navigation.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const _buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2B0A12), Color(0xFFE11B4C)],
  );

  void showCustomPopup(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🔹 TOP TEXT (DYNAMIC)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 BOTTOM TEXT (DYNAMIC)
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// 🔹 BANNER IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/img3.png",
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),

              /// ❌ CLOSE BUTTON
              Positioned(
                right: -10,
                top: -10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <_NotificationItem>[
      const _NotificationItem(
        timeAgo: '1 hour ago',
        title: 'உங்கள் தங்க சேமிப்பு\n₹2,500 சேர்ந்தது',
        message:
            'வாங்கிய தொகை உங்கள் கணக்கில்\nபாதுகாப்பாக சேமிக்கப்பட்டுள்ளது',
        cta: 'Gold Savings',
        icon: Icons.savings,
      ),
      const _NotificationItem(
        timeAgo: '3 hours ago',
        title: 'Special Birthday Offer!',
        message:
            'Get 5% extra gold on your next purchase.\nLimited time offer.',
        cta: 'Birthday',
        icon: Icons.card_giftcard,
      ),
      const _NotificationItem(
        timeAgo: '5 hours ago',
        title: 'தங்கம் விலை உயர்வு',
        message: 'இன்றைய தங்க விலை ₹6,250/கிராம்.\nசிறந்த நேரம் முதலீடு செய்ய',
        cta: 'Gold Savings',
        icon: Icons.show_chart,
      ),
      const _NotificationItem(
        timeAgo: '5 hours ago',
        title: 'தங்கம் விலை உயர்வு',
        message: 'இன்றைய தங்க விலை ₹6,250/கிராம்.\nசிறந்த நேரம் முதலீடு செய்ய',
        cta: 'Gold Savings',
        icon: Icons.show_chart,
      ),
      const _NotificationItem(
        timeAgo: '5 hours ago',
        title: 'தங்கம் விலை உயர்வு',
        message: 'இன்றைய தங்க விலை ₹6,250/கிராம்.\nசிறந்த நேரம் முதலீடு செய்ய',
        cta: 'Gold Savings',
        icon: Icons.show_chart,
      ),
      const _NotificationItem(
        timeAgo: '5 hours ago',
        title: 'தங்கம் விலை உயர்வு',
        message: 'இன்றைய தங்க விலை ₹6,250/கிராம்.\nசிறந்த நேரம் முதலீடு செய்ய',
        cta: 'Gold Savings',
        icon: Icons.show_chart,
      ),
      const _NotificationItem(
        timeAgo: '5 hours ago',
        title: 'தங்கம் விலை உயர்வு',
        message: 'இன்றைய தங்க விலை ₹6,250/கிராம்.\nசிறந்த நேரம் முதலீடு செய்ய',
        cta: 'Gold Savings',
        icon: Icons.show_chart,
      ),
      const _NotificationItem(
        timeAgo: '5 hours ago',
        title: 'தங்கம் விலை உயர்வு',
        message: 'இன்றைய தங்க விலை ₹6,250/கிராம்.\nசிறந்த நேரம் முதலீடு செய்ய',
        cta: 'Gold Savings',
        icon: Icons.show_chart,
      ),
    ];


      return WillPopScope(
  onWillPop: () => ExitDialog.show(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: Column(
          children: [
            _Header(
              onBack: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    ...items.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _NotificationCard(
                          item: e,
                          buttonGradient: _buttonGradient,
                          onTapCta: () {
                            showCustomPopup(
                              context,
                              title: e.title,
                              message: e.message,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: AppBottomNavigation(currentIndex: 1),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  static const _headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2B0A12), Color(0xFFE11B4C)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _headerGradient),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 18,
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.arrow_back, onTap: onBack),
          const Spacer(),
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}



class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.buttonGradient,
    required this.onTapCta,
  });

  final _NotificationItem item;
  final Gradient buttonGradient;
  final VoidCallback onTapCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GoldIcon(icon: item.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.timeAgo,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GradientButton(
            text: item.cta,
            gradient: buttonGradient,
            onTap: onTapCta,
          ),
        ],
      ),
    );
  }
}

class _GoldIcon extends StatelessWidget {
  const _GoldIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2CC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFFC28B00), size: 22),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.text,
    required this.gradient,
    required this.onTap,
  });

  final String text;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 20,
    this.backgroundColor = const Color(0x1FFFFFFF),
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.timeAgo,
    required this.title,
    required this.message,
    required this.cta,
    required this.icon,
  });

  final String timeAgo;
  final String title;
  final String message;
  final String cta;
  final IconData icon;
}
