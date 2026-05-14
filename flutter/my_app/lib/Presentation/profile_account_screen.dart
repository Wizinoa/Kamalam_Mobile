import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Presentation/about_kamalam_screen.dart';
import 'package:my_app/Presentation/help_center.dart';
import 'package:my_app/Presentation/instant_gold_transaction_screen.dart';
import 'package:my_app/Presentation/login_screen.dart';
import 'package:my_app/Presentation/otp_screen.dart';

import 'package:my_app/Presentation/profile_screen.dart';
import 'package:my_app/Presentation/savings_history.dart';
import 'package:my_app/Presentation/savings_target.dart';
import 'package:my_app/Presentation/terms_and_conditions.dart';
import 'package:my_app/Providers/user_provider.dart';
import 'package:my_app/Utils/back_screen.dart';
import 'package:my_app/Utils/bottom_navigation.dart';
import 'package:my_app/Utils/enum.dart';
import 'package:my_app/Utils/local_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsOn = true;

  Future<void> _openStoreDirections(BuildContext context) async {
    final Uri appUri = Uri.parse(
      'https://maps.app.goo.gl/fLLZZT4otqzXinhS7?g_st=ac',
    );

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open Google Maps')));
  }

  TextStyle _poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.2,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: AppBar(
          toolbarHeight: 88,
          elevation: 0,
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
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 243, 242, 242),
                        ), // red border
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_outline, // ✅ outline icon
                          size: 32,
                          color: Color.fromARGB(
                            255,
                            250,
                            249,
                            248,
                          ), // ✅ red icon
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final user = userProvider.user;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.fullName ?? ''}',
                              style: _poppins(
                                16,
                                FontWeight.w700,
                                Colors.white,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              user?.mobile ?? '',
                              style: _poppins(
                                12,
                                FontWeight.w400,
                                Colors.white70,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () => ExitDialog.show(context),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle('Account'),
                _sectionCard(
                  children: [
                    _menuTile(
                      Icons.person_outline,
                      'My Profile',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _divider(),
                    _menuTile(
                      Icons.lock_outline_rounded,
                      'Change MPIN',
                      onTap: () async {
                        final email = await LocalStorage.getEmail();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OtpScreen(
                              mobile: '',
                              email: email ?? "",
                              flow: OtpFlow.forgotMpin,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _sectionTitle('Savings'),
                _sectionCard(
                  children: [
                    _menuTile(
                      Icons.adjust_outlined,
                      'Set Savings Target',
                      iconBg: const Color(0xFF7A001E),
                      iconColor: Colors.white,

                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SavingsTarget(),
                          ),
                        );
                      },
                    ),
                    _divider(),
                    _menuTile(
                      Icons.history_toggle_off_rounded,
                      'Savings History',
                      iconBg: const Color(0xFF7A001E),
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SavingsHistory(),
                          ),
                        );
                      },
                    ),
                    _divider(),

                    _menuTile(
                      Icons.receipt_long,
                      'Gold Purchases',
                      iconColor: Colors.white,
                      isNew: true,
                      newTextColor: Colors.white,
                      onTap: () {
                         Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GoldTransactionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                _sectionTitle('Support'),
                _sectionCard(
                  children: [
                    _menuTile(
                      Icons.help_outline_rounded,
                      'Help Center',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const helpcenter()),
                        );
                      },
                    ),
                    _divider(),
                    _menuTile(
                      Icons.location_on_outlined,
                      'Store Locator',
                      onTap: () => _openStoreDirections(context),
                    ),
                    _divider(),
                    _menuTile(
                      Icons.info_outline_rounded,
                      'About Us',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _sectionTitle('Legal'),
                _sectionCard(
                  children: [
                    _menuTile(
                      Icons.article_outlined,
                      'Terms & Conditions',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsAndConditionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF3A0A13), Color(0xFFC6003A)],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await LocalStorage.clearToken();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(
                        'Logout',
                        style: _poppins(15, FontWeight.w700, Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Version 2.4.1',
                  textAlign: TextAlign.center,
                  style: _poppins(11, FontWeight.w400, Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  '@ 2026 Kamalam DigiGold. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: _poppins(10, FontWeight.w400, Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: AppBottomNavigation(currentIndex: 3),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(title, style: _poppins(13, FontWeight.w500, Colors.black54)),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }

  Widget _menuTile(
    IconData icon,
    String title, {
    String? trailingText,
    bool hasSwitch = false,

    // NEW BADGE
    bool isNew = false,

    String newText = "NEW",

    Color newBadgeColor = const Color(0xFFD4AF37),

    Color newTextColor = Colors.white,

    Color iconBg = const Color(0xFFD4AF37),

    Color iconColor = Colors.white,

    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(8),

        onTap: hasSwitch ? null : onTap,

        child: SizedBox(
          height: 54,

          child: Row(
            children: [
              // ICON
              Container(
                width: 30,
                height: 30,

                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, size: 16, color: iconColor),
              ),

              const SizedBox(width: 12),

              // TITLE
              Expanded(
                child: Text(
                  title,

                  style: _poppins(13, FontWeight.w500, const Color(0xFF2A2A2A)),
                ),
              ),

              // NEW BADGE
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),

                  decoration: BoxDecoration(
                    color: newBadgeColor,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    newText,

                    style: _poppins(9, FontWeight.w700, newTextColor),
                  ),
                ),

              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),

                  child: Text(
                    trailingText,

                    style: _poppins(11, FontWeight.w400, Colors.grey.shade500),
                  ),
                ),

              if (hasSwitch)
                Switch(
                  value: _notificationsOn,

                  onChanged: (value) =>
                      setState(() => _notificationsOn = value),

                  activeColor: const Color(0xFFD4AF37),

                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,

                  color: Colors.grey.shade500,

                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
