// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Models/savings_models.dart';
import 'package:my_app/Presentation/about_digigold_screen.dart';
import 'package:my_app/Presentation/instant_gold_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final PageController _promoController = PageController(viewportFraction: 1);
  int _promoPage = 0;

  final PageController _savingSchemesController = PageController(
    viewportFraction: 1,
  );
  int _savingSchemesPage = 0;

  // ── NEW: dashboard carousel ──
  final PageController _dashboardController = PageController(
    viewportFraction: 1,
  );
  int _dashboardPage = 0;

  static const Color _maroonLeft = Color(0xFFC6003A);
  static const Color _maroonRight = Color(0xFF27080D);
  bool _isPlaying = false;
  late YoutubePlayerController _controller;

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
    final Uri phoneUri = Uri(scheme: 'tel', path: '04522350270');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open dialer')));
    }
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
    Future.microtask(() {
      Provider.of<GoldPriceProvider>(context, listen: false).fetchGoldPrice();
      Provider.of<BannerProvider>(context, listen: false).fetchBanners();
      Provider.of<SchemeProvider>(context, listen: false).fetchSchemes();
      Provider.of<SavingsProvider>(
        context,
        listen: false,
      ).fetchSavingsDetails();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _promoController.dispose();
    _savingSchemesController.dispose();
    _dashboardController.dispose(); // ── NEW ──
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
                            Row(
                              children: [
                                /// 🔶 FIRST CARD
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: SizedBox(
                                      height: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Image.asset(
                                                "assets/images/img6.png",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Image.asset(
                                                "assets/images/img11.png",
                                                height: 30,
                                                width: 30,
                                              ),
                                            ),
                                            Consumer<GoldPriceProvider>(
                                              builder: (context, provider, child) {
                                                final gold = provider.goldData;
                                                final sellPrice =
                                                    gold?.sellPrice ?? 0;

                                                return Positioned(
                                                  left: 10,
                                                  bottom: 10,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Gold",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "₹${formatIndianCurrency(sellPrice)}",
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const Text(
                                                        "22KT Per gram",
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                /// 🔶 SECOND CARD
                                /// 🔶 SECOND CARD (Silver)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: SizedBox(
                                      height: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Image.asset(
                                                "assets/images/img7.png",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Image.asset(
                                                "assets/images/img10.png",
                                                height: 30,
                                                width: 30,
                                              ),
                                            ),
                                            Consumer<GoldPriceProvider>(
                                              builder: (context, provider, child) {
                                                final silver = provider
                                                    .silverData; // ✅ public getter
                                                final sellPrice =
                                                    silver?.sellPrice ?? 0;
                                                return Positioned(
                                                  left: 10,
                                                  bottom: 10,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Silver",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "₹${formatIndianCurrency(sellPrice)}",
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const Text(
                                                        "Per gram",
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
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
                    ),
                    Expanded(
                      flex: 150,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        child: ColoredBox(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              18,
                              14,
                              18,
                              navLift + 76,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Rate updated on 10:32 AM 22-Jan-2026',
                                  textAlign: TextAlign.center,
                                  style: _poppins(
                                    11,
                                    FontWeight.w400,
                                    Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── Dashboard carousel + dots ──
                                _dashboardCarousel(context),
                                const SizedBox(height: 20),

                                _goldRateCard(context),
                                const SizedBox(height: 20),

                                Text(
                                  'Saving Schemes',
                                  style: _poppins(
                                    17,
                                    FontWeight.w700,
                                    const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // ── Saving schemes carousel + dots ──
                                _savingSchemesCarousel(context),
                                const SizedBox(height: 24),
                                _promoCarousel(context),
                                const SizedBox(height: 26),
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

  // ── Dashboard as a PageView carousel ──
  Widget _dashboardCarousel(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final savingsList = provider.savingsList;

        if (savingsList.isEmpty) {
          return const SizedBox();
        }

        return Column(
          children: [
            SizedBox(
              height: 250,

              child: PageView.builder(
                controller: _dashboardController,

                itemCount: savingsList.length,

                onPageChanged: (i) {
                  setState(() {
                    _dashboardPage = i;
                  });
                },

                itemBuilder: (context, index) {
                  return _dashboardCard(context, savingsList[index]);
                },
              ),
            ),

            const SizedBox(height: 10),

            _dotIndicator(
              count: savingsList.length,
              currentPage: _dashboardPage,
            ),
          ],
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

                  '${data.totalGoldAccumulated.toStringAsFixed(4)} g',
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
                      '${data.totalGoldAccumulated.toStringAsFixed(4)} g',

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

  Widget _goldRateCard(BuildContext context) {
    return Consumer<GoldPriceProvider>(
      builder: (context, provider, child) {
        final gold = provider.goldData;
        final silver = provider.silverData;

        return SizedBox(
          height: 235,
          child: PageView(
            children: [
              /// GOLD CARD
              _metalCard(
                context: context,
                title: "22KT Live Gold Rate",
                sellPrice: gold?.sellPrice ?? 8742,
                date: gold?.date ?? '',
                time: gold?.time ?? '',
                image: "assets/images/img11.png",
                smallImage: "assets/images/img21.png",
                bgColor: const Color(0xFFF8F1E5),
                borderColor: const Color(0xFFE9DAB8),
                imageBg: const Color(0xFFF2DA96),
                iconBg: const Color(0xFFF1D78A),
                gradient: const [Color(0xFF5A0018), Color(0xFFD1004B)],
                buttonText: "Buy Gold",
                metalType: "gold",
              ),

              /// SILVER CARD
              _metalCard(
                context: context,
                title: "999 Live Silver Rate",
                sellPrice: silver?.sellPrice ?? 108,
                date: silver?.date ?? '',
                time: silver?.time ?? '',
                image: "assets/images/img10.png",
                smallImage: "assets/images/img26.png",
                bgColor: const Color(0xFFF4F5F7),
                borderColor: const Color(0xFFD7DCE2),
                imageBg: const Color(0xFFE2E6EC),
                iconBg: const Color(0xFFDDE2E8),
                gradient: const [Color(0xFF434A54), Color(0xFF9AA3AF)],
                buttonText: "Buy Silver",
                metalType: "silver",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metalCard({
    required BuildContext context,
    required String title,
    required dynamic sellPrice,
    required String date,
    required String time,
    required String image,
    required String smallImage,
    required Color bgColor,
    required Color borderColor,
    required Color imageBg,
    required Color iconBg,
    required List<Color> gradient,
    required String buttonText,
    required String metalType,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          /// TOP CONTENT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Row(
                      children: [
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(smallImage),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          title,
                          style: _poppins(
                            13,
                            FontWeight.w500,
                            const Color(0xFF6F6F6F),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// PRICE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${formatIndianCurrency(sellPrice)}",
                          style: _poppins(
                            30,
                            FontWeight.w700,
                            const Color(0xFF101010),
                          ),
                        ),

                        const SizedBox(width: 4),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            "/gram",
                            style: _poppins(
                              16,
                              FontWeight.w500,
                              const Color(0xFF7B7B7B),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// UPDATE
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

                        Text(
                          "Updated $date $time",
                          style: _poppins(
                            11,
                            FontWeight.w400,
                            const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// IMAGE
              Container(
                height: 78,
                width: 78,
                decoration: BoxDecoration(
                  color: imageBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// BUTTON
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BuyGoldScreen(metalType: metalType),
                ),
              );
            },
            child: Container(
              height: 58,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: gradient,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    buttonText,
                    style: _poppins(17, FontWeight.w600, Colors.white),
                  ),

                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoCarousel(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, provider, child) {
        final banners = provider.banners;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (banners.isEmpty) {
          return const SizedBox();
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: PageView.builder(
                controller: _promoController,
                padEnds: false,
                itemCount: banners.length,
                onPageChanged: (i) {
                  setState(() => _promoPage = i);
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child:
                            banner.bannerImage != null &&
                                banner.bannerImage!.isNotEmpty
                            ? Image.network(
                                banner.bannerImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/img8.png",
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                "assets/images/img8.png",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            _dotIndicator(count: banners.length, currentPage: _promoPage),
          ],
        );
      },
    );
  }

  Widget _savingSchemesCarousel(BuildContext context) {
    return Consumer<SchemeProvider>(
      builder: (context, provider, child) {
        final schemes = provider.schemes;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (schemes.isEmpty) {
          return const SizedBox();
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 270,
              child: PageView.builder(
                controller: _savingSchemesController,
                padEnds: false,
                itemCount: schemes.length,
                onPageChanged: (index) {
                  setState(() {
                    _savingSchemesPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final scheme = schemes[index];

                  final isSilver = scheme.assetType.toLowerCase() == "silver";

                  return _savingSchemesCard(
                    context,
                    backgroundImage: isSilver
                        ? 'assets/images/img27.png'
                        : 'assets/images/img13.png',
                    sideImage: isSilver
                        ? 'assets/images/img10.png'
                        : 'assets/images/img9.png',
                    schemeLabel: isSilver
                        ? 'DigiSilver Savings'
                        : 'DigiGold Savings',
                    heading: scheme.name,
                    bullets: (
                      'Start from ₹${scheme.minDailyDeposit}',
                      'Lock-in ${scheme.lockInPeriod} days',
                      '${scheme.durationDays} days scheme',
                    ),
                    initialAboutPage: index,
                    isSilverScheme: isSilver,
                    schemeId: scheme.id,
                    name: scheme.name,
                    // ✅ PASS HERE
                    minDailyDeposit: scheme.minDailyDeposit,
                    durationDays: scheme.durationDays,
                    lockInPeriod: scheme.lockInPeriod,
                    joined: scheme.joined,
                    maturityDate: scheme.maturityDate,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            _dotIndicator(
              count: schemes.length,
              currentPage: _savingSchemesPage,
            ),
          ],
        );
      },
    );
  }

  Widget _savingSchemesCard(
    BuildContext context, {
    required String backgroundImage,
    required String sideImage,
    required String schemeLabel,
    required String heading,
    required (String, String, String) bullets,
    required int initialAboutPage,
    required bool isSilverScheme,
    required String schemeId,
    required String name,
    required int minDailyDeposit,
    required int durationDays,
    required int lockInPeriod,
    required DateTime maturityDate,
    required bool joined,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // ✅ Background
          Positioned.fill(
            child: Image.asset(backgroundImage, fit: BoxFit.cover),
          ),

          // ✅ Joined Badge
          if (joined)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_maroonRight, _maroonLeft]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Joined",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Stack(
            children: [
              Positioned(
                right: -8,
                bottom: 64,
                child: Image.asset(
                  sideImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.savings_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          schemeLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      heading,
                      style: _poppins(21, FontWeight.w700, Colors.white),
                    ),

                    const SizedBox(height: 10),

                    _bullet(context, bullets.$1),
                    _bullet(context, bullets.$2),
                    _bullet(context, bullets.$3),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // ✅ JOIN / PAY NOW
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => KYCScreen(
                                    isSilverScheme: isSilverScheme,
                                    schemeId: schemeId,
                                    name: name,
                                    maturityDate: maturityDate,
                                  ),
                                ),
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFB8860B),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: Text(
                              joined ? 'Pay Now' : 'Join Now',
                              style: _poppins(
                                14,
                                FontWeight.w600,
                                const Color(0xFFB8860B),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ✅ KNOW MORE
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AboutDigigoldScreen(
                                    scheme: AboutSchemeData(
                                      backgroundImage: backgroundImage,
                                      sideImage: sideImage,
                                      label: schemeLabel,
                                      title: heading,
                                      point1: bullets.$1,
                                      point2: bullets.$2,
                                      point3: bullets.$3,
                                      schemeId: schemeId,
                                      name: name,
                                      isSilverScheme: isSilverScheme,
                                      minAmount: minDailyDeposit,
                                      durationDays: durationDays,
                                      lockInPeriod: lockInPeriod,
                                      maturityDate: maturityDate,
                                    ),
                                  ),
                                ),
                              );
                            },

                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: Text(
                              'Know More',
                              style: _poppins(
                                14,
                                FontWeight.w600,
                                Colors.white,
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
        ],
      ),
    );
  }

  Widget _bullet(BuildContext context, String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFD4AF37),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(t, style: _poppins(13, FontWeight.w400, Colors.white)),
          ),
        ],
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
                      print("Could not open WhatsApp");
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
