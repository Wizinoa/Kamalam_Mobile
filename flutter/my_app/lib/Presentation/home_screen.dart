// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Models/savings_models.dart';
import 'package:my_app/Presentation/about_digigold_screen.dart';
import 'package:my_app/Presentation/kyc_screen.dart';
import 'package:my_app/Providers/banner_provider.dart';
import 'package:my_app/Providers/gold_Provider.dart';
import 'package:my_app/Providers/savings_details_provider.dart';
import 'package:my_app/Providers/scheme_provider.dart';
import 'package:my_app/Utils/back_screen.dart';
import 'package:my_app/Utils/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _DashboardSchemeTabData {
  final String title;
  final List<SavingsSummaryModel> items;
  final IconData icon;

  const _DashboardSchemeTabData({
    required this.title,
    required this.items,
    required this.icon,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Banner popup ──
  bool _popupShown = false;
  static const Duration _popupDelay = Duration(seconds: 2);
  static const Duration _popupSlide = Duration(milliseconds: 650);

  // ── Dashboard carousel ──
  final PageController _dashboardController = PageController(
    viewportFraction: 1,
  );
  int _dashboardPage = 0;
  int _dashboardSelectedTabIndex = 0;

  // ── Metal price carousel ──
  final PageController _metalController = PageController(viewportFraction: 1);
  int _metalPage = 0;

  static const Color _maroonLeft = Color(0xFFC6003A);
  static const Color _maroonRight = Color(0xFF27080D);
  static const Color _silverDark = Color(0xFF29323C);
  bool _isPlaying = false;
  late YoutubePlayerController _controller;

  // ── Karat selection for the top Gold card ──
  static const List<String> _goldKarats = ['18K', '22K', '24K'];
  static const Map<String, double> _goldKaratValue = {
    '18K': 18,
    '22K': 22,
    '24K': 24,
  };
  static const double _goldBaseKarat = 22; // rate returned by the API

  String _selectedKarat = '22K';

  // ── Saving Schemes: Gold / Silver dropdown ──
  static const List<String> _metals = ['Gold', 'Silver'];
  String _selectedMetal = 'Gold';

  bool get _isSilverSelected => _selectedMetal == 'Silver';

  TextStyle _poppins(double size, FontWeight w, Color c) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: w, color: c, height: 1.2);

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

  String formatIndianCurrency(num number) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return formatter.format(number);
  }

  void _callNumber() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '8610676308');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open dialer')));
    }
  }

  /// Waits for the data and for the 2 second delay, then shows the popup.
  Future<void> _loadAndShowPopup() async {
    await Future.wait([_loadAll(), Future<void>.delayed(_popupDelay)]);
    if (!mounted || _popupShown) return;

    // Do not pop up over another screen the user has already opened.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    final banners = Provider.of<BannerProvider>(context, listen: false).banners;
    final images = [for (final b in banners) b.bannerImage];
    if (images.isEmpty) return;

    _popupShown = true;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close banner',
      barrierColor: Colors.black54,
      transitionDuration: _popupSlide,
      pageBuilder: (dialogContext, _, __) => _BannerPopup(images: images),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  /// Loads (or reloads) everything shown on the home screen.
  Future<void> _loadAll() async {
    final gold = Provider.of<GoldPriceProvider>(context, listen: false);
    final banners = Provider.of<BannerProvider>(context, listen: false);
    final schemes = Provider.of<SchemeProvider>(context, listen: false);
    final savings = Provider.of<SavingsProvider>(context, listen: false);

    await Future.wait([
      Future<void>.sync(() => gold.fetchGoldPrice()),
      Future<void>.sync(() => banners.fetchBanners()),
      Future<void>.sync(() => schemes.fetchSchemes()),
      Future<void>.sync(() => savings.fetchSavingsDetails()),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'jLCQfQCijJw',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: true,
        enableCaption: false,
      ),
    );
    Future.microtask(_loadAndShowPopup);
  }

  @override
  void dispose() {
    _controller.dispose();
    _dashboardController.dispose();
    _metalController.dispose();
    super.dispose();
  }

  // ── Shared dot-indicator builder ──
  Widget _dotIndicator({
    required int count,
    required int currentPage,
    Color activeColor = _maroonRight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: on ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: on ? activeColor : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  // ============================================================
  // KARAT HELPERS (18K / 22K / 24K)
  // ============================================================

  /// Price for one gram of gold at the chosen karat.
  num _goldPriceFor(num base22, String karat) {
    final k = _goldKaratValue[karat] ?? _goldBaseKarat;
    return base22 * k / _goldBaseKarat;
  }

  Future<void> _showPuritySheet({
    required String title,
    required List<String> options,
    required String selected,
    required num Function(String option) priceOf,
    required String Function(String option) labelOf,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: _poppins(17, FontWeight.w700, const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 12),
                for (final option in options)
                  _purityTile(
                    label: labelOf(option),
                    price: priceOf(option),
                    isSelected: option == selected,
                    onTap: () {
                      onSelected(option);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _purityTile({
    required String label,
    required num price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF4F7) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _maroonLeft : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: _poppins(15, FontWeight.w600, const Color(0xFF1A1A1A)),
                ),
              ),
              Text(
                '₹${formatIndianCurrency(price)} / g',
                style: _poppins(14, FontWeight.w600, const Color(0xFF444444)),
              ),
              const SizedBox(width: 10),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? _maroonLeft : Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One of the two small cards at the top (Gold / Silver).
  Widget _topMetalCard({
    required String backgroundImage,
    required String iconImage,
    required String title,
    required num sellPrice,
    required String unitText,
    required EdgeInsets padding,
    VoidCallback? onTap, // null = card is not tappable
  }) {
    return Expanded(
      child: Padding(
        padding: padding,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(backgroundImage, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Image.asset(iconImage, height: 30, width: 30),
                  ),
                  if (onTap != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${formatIndianCurrency(sellPrice)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          unitText,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navLift = 16.0 + bottomInset;
    return WillPopScope(
      onWillPop: () => ExitDialog.show(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: _maroonLeft,
          extendBody: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [_maroonRight, _maroonLeft],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      flex: 42,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            Consumer<GoldPriceProvider>(
                              builder: (context, provider, child) {
                                final goldBase =
                                    provider.goldData?.sellPrice ?? 0;
                                final silverBase =
                                    provider.silverData?.sellPrice ?? 0;

                                return Row(
                                  children: [
                                    /// 🔶 GOLD CARD (tap to pick 18K / 22K / 24K)
                                    _topMetalCard(
                                      backgroundImage: 'assets/images/img6.png',
                                      iconImage: 'assets/images/img11.png',
                                      title: 'Gold $_selectedKarat',
                                      sellPrice: _goldPriceFor(
                                        goldBase,
                                        _selectedKarat,
                                      ),
                                      unitText: '${_selectedKarat}T Per gram',
                                      padding: const EdgeInsets.only(right: 8),
                                      onTap: () => _showPuritySheet(
                                        title: 'Select Gold Purity',
                                        options: _goldKarats,
                                        selected: _selectedKarat,
                                        labelOf: (k) => '$k Gold',
                                        priceOf: (k) =>
                                            _goldPriceFor(goldBase, k),
                                        onSelected: (k) =>
                                            setState(() => _selectedKarat = k),
                                      ),
                                    ),

                                    /// 🔶 SILVER CARD (plain, not tappable)
                                    _topMetalCard(
                                      backgroundImage: 'assets/images/img7.png',
                                      iconImage: 'assets/images/img10.png',
                                      title: 'Silver',
                                      sellPrice: silverBase,
                                      unitText: 'Per gram',
                                      padding: const EdgeInsets.only(right: 8),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 150,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        child: ColoredBox(
                          color: Colors.white,
                          child: RefreshIndicator(
                            color: _maroonLeft,
                            backgroundColor: Colors.white,
                            onRefresh: _loadAll,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                18,
                                14,
                                18,
                                navLift + 76,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── Live data of the selected metal ──
                                  _metalDataCard(),
                                  const SizedBox(height: 14),

                                  Consumer<GoldPriceProvider>(
                                    builder: (context, provider, child) {
                                      final gold = provider.goldData;
                                      final stamp =
                                          '${gold?.date ?? ''} ${gold?.time ?? ''}'
                                              .trim();
                                      if (stamp.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        'Rate updated on $stamp',
                                        textAlign: TextAlign.center,
                                        style: _poppins(
                                          11,
                                          FontWeight.w400,
                                          Colors.grey.shade600,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // ── Dashboard carousel + dots ──
                                  _dashboardCarousel(context),
                                  const SizedBox(height: 20),

                                  // ── Saving Schemes header + Gold/Silver dropdown ──
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Saving Schemes',
                                          style: _poppins(
                                            17,
                                            FontWeight.w700,
                                            const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                      _metalDropdown(),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // // ── Live data carousel (Gold & Silver) ──
                                  // _metalDataCard(),
                                  // const SizedBox(height: 14),

                                  // ── Daily / Monthly / Anytime (selected metal only) ──
                                  _savingSchemeTypeCards(context),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Visit Our Showroom',
                                    style: _poppins(
                                      17,
                                      FontWeight.w700,
                                      const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _showroomCard(context),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Learn About Gold Investment',
                                    style: _poppins(
                                      17,
                                      FontWeight.w700,
                                      const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _learnCard(context),
                                  const SizedBox(height: 20),
                                  _needHelpCard(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 5,
                right: 5,
                bottom: 8,
                child: const AppBottomNavigation(currentIndex: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dashboard: Daily / Monthly / Anytime user savings tabs ──
  Widget _dashboardCarousel(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final savingsList = provider.savingsList;

        if (savingsList.isEmpty) {
          return const SizedBox.shrink();
        }

        // Read the scheme type from the model when available. For older API
        // responses, fall back to the scheme name. This keeps the dashboard
        // independent from the Saving Schemes section below.
        String getDashboardSchemeType(SavingsSummaryModel item) {
          String normalise(dynamic value) {
            final valueText = value?.toString().trim().toLowerCase() ?? '';
            if (valueText == 'daily' ||
                valueText == 'monthly' ||
                valueText == 'anytime') {
              return valueText;
            }
            return '';
          }

          try {
            final dynamic dynamicItem = item;
            final fromSchemaType = normalise(dynamicItem.schemaType);
            if (fromSchemaType.isNotEmpty) return fromSchemaType;
          } catch (_) {
            // Older SavingsSummaryModel versions may not expose schemaType.
          }

          final searchableName =
              '${item.schemeName} ${item.name}'.toLowerCase();

          if (searchableName.contains('monthly')) return 'monthly';
          if (searchableName.contains('anytime')) return 'anytime';
          if (searchableName.contains('daily')) return 'daily';

          // Keep older records visible when their API response does not
          // include a recognisable scheme type.
          return 'daily';
        }

        final dailyItems = savingsList
            .where((item) => getDashboardSchemeType(item) == 'daily')
            .toList();
        final monthlyItems = savingsList
            .where((item) => getDashboardSchemeType(item) == 'monthly')
            .toList();
        final anytimeItems = savingsList
            .where((item) => getDashboardSchemeType(item) == 'anytime')
            .toList();

        final tabs = <_DashboardSchemeTabData>[
          _DashboardSchemeTabData(
            title: 'Daily',
            items: dailyItems,
            icon: Icons.today_rounded,
          ),
          _DashboardSchemeTabData(
            title: 'Monthly',
            items: monthlyItems,
            icon: Icons.calendar_month_rounded,
          ),
          _DashboardSchemeTabData(
            title: 'Anytime',
            items: anytimeItems,
            icon: Icons.account_balance_wallet_rounded,
          ),
        ];

        return StatefulBuilder(
          builder: (context, setTabState) {
            // The selected tab is local to this dashboard carousel. It does
            // not change the Saving Schemes section or the selected metal.
            int selectedTab = _dashboardSelectedTabIndex;
            final selectedItems = tabs[selectedTab].items;

            Widget tabButton(int index) {
              final tab = tabs[index];
              final isSelected = selectedTab == index;
              final selectedColor = _maroonLeft;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (selectedTab == index) return;

                    setTabState(() {
                      _dashboardSelectedTabIndex = index;
                      _dashboardPage = 0;
                    });

                    if (_dashboardController.hasClients) {
                      _dashboardController.jumpToPage(0);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor
                          : const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: isSelected
                            ? selectedColor
                            : const Color(0xFFE9E9EC),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            11.5,
                            FontWeight.w700,
                            isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tab.items.length} ${tab.items.length == 1 ? 'scheme' : 'schemes'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            9,
                            FontWeight.w500,
                            isSelected ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (selectedItems.isEmpty) {
              return Column(
                children: [
                  Row(
                    children: [
                      tabButton(0),
                      const SizedBox(width: 8),
                      tabButton(1),
                      const SizedBox(width: 8),
                      tabButton(2),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 25,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEDEDEF)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          tabs[selectedTab].icon,
                          size: 30,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No ${tabs[selectedTab].title} savings found',
                          textAlign: TextAlign.center,
                          style: _poppins(
                            13,
                            FontWeight.w600,
                            Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your ${tabs[selectedTab].title.toLowerCase()} savings will appear here.',
                          textAlign: TextAlign.center,
                          style: _poppins(
                            11,
                            FontWeight.w400,
                            Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    tabButton(0),
                    const SizedBox(width: 8),
                    tabButton(1),
                    const SizedBox(width: 8),
                    tabButton(2),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    key: ValueKey('dashboard-tab-$selectedTab'),
                    controller: _dashboardController,
                    itemCount: selectedItems.length,
                    onPageChanged: (index) {
                      setTabState(() {
                        _dashboardPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _dashboardCard(context, selectedItems[index]);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _dotIndicator(
                  count: selectedItems.length,
                  currentPage: _dashboardPage.clamp(
                    0,
                    selectedItems.length - 1,
                  ).toInt(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dashboardCard(BuildContext context, SavingsSummaryModel data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.assetType.toLowerCase() == "silver"
              ? [const Color(0xFF485563), const Color(0xFF29323C)]
              : [_maroonRight, _maroonLeft],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// TOP SECTION
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: _poppins(16, FontWeight.w700, Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${data.schemeId}',
                      style: _poppins(10, FontWeight.w400, Colors.white70),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'SRI KAMALAM',
                        style: _poppins(9, FontWeight.w600, Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: data.status == "completed"
                              ? Colors.green
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        data.status.toUpperCase(),
                        style: _poppins(10, FontWeight.w700, Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// STATS
          Row(
            children: [
              Expanded(
                child: _glassStat(
                  'Weight Saved',
                  '${(data.totalGoldAccumulated * (1 - 0.03)).toStringAsFixed(4)} g',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _glassStat(
                  'Benefit Earned',
                  '${data.benefitEarned.toStringAsFixed(4)} g',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _glassStat(
                  'Rewards Earned',
                  '${data.rewardsEarned.toStringAsFixed(4)} g',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// DIVIDER
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),

          const SizedBox(height: 12),

          /// BOTTOM SECTION
          Row(
            children: [
              /// LEFT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total ${data.assetType} Saved',
                        style: _poppins(10, FontWeight.w500, Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(data.totalGoldAccumulated * (1 - 0.03)).toStringAsFixed(4)} g',
                      style: _poppins(22, FontWeight.w800, Colors.white),
                    ),
                  ],
                ),
              ),

              /// RIGHT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Scheme',
                      style: _poppins(9, FontWeight.w400, Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.schemeName,
                      textAlign: TextAlign.end,
                      style: _poppins(11, FontWeight.w600, Colors.white),
                    ),
                    const SizedBox(height: 6),
                    if (data.targetAchievedPercentage > 0)
                      Text(
                        'Target Achieved',
                        style: _poppins(10, FontWeight.w600, Colors.white),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// PROGRESS
          if (data.targetAchievedPercentage > 0)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: data.targetAchievedPercentage / 100,
                      minHeight: 5,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF2ECC71),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(data.targetAchievedPercentage > 100 ? 100 : data.targetAchievedPercentage).toStringAsFixed(0)}%',
                  style: _poppins(10, FontWeight.w700, Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _glassStat(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: _poppins(9, FontWeight.w400, Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(value, style: _poppins(11, FontWeight.w700, Colors.white)),
        ],
      ),
    );
  }

  // ============================================================
  // SAVING SCHEMES  -  Gold / Silver dropdown
  // ============================================================

  /// Small dropdown (Gold / Silver) shown next to "Saving Schemes".
  Widget _metalDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSilverSelected ? Colors.grey.shade500 : _maroonLeft,
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMetal,
          isDense: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _isSilverSelected ? Colors.grey.shade700 : _maroonLeft,
          ),
          items: [
            for (final m in _metals)
              DropdownMenuItem<String>(
                value: m,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: m == 'Silver'
                            ? const Color(0xFFB0B7C3)
                            : const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      m,
                      style: _poppins(
                        13,
                        FontWeight.w600,
                        const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (v) {
            if (v == null || v == _selectedMetal) return;
            setState(() => _selectedMetal = v);
          },
        ),
      ),
    );
  }

  /// Live data carousel for Gold and Silver prices.
  Widget _metalDataCard() {
    return Consumer<GoldPriceProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            SizedBox(
              height: 90,
              child: PageView.builder(
                controller: _metalController,
                itemCount: 2,
                onPageChanged: (i) {
                  setState(() {
                    _metalPage = i;
                  });
                },
                itemBuilder: (context, index) {
                  final isSilver = index == 1;

                  final num base = isSilver
                      ? (provider.silverData?.sellPrice ?? 0)
                      : (provider.goldData?.sellPrice ?? 0);
                  final String date =
                      (isSilver
                          ? provider.silverData?.date
                          : provider.goldData?.date) ??
                      '';
                  final String time =
                      (isSilver
                          ? provider.silverData?.time
                          : provider.goldData?.time) ??
                      '';
                  final stamp = '$date $time'.trim();

                  final num price = isSilver
                      ? base
                      : _goldPriceFor(base, _selectedKarat);
                  final label = isSilver
                      ? '999 Live Silver Rate'
                      : '$_selectedKarat Live Gold Rate';

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSilver
                          ? const Color(0xFFF4F5F7)
                          : const Color(0xFFF8F1E5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSilver
                            ? const Color(0xFFD7DCE2)
                            : const Color(0xFFE9DAB8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: isSilver
                                ? const Color(0xFFE2E6EC)
                                : const Color(0xFFF2DA96),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Image.asset(
                            isSilver
                                ? 'assets/images/img10.png'
                                : 'assets/images/img11.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: _poppins(
                                  12,
                                  FontWeight.w500,
                                  const Color(0xFF6F6F6F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${formatIndianCurrency(price)}',
                                    style: _poppins(
                                      22,
                                      FontWeight.w700,
                                      const Color(0xFF101010),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      '/gram',
                                      style: _poppins(
                                        12,
                                        FontWeight.w500,
                                        const Color(0xFF7B7B7B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (stamp.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      height: 7,
                                      width: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF18C45C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Updated $stamp',
                                        overflow: TextOverflow.ellipsis,
                                        style: _poppins(
                                          10.5,
                                          FontWeight.w400,
                                          const Color(0xFF888888),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
            _dotIndicator(count: 2, currentPage: _metalPage),
          ],
        );
      },
    );
  }

  /// Schemes that belong to the metal selected in the dropdown.
  List<dynamic> _schemesForSelectedMetal(SchemeProvider provider) {
    final metal = _selectedMetal.toLowerCase();
    return provider.schemes
        .where(
          (s) =>
              s.assetType.toString().toLowerCase() == metal &&
              s.isActive == true,
        )
        .toList();
  }

  /// Which card a scheme belongs to: 'daily' / 'monthly' / 'anytime'.
  /// Uses the backend `schema_type`. Old schemes (schema_type "gold" or
  /// "silver") fall back to the name, and then to 'daily'.
  String _typeOf(dynamic s) {
    final t = s.schemaType.toString().toLowerCase();
    if (t == 'daily' || t == 'monthly' || t == 'anytime') return t;
    final n = s.name.toString().toLowerCase();
    if (n.contains('monthly')) return 'monthly';
    if (n.contains('anytime')) return 'anytime';
    return 'daily';
  }

  /// Duration in months (durationMonths, else durationDays / 30, else 11).
  int _monthsOf(dynamic s) {
    final int m = (s.durationMonths ?? 0) as int;
    if (m > 0) return m;
    final int d = (s.durationDays ?? 0) as int;
    return d >= 30 ? (d / 30).round() : 11;
  }

  /// "22K gold" / "18K gold" / "silver" - shown inside the card text.
  String _assetLabel(dynamic s) {
    final p = (s.purity ?? '').toString().trim();
    if (_isSilverSelected || p.isEmpty) return _selectedMetal.toLowerCase();
    return '${p.toUpperCase()} gold';
  }

  // ============================================================
  // STATIC TEST DATA  (set to false to use the backend schemes)
  // ============================================================
  static const bool _useStaticSchemeData = false;

  List<dynamic> _staticSchemes(String type, List<int> amounts) {
    final asset = _isSilverSelected ? 'silver' : 'gold';
    return [
      for (final a in amounts)
        _StaticScheme(
          id: 'static-$type-$asset-$a',
          name:
              '${type[0].toUpperCase()}${type.substring(1)} $_selectedMetal Scheme $a',
          assetType: asset,
          schemaType: type,
          minDailyDeposit: a,
        ),
    ];
  }

  /// Fake Daily schemes (₹100 and ₹500).
  List<dynamic> _staticDailySchemes() => _staticSchemes('daily', [100, 500]);

  /// Fake Monthly schemes (change the amounts as you like).
  List<dynamic> _staticMonthlySchemes() =>
      _staticSchemes('monthly', _isSilverSelected ? [500, 1000] : [1000, 2000]);

  /// Fake Anytime schemes (change the amounts as you like).
  List<dynamic> _staticAnytimeSchemes() => _staticSchemes(
    'anytime',
    _isSilverSelected ? [500, 1000] : [5000, 10000],
  );

  /// All schemes of one type (daily / monthly / anytime),
  /// sorted by minimum amount - lowest first.
  List<dynamic> _schemesOfType(List<dynamic> schemes, String type) {
    final list = schemes.where((s) => _typeOf(s) == type).toList();
    list.sort((a, b) {
      final num x = (a.minDailyDeposit ?? 0) as num;
      final num y = (b.minDailyDeposit ?? 0) as num;
      return x.compareTo(y);
    });
    return list;
  }

  /// START / PAY button -> KYC flow.
  void _startScheme(dynamic scheme) {
    final isSilver = scheme.assetType.toString().toLowerCase() == 'silver';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KYCScreen(
          isSilverScheme: isSilver,
          schemeId: scheme.id,
          name: scheme.name,
          maturityDate: scheme.maturityDate,
        ),
      ),
    );
  }

  /// KNOW MORE button -> About screen.
  void _knowMoreScheme({
    required dynamic scheme,
    required String title,
    required List<String> points,
  }) {
    final isSilver = scheme.assetType.toString().toLowerCase() == 'silver';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AboutDigigoldScreen(
          scheme: AboutSchemeData(
            backgroundImage: isSilver
                ? 'assets/images/img27.png'
                : 'assets/images/img13.png',
            sideImage: isSilver
                ? 'assets/images/img10.png'
                : 'assets/images/img9.png',
            label: isSilver ? 'DigiSilver Savings' : 'DigiGold Savings',
            title: title,
            point1: points[0],
            point2: points[1],
            point3: points[2],
            schemeId: scheme.id,
            name: scheme.name,
            isSilverScheme: isSilver,
            minAmount: scheme.minDailyDeposit,
            durationDays: scheme.durationDays,
            lockInPeriod: scheme.lockInPeriod,
            maturityDate: scheme.maturityDate,
          ),
        ),
      ),
    );
  }

  /// Puts several scheme cards next to each other (swipe sideways) with
  /// dot indicators below. The next card peeks in from the right.
  Widget _sideBySideCards(BuildContext context, List<Widget> cards) {
    return _SideBySideCards(
      cards: cards,
      activeColor: _isSilverSelected ? _silverDark : _maroonLeft,
    );
  }

  /// Daily / Monthly / Anytime cards for the metal chosen in the dropdown.
  Widget _savingSchemeTypeCards(BuildContext context) {
    return Consumer<SchemeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final isSilver = _isSilverSelected;
        final metalWord = _selectedMetal.toLowerCase(); // gold / silver
        final schemes = _schemesForSelectedMetal(provider);

        // Schemes for each card (static test data or backend data).
        final List<dynamic> dailySchemes = _useStaticSchemeData
            ? _staticDailySchemes()
            : _schemesOfType(schemes, 'daily');
        final List<dynamic> monthlySchemes = _useStaticSchemeData
            ? _staticMonthlySchemes()
            : _schemesOfType(schemes, 'monthly');
        final List<dynamic> anytimeSchemes = _useStaticSchemeData
            ? _staticAnytimeSchemes()
            : _schemesOfType(schemes, 'anytime');

        if (dailySchemes.isEmpty &&
            monthlySchemes.isEmpty &&
            anytimeSchemes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No $_selectedMetal schemes available right now',
              textAlign: TextAlign.center,
              style: _poppins(13, FontWeight.w500, Colors.grey.shade600),
            ),
          );
        }

        // Colours change with the selected metal.
        final darkGradient = isSilver
            ? const [Color(0xFF485563), Color(0xFF29323C)]
            : const [Color(0xFF8A0A2A), Color(0xFFD1004B)];
        final lightGradient = isSilver
            ? const [Color(0xFFF4F5F7), Color(0xFFD5DAE1)]
            : const [Color(0xFFFFF6DE), Color(0xFFF7DC93)];
        final accent = isSilver ? _silverDark : _maroonLeft;
        final lightAccent = isSilver ? _silverDark : const Color(0xFF8A0A2A);
        final lightButton = isSilver
            ? const [Color(0xFF485563), Color(0xFF29323C)]
            : const [_maroonRight, _maroonLeft];

        // ── One DAILY card per scheme ──
        Widget buildDaily(dynamic d) {
          final dailyPoints = [
            'Start from as low as ₹${d.minDailyDeposit}',
            'Automatic daily savings',
            'Flexible & secure',
          ];
          return _schemeTypeCard(
            title: 'Daily $_selectedMetal Scheme',
            description:
                'Save a small amount daily to build your ${_assetLabel(d)} savings.',
            points: dailyPoints,
            buttonText: d.joined == true ? 'Pay Now' : 'Join Now',
            isJoined: d.joined == true,
            icon: Icons.savings_outlined,
            illustration: 'assets/images/scheme_daily.png',
            gradient: darkGradient,
            lightCard: false,
            accent: accent,
            buttonGradient: lightButton,
            onTap: () => _startScheme(d),
            onKnowMore: () => _knowMoreScheme(
              scheme: d,
              title: 'Daily $_selectedMetal Scheme',
              points: dailyPoints,
            ),
          );
        }

        // ── One MONTHLY card per scheme ──
        Widget buildMonthly(dynamic m) {
          final months = _monthsOf(m);
          final monthlyPoints = [
            'Invest ₹${m.minDailyDeposit} monthly for $months months',
            'One time lock-in period',
            'Higher ${_assetLabel(m)} savings',
          ];
          return _schemeTypeCard(
            title: 'Monthly $_selectedMetal Scheme',
            description:
                'One time payment for $months months with lock-in period.',
            points: monthlyPoints,
            buttonText: m.joined == true ? 'Pay Now' : 'Join Now',
            isJoined: m.joined == true,
            icon: Icons.calendar_month_rounded,
            illustration: 'assets/images/scheme_monthly.png',
            gradient: lightGradient,
            lightCard: true,
            accent: lightAccent,
            buttonGradient: lightButton,
            onTap: () => _startScheme(m),
            onKnowMore: () => _knowMoreScheme(
              scheme: m,
              title: 'Monthly $_selectedMetal Scheme',
              points: monthlyPoints,
            ),
          );
        }

        // ── One ANYTIME card per scheme (a == null -> built-in default) ──
        Widget buildAnytime(dynamic a) {
          final anytimeMin = a != null
              ? a.minDailyDeposit
              : (isSilver ? 500 : 5000);
          final anytimePoints = [
            'Start from as low as ₹$anytimeMin',
            'No fixed schedule',
            'Grow your ${a != null ? _assetLabel(a) : metalWord} savings',
          ];
          return _schemeTypeCard(
            title: 'Anytime $_selectedMetal Scheme',
            description: 'Save at your convenience with flexible deposits.',
            points: anytimePoints,
            buttonText: a != null && a.joined == true
              ? 'Pay Now' : 'Join Now',
            isJoined: a != null && a.joined == true,
            icon: Icons.account_balance_wallet_rounded,
            illustration: 'assets/images/scheme_anytime.png',
            gradient: darkGradient,
            lightCard: false,
            accent: accent,
            buttonGradient: lightButton,
            onTap: a != null
                ? () => _startScheme(a)
                : () {
                    final isSilver = _isSilverSelected;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => KYCScreen(
                          isSilverScheme: isSilver,
                          schemeId: '',
                          name: 'Anytime $_selectedMetal Scheme',
                          maturityDate: null,
                        ),
                      ),
                    );
                  },
            onKnowMore: a != null
                ? () => _knowMoreScheme(
                    scheme: a,
                    title: 'Anytime $_selectedMetal Scheme',
                    points: anytimePoints,
                  )
                : () {
                    final isSilver = _isSilverSelected;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AboutDigigoldScreen(
                          scheme: AboutSchemeData(
                            backgroundImage: isSilver
                                ? 'assets/images/img27.png'
                                : 'assets/images/img13.png',
                            sideImage: isSilver
                                ? 'assets/images/img10.png'
                                : 'assets/images/img9.png',
                            label: isSilver
                                ? 'DigiSilver Savings'
                                : 'DigiGold Savings',
                            title: 'Anytime $_selectedMetal Scheme',
                            point1: anytimePoints[0],
                            point2: anytimePoints[1],
                            point3: anytimePoints[2],
                            schemeId: '',
                            name: 'Anytime $_selectedMetal Scheme',
                            isSilverScheme: isSilver,
                            minAmount: isSilver ? 500 : 5000,
                            durationDays: 0,
                            lockInPeriod: 0,
                            maturityDate: null,
                          ),
                        ),
                      ),
                    );
                  },
          );
        }

        final cards = <Widget>[];

        // One card -> full width. Two or more -> side by side with dots.
        void addSection(List<Widget> section) {
          if (section.isEmpty) return;
          if (cards.isNotEmpty) cards.add(const SizedBox(height: 14));
          cards.add(
            section.length == 1
                ? section.first
                : _sideBySideCards(context, section),
          );
        }

        addSection([for (final d in dailySchemes) buildDaily(d)]);
        addSection([for (final m in monthlySchemes) buildMonthly(m)]);
        addSection(
          anytimeSchemes.isEmpty
              ? [buildAnytime(null)] // no backend scheme -> default card
              : [for (final a in anytimeSchemes) buildAnytime(a)],
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(key: ValueKey(_selectedMetal), children: cards),
        );
      },
    );
  }

  /// One scheme card. [lightCard] = light card with dark text and a coloured
  /// button; otherwise dark card with white text and a white button.
  /// [accent] is the text/border colour used on the buttons.
  Widget _schemeTypeCard({
    required String title,
    required String description,
    required List<String> points,
    required String buttonText,
    required bool isJoined,
    required IconData icon,
    required String illustration,
    required List<Color> gradient,
    required bool lightCard,
    required Color accent,
    required List<Color> buttonGradient,
    required VoidCallback onTap,
    required VoidCallback onKnowMore,
  }) {
    final titleColor = lightCard ? const Color(0xFF2B1A0A) : Colors.white;
    final textColor = lightCard ? const Color(0xFF5A4630) : Colors.white;
    final checkColor = lightCard
        ? const Color(0xFFB8860B)
        : const Color(0xFFF4C95D);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradient,
          ),
        ),
        child: Stack(
          children: [
            // Joined status badge at the top-right of the scheme card.
            if (isJoined)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF9AD5AF),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 12,
                        color: Color(0xFF168348),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'JOINED',
                        style: _poppins(
                          9,
                          FontWeight.w800,
                          const Color(0xFF168348),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Illustration on the right
            Positioned(
              right: -4,
              top: 0,
              child: Image.asset(
                illustration,
                width: 140,
                height: 150,
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(width: 140, height: 150),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lightCard
                              ? const Color(0xFFE9B64B)
                              : const Color(0xFFE9A23B),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 96),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: _poppins(
                                  16,
                                  FontWeight.w700,
                                  titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: _poppins(11, FontWeight.w400, textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  for (final p in points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, left: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: checkColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              p,
                              style: _poppins(11.5, FontWeight.w500, textColor),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // ── START / PAY + KNOW MORE ──
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: onTap,
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: lightCard
                                  ? LinearGradient(colors: buttonGradient)
                                  : null,
                              color: lightCard ? null : Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    buttonText,
                                    overflow: TextOverflow.ellipsis,
                                    style: _poppins(
                                      12.5,
                                      FontWeight.w600,
                                      lightCard ? Colors.white : accent,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 17,
                                  color: lightCard ? Colors.white : accent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: onKnowMore,
                          child: Container(
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: lightCard ? accent : Colors.white70,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              'Know More',
                              style: _poppins(
                                12.5,
                                FontWeight.w600,
                                lightCard ? accent : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showroomCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/img16.png', fit: BoxFit.cover),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF4E0),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFD4AF37),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Store Location',
                        style: _poppins(
                          15,
                          FontWeight.w700,
                          const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visit our showroom today',
                        style: _poppins(
                          12,
                          FontWeight.w400,
                          Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _openStoreDirections(context),
                        child: Text(
                          'Get Directions ->',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _learnCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/img16.png', fit: BoxFit.cover),
                Container(color: Colors.black.withValues(alpha: 0.38)),
                SizedBox(
                  height: 200,
                  child: _isPlaying
                      ? GestureDetector(
                          onVerticalDragUpdate: (_) {},
                          onHorizontalDragUpdate: (_) {},
                          child: YoutubePlayer(
                            controller: _controller,
                            showVideoProgressIndicator: true,
                            bottomActions: const [],
                          ),
                        )
                      : Stack(
                          children: [
                            Image.asset(
                              'assets/images/img16.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                            Container(
                              color: Colors.black.withValues(alpha: 0.38),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _isPlaying = true);
                                  _controller.play();
                                },
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 38,
                                    color: Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why Choose Digital Gold?',
                  style: _poppins(15, FontWeight.w700, const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn the benefits of digital gold investment',
                  style: _poppins(12, FontWeight.w400, Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _needHelpCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFCDD2),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: _maroonRight,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Help?',
                      style: _poppins(
                        16,
                        FontWeight.w700,
                        const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '24/7 customer support available',
                      style: _poppins(
                        12,
                        FontWeight.w400,
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _callNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroonRight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Contact',
                    style: _poppins(14, FontWeight.w600, Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final phone = "918610676308";
                    final url = Uri.parse("https://wa.me/$phone");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      debugPrint("Could not open WhatsApp");
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(
                      color: Color(0xFF25D366),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'WhatsApp',
                    style: _poppins(
                      14,
                      FontWeight.w600,
                      const Color(0xFF25D366),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BANNER POPUP
// ============================================================

/// Card with the banner image(s) and a close button.
/// With more than one banner it changes by itself every few seconds.
class _BannerPopup extends StatefulWidget {
  final List<String?> images;

  const _BannerPopup({required this.images});

  @override
  State<_BannerPopup> createState() => _BannerPopupState();
}

class _BannerPopupState extends State<_BannerPopup> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _page = 0;

  double _aspect = 0.95;
  ImageStream? _aspectStream;
  ImageStreamListener? _aspectListener;

  int get _count => widget.images.length;

  ImageProvider _providerFor(String? url) {
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    return const AssetImage('assets/images/img8.png');
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _readAspect();
  }

  /// Reads the real size of the first image to shape the card.
  void _readAspect() {
    final stream = _providerFor(
      widget.images.first,
    ).resolve(const ImageConfiguration());
    final listener = ImageStreamListener((info, _) {
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (mounted && w > 0 && h > 0) setState(() => _aspect = w / h);
    }, onError: (_, __) {});
    stream.addListener(listener);
    _aspectStream = stream;
    _aspectListener = listener;
  }

  @override
  void dispose() {
    final l = _aspectListener;
    if (l != null) _aspectStream?.removeListener(l);
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_count <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final current = _pageController.page?.round() ?? 0;
      _pageController.animateToPage(
        current + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    double width = size.width * 0.88 > 420 ? 420.0 : size.width * 0.88;
    double height = width / _aspect;
    final maxHeight = size.height * 0.75;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * _aspect;
    }

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          child: Stack(
            children: [
              // ── Banner(s) ──
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Listener(
                    onPointerDown: (_) => _timer?.cancel(),
                    onPointerUp: (_) => _startTimer(),
                    onPointerCancel: (_) => _startTimer(),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _page = i % _count),
                      itemBuilder: (context, index) {
                        final url = widget.images[index % _count];
                        final hasUrl = url != null && url.isNotEmpty;

                        return ColoredBox(
                          color: Colors.white,
                          child: hasUrl
                              ? Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  // Smooth fade-in once the first frame is ready.
                                  frameBuilder:
                                      (context, child, frame, wasSyncLoaded) {
                                        if (wasSyncLoaded) return child;
                                        return AnimatedOpacity(
                                          opacity: frame == null ? 0 : 1,
                                          duration: const Duration(
                                            milliseconds: 350,
                                          ),
                                          curve: Curves.easeOut,
                                          child: child,
                                        );
                                      },
                                  // Shown while the image is downloading.
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    final total = progress.expectedTotalBytes;
                                    return _BannerLoading(
                                      value: total == null
                                          ? null
                                          : progress.cumulativeBytesLoaded /
                                                total,
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/img8.png',
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/img8.png',
                                  fit: BoxFit.contain,
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Dots (only with more than one banner) ──
              if (_count > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_count, (i) {
                      final on = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: on ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: on ? Colors.white : Colors.white54,
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 3),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

              // ── Close button ──
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.white,
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
}

// ============================================================
// STATIC TEST SCHEME (only used while _useStaticSchemeData = true)
// ============================================================
class _StaticScheme {
  final String id;
  final String name;
  final String assetType;
  final String schemaType;
  final String? purity;
  final int minDailyDeposit;
  final bool joined;
  final int durationDays;
  final int durationMonths;
  final int lockInPeriod;
  final DateTime? maturityDate;

  const _StaticScheme({
    required this.id,
    required this.name,
    required this.assetType,
    required this.schemaType,
    required this.minDailyDeposit,
    this.purity,
    this.joined = false,
    this.durationDays = 330,
    this.durationMonths = 11,
    this.lockInPeriod = 0,
    this.maturityDate,
  });
}

// ============================================================
// SIDE-BY-SIDE CARDS  (horizontal swipe + dot indicator below)
// ============================================================
class _SideBySideCards extends StatefulWidget {
  final List<Widget> cards;
  final Color activeColor;

  const _SideBySideCards({required this.cards, required this.activeColor});

  @override
  State<_SideBySideCards> createState() => _SideBySideCardsState();
}

class _SideBySideCardsState extends State<_SideBySideCards> {
  static const double _gap = 12;

  final ScrollController _scroll = ScrollController();
  int _page = 0;
  double _cardWidth = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  int _pageFor(double offset) {
    if (_cardWidth <= 0) return 0;
    return (offset / (_cardWidth + _gap)).round().clamp(
      0,
      widget.cards.length - 1,
    );
  }

  void _onScroll() {
    final i = _pageFor(_scroll.offset);
    if (i != _page) setState(() => _page = i);
  }

  /// Snap to the nearest card when the user stops scrolling.
  bool _onScrollEnd(ScrollEndNotification n) {
    if (!_scroll.hasClients || _cardWidth <= 0) return false;
    final target = (_pageFor(_scroll.offset) * (_cardWidth + _gap)).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );
    if ((target - _scroll.offset).abs() > 1) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // 36 = the 18 + 18 horizontal padding of the home scroll view.
    _cardWidth = (MediaQuery.sizeOf(context).width - 36) * 0.9;

    return Column(
      children: [
        NotificationListener<ScrollEndNotification>(
          onNotification: _onScrollEnd,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < widget.cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    SizedBox(width: _cardWidth, child: widget.cards[i]),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cards.length, (i) {
            final on = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: on ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: on ? widget.activeColor : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ============================================================
// BANNER LOADING PLACEHOLDER (shown while the banner downloads)
// ============================================================
class _BannerLoading extends StatefulWidget {
  /// 0..1 download progress, or null when the size is unknown.
  final double? value;

  const _BannerLoading({this.value});

  @override
  State<_BannerLoading> createState() => _BannerLoadingState();
}

class _BannerLoadingState extends State<_BannerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        // Soft pulsing grey so the card never looks like an empty white box.
        final color = Color.lerp(
          const Color(0xFFEDEDED),
          const Color(0xFFF8F8F8),
          _anim.value,
        );
        return ColoredBox(color: color!, child: child);
      },
      child: Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            value: widget.value,
            strokeWidth: 3,
            color: const Color(0xFFC6003A),
            backgroundColor: Colors.black12,
          ),
        ),
      ),
    );
  }
}
