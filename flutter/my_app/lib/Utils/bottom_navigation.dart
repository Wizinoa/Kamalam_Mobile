import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Presentation/home_screen.dart';
import 'package:my_app/Presentation/notification_screen.dart';
import 'package:my_app/Presentation/passbook_screen.dart';
import 'package:my_app/Presentation/profile_account_screen.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  static const Color _accentRed = Color(0xFF9B1B30);
  static const Color _inactiveNav = Color(0xFF9CA8B8);
  static const Color _pillMaroon = Color(0xFF6B1420);
  static const Color _pillLight = Color(0xFFFFF8F8);

  TextStyle _poppins(double size, FontWeight w, Color c) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: w, color: c, height: 1.2);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final Widget page = switch (index) {
      0 => const HomeScreen(),
      1 => const NotificationScreen(),
      2 => const PassbookScreen(),
      _ => const AccountScreen(),
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            currentIndex == 0
                ? _activePill(icon: Icons.home_rounded, label: 'Home')
                : _icon(
                    icon: Icons.home_outlined,
                    onTap: () => _onTap(context, 0),
                  ),
            currentIndex == 1
                ? _activePill(icon: Icons.notifications_rounded, label: 'Alerts')
                : _icon(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _onTap(context, 1),
                  ),
            currentIndex == 2
                ? _activePill(
                    icon: Icons.receipt_long_rounded,
                    label: 'History',
                  )
                : _icon(
                    icon: Icons.receipt_long_outlined,
                    onTap: () => _onTap(context, 2),
                  ),
            currentIndex == 3
                ? _activePill(icon: Icons.person_rounded, label: 'Profile')
                : _icon(
                    icon: Icons.person_outline_rounded,
                    onTap: () => _onTap(context, 3),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _icon({required IconData icon, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: _inactiveNav, size: 25),
      splashRadius: 26,
    );
  }

  Widget _activePill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_pillMaroon, _pillLight],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _accentRed, size: 22),
          const SizedBox(width: 8),
          Text(label, style: _poppins(13, FontWeight.w700, _accentRed)),
        ],
      ),
    );
  }
}
