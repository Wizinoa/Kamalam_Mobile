// ignore_for_file: use_build_context_synchronously, prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Models/passbook_models.dart';
import 'package:my_app/Presentation/home_screen.dart';
import 'package:my_app/Providers/passbook_providers.dart';
import 'package:my_app/Providers/receipt_provider.dart';
import 'package:my_app/Providers/reward_provider.dart';
import 'package:my_app/Utils/back_screen.dart';
import 'package:my_app/Utils/bottom_navigation.dart';
import 'package:provider/provider.dart';

class PassbookScreen extends StatefulWidget {
  const PassbookScreen({super.key});

  @override
  State<PassbookScreen> createState() => _PassbookScreenState();
}

class _PassbookScreenState extends State<PassbookScreen> {
  bool _showRewards = false;

  // The three passbook tabs are filtered using the API's schemeType field.
  String _selectedSchemeType = 'daily';

  // ---------------------------------------------------------------------------
  // TRANSACTION TABLE COLUMN WIDTHS
  // The header and every row use these SAME flex values, so columns always
  // line up. Change a number here to resize a column everywhere.
  // ---------------------------------------------------------------------------
  static const int _colStatus = 9;
  static const int _colDate = 15;
  static const int _colAmount = 16;
  static const int _colPurity = 12;
  static const int _colRate = 18;
  static const int _colWeight = 22;

  // Horizontal padding inside the row card (10) + border width (1).
  // The header uses the same value so its text starts at the same x-position.
  static const double _rowSidePadding = 10;
  static const double _rowBorderWidth = 1;

  List<PassbookModels> _schemesForSelectedTab(
    List<PassbookModels> allSchemes,
  ) {
    return allSchemes
        .where((scheme) =>
            scheme.schemeType.toLowerCase() == _selectedSchemeType)
        .toList();
  }

  void _selectSchemeTab(String schemeType) {
    if (_selectedSchemeType == schemeType) return;

    setState(() {
      _selectedSchemeType = schemeType;
      _schemeCardPage = 0;
      _showRewards = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_schemeCardController.hasClients) {
        _schemeCardController.jumpToPage(0);
      }

      final provider = Provider.of<PassbookProviders>(
        context,
        listen: false,
      );
      final filtered = _schemesForSelectedTab(provider.schemes);

      Provider.of<ReceiptsProvider>(context, listen: false).clear();
      Provider.of<RewardProvider>(context, listen: false).clear();

      if (filtered.isNotEmpty) {
        _fetchSchemeHistory(filtered.first.savingsId);
      }
    });
  }

  Future<void> _fetchSchemeHistory(String savingsId) async {
    await Future.wait([
      Provider.of<ReceiptsProvider>(
        context,
        listen: false,
      ).fetchReceipts(savingsId),
      Provider.of<RewardProvider>(
        context,
        listen: false,
      ).fetchRewards(savingsId),
    ]);
  }

  // Carousel controller for scheme cards
  final PageController _schemeCardController = PageController();
  int _schemeCardPage = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final passbookProvider = Provider.of<PassbookProviders>(
        context,
        listen: false,
      );

      await passbookProvider.fetchSavingsDetails();

      if (passbookProvider.schemes.isNotEmpty) {
        final dailySchemes = passbookProvider.schemes
            .where((scheme) => scheme.schemeType.toLowerCase() == 'daily')
            .toList();

        // Load the first Daily scheme initially; fall back to the first
        // available scheme if the API has no Daily records.
        final firstScheme = dailySchemes.isNotEmpty
            ? dailySchemes.first
            : passbookProvider.schemes.first;

        if (mounted && dailySchemes.isEmpty) {
          setState(() => _selectedSchemeType = firstScheme.schemeType);
        }

        await _fetchSchemeHistory(firstScheme.savingsId);
      } else {
        // No schemes — clear stale data so UI shows empty state
        Provider.of<ReceiptsProvider>(context, listen: false).clear();
        Provider.of<RewardProvider>(context, listen: false).clear();
      }
    });
  }

  String formatAmount(num amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    }

    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }

    return amount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _schemeCardController.dispose();
    super.dispose();
  }

  final p = (double s, FontWeight w, Color c) =>
      GoogleFonts.poppins(fontSize: s, fontWeight: w, color: c, height: 1.2);

  Widget _dotIndicator({required int count, required int currentPage}) {
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
            color: on ? const Color(0xFF3A0013) : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION TABLE HELPERS
  // ---------------------------------------------------------------------------

  /// One header cell. Same flex + same alignment as the matching row cell.
  Widget _txnHeaderCell(
    String label,
    int flex,
    TextStyle Function(double, FontWeight, Color) p,
  ) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            style: p(10, FontWeight.w500, const Color(0xFF7D7D7D)),
          ),
        ),
      ),
    );
  }

  /// One data cell. Same flex + same alignment as the matching header cell.
  Widget _txnCell(
    String text,
    int flex,
    TextStyle Function(double, FontWeight, Color) p, {
    FontWeight weight = FontWeight.w500,
    Color color = const Color(0xFF2D2D2D),
  }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 1,
            style: p(11, weight, color),
          ),
        ),
      ),
    );
  }

  Widget _buildTxnHeader(TextStyle Function(double, FontWeight, Color) p) {
    return Padding(
      // Match the row card: horizontal padding + border width
      padding: const EdgeInsets.symmetric(
        horizontal: _rowSidePadding + _rowBorderWidth,
      ),
      child: Row(
        children: [
          _txnHeaderCell('Status', _colStatus, p),
          _txnHeaderCell('Date', _colDate, p),
          _txnHeaderCell('Amount', _colAmount, p),
          _txnHeaderCell('Purity', _colPurity, p),
          _txnHeaderCell('Gold Rate', _colRate, p),
          _txnHeaderCell('Saved Weight', _colWeight, p),
        ],
      ),
    );
  }

  Widget _buildTxnRow(
    dynamic t,
    TextStyle Function(double, FontWeight, Color) p,
  ) {
    final date = DateTime.tryParse(t.createdAt.toString());

    final purityText = (t.purity == null || t.purity!.trim().isEmpty)
        ? '-'
        : t.purity!.toUpperCase();

    final rateText = t.goldRate != null ? '₹${t.goldRate!}' : '-';

    final weightText = '${(t.grams).toStringAsFixed(4)}g';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: _rowSidePadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: _rowBorderWidth,
        ),
      ),
      child: Row(
        children: [
          // Status
          Expanded(
            flex: _colStatus,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.check_circle,
                size: 14,
                color: Color(0xFF79D09C),
              ),
            ),
          ),
          // Date
          _txnCell(
            date != null ? DateFormat('dd MMM').format(date) : '-',
            _colDate,
            p,
          ),
          // Amount
          _txnCell('₹${formatAmount(t.amount)}', _colAmount, p),
          // Purity
          _txnCell(purityText, _colPurity, p, weight: FontWeight.w600),
          // Gold Rate
          _txnCell(rateText, _colRate, p),
          // Saved Weight
          _txnCell(weightText, _colWeight, p),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = (double s, FontWeight w, Color c) =>
        GoogleFonts.poppins(fontSize: s, fontWeight: w, color: c, height: 1.2);

    return WillPopScope(
      onWillPop: () => ExitDialog.show(context),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
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
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Scheme Passbook",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          color: const Color(0xFFF7F7F7),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // DAILY / MONTHLY / ANYTIME TABS
                      Consumer<PassbookProviders>(
                        builder: (context, provider, child) {
                          final all = provider.schemes;
                          return _buildSchemeTypeTabs(all);
                        },
                      ),
                      const SizedBox(height: 16),

                      // SCHEME CARD CAROUSEL
                      Consumer<PassbookProviders>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const SizedBox(
                              height: 260,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final schemes =
                              _schemesForSelectedTab(provider.schemes);

                          if (schemes.isEmpty) {
                            return SizedBox(
                              height: 260,
                              child: Center(
                                child: Text(
                                  'No schemes found',
                                  style: p(
                                    14,
                                    FontWeight.w500,
                                    Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
                                child: PageView.builder(
                                  controller: _schemeCardController,
                                  itemCount: schemes.length,
                                  onPageChanged: (i) async {
                                    setState(() => _schemeCardPage = i);

                                    final scheme = schemes[i];

                                    // Clear old history before loading the
                                    // selected scheme's receipts and rewards.
                                    Provider.of<ReceiptsProvider>(
                                      context,
                                      listen: false,
                                    ).clear();
                                    Provider.of<RewardProvider>(
                                      context,
                                      listen: false,
                                    ).clear();

                                    await _fetchSchemeHistory(scheme.savingsId);
                                  },
                                  itemBuilder: (context, index) {
                                    final data = schemes[index];
                                    return _schemeCard(p, data);
                                  },
                                ),
                              ),

                              // Dots only when more than 1 scheme
                              if (schemes.length > 1) ...[
                                const SizedBox(height: 10),
                                _dotIndicator(
                                  count: schemes.length,
                                  currentPage: _schemeCardPage,
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // TARGET ACHIEVED SECTION
                      Consumer<PassbookProviders>(
                        builder: (context, passbookProvider, child) {
                          final visibleSchemes = _schemesForSelectedTab(
                            passbookProvider.schemes,
                          );

                          if (passbookProvider.isLoading ||
                              visibleSchemes.isEmpty) {
                            return const SizedBox();
                          }

                          if (_schemeCardPage >= visibleSchemes.length) {
                            return const SizedBox();
                          }

                          final currentScheme = visibleSchemes[_schemeCardPage];

                          final percentage =
                              currentScheme.targetAchievedPercentage;

                          // Hide everything if percentage is 0 or null
                          if (percentage <= 0) {
                            return const SizedBox();
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE5E5E5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Target Achieved',
                                      style: p(
                                        11,
                                        FontWeight.w500,
                                        const Color(0xFF5A5A5A),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${(percentage > 100 ? 100 : percentage).toStringAsFixed(0)}% Completed',
                                      style: p(
                                        11,
                                        FontWeight.w600,
                                        const Color(0xFF00A651),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFE1E1E1),
                                    color: const Color(0xFF00A651),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // TOGGLE: Receipts / Rewards
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECEE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _showRewards = false),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    gradient: _showRewards
                                        ? null
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFF3A0013),
                                              Color(0xFFD1004C),
                                            ],
                                          ),
                                    color: _showRewards
                                        ? Colors.transparent
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Receipts',
                                      style: p(
                                        12,
                                        FontWeight.w600,
                                        _showRewards
                                            ? const Color(0xFF80869A)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _showRewards = true),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    gradient: _showRewards
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF3A0013),
                                              Color(0xFFD1004C),
                                            ],
                                          )
                                        : null,
                                    color: _showRewards
                                        ? null
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Rewards',
                                      style: p(
                                        12,
                                        FontWeight.w600,
                                        _showRewards
                                            ? Colors.white
                                            : const Color(0xFF80869A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // RECEIPTS SECTION
                      if (!_showRewards) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Transaction History',
                            style: p(
                              14,
                              FontWeight.w600,
                              const Color(0xFF2F2F2F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Aligned table header
                        _buildTxnHeader(p),
                        const SizedBox(height: 10),

                        // Aligned table rows
                        Consumer<ReceiptsProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final txns = provider.receipts;

                            if (txns.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No transactions found"),
                              );
                            }

                            return Column(
                              children:
                                  txns.map((t) => _buildTxnRow(t, p)).toList(),
                            );
                          },
                        ),
                      ]
                      // REWARDS SECTION
                      else ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Rewards History',
                            style: p(
                              14,
                              FontWeight.w600,
                              const Color(0xFF2F2F2F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Consumer<RewardProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final rewards = provider.rewards;

                            if (rewards.isEmpty) {
                              return Column(
                                children: [
                                  const SizedBox(height: 18),
                                  Image.asset(
                                    'assets/images/img19.png',
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No rewards found",
                                    style: p(13, FontWeight.w500, Colors.grey),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                              );
                            }

                            return Column(
                              children: rewards.map((reward) {
                                final date = DateTime.tryParse(
                                  reward.date.toString(),
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE5E5E5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.card_giftcard,
                                        color: Color(0xFFF4BE45),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reward.type,
                                              style: p(
                                                13,
                                                FontWeight.w600,
                                                const Color(0xFF2D2D2D),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              reward.description,
                                              style: p(
                                                11,
                                                FontWeight.w400,
                                                Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              date != null
                                                  ? DateFormat(
                                                      'dd MMM yyyy',
                                                    ).format(date)
                                                  : '-',
                                              style: p(
                                                10,
                                                FontWeight.w400,
                                                Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "${reward.amount} pts",
                                        style: p(
                                          14,
                                          FontWeight.w700,
                                          const Color(0xFF00A651),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: AppBottomNavigation(currentIndex: 2),
        ),
      ),
    );
  }

  Widget _buildSchemeTypeTabs(List<PassbookModels> allSchemes) {
    const tabs = [
      {'type': 'daily', 'label': 'Daily'},
      {'type': 'monthly', 'label': 'Monthly'},
      {'type': 'anytime', 'label': 'Anytime'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEE),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: tabs.map((tab) {
          final type = tab['type']!;
          final label = tab['label']!;
          final isSelected = _selectedSchemeType == type;
          final count = allSchemes
              .where((scheme) => scheme.schemeType.toLowerCase() == type)
              .length;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _selectSchemeTab(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF3A0013), Color(0xFFD1004C)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF80869A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white24
                            : const Color(0xFFDADAE0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Scheme card widget
  Widget _schemeCard(
    TextStyle Function(double, FontWeight, Color) p,
    PassbookModels data,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A0013), Color(0xFFD1004C)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.white, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.schemeName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: p(12, FontWeight.w700, Colors.white),
                  ),
                ),
                const Icon(Icons.help, color: Colors.white, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _kv(p, 'Scheme Name', data.schemeName)),
              Expanded(
                child: _kv(p, 'Scheme ID', data.allocatedId, right: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _kv(
                  p,
                  'Total Amount Paid',
                  '₹${data.totalSavedAmount.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _kv(
                  p,
                  'Average Rate / g',
                  '₹${data.averageRate.toStringAsFixed(2)}',
                  right: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _kv(
                  p,
                  'Saved Weight',
                  '${(data.savedWeight).toStringAsFixed(4)}g',
                ),
              ),
              Expanded(
                child: _kv(
                  p,
                  'Benefit on Maturity',
                  '₹${data.benefitEarned.toStringAsFixed(2)}',
                  right: true,
                  valueColor: const Color(0xFF00A651),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Reward + Total Gold
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A0013), Color(0xFFD1004C)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Rewards :   ${data.rewardsEarned.toStringAsFixed(0)} pts',
                    style: p(10, FontWeight.w600, const Color(0xFFF4BE45)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB13A49),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 14,
                        color: Color(0xFFF4BE45),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total ${data.assetType} Saved\n${data.totalGoldSaved.toStringAsFixed(4)}g',
                        style: p(8, FontWeight.w500, Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Date of Joining
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _kv(
                    p,
                    'Date of Joining',
                    data.dateOfJoining != null
                        ? '${data.dateOfJoining!.day} '
                              '${_monthName(data.dateOfJoining!.month)} '
                              '${data.dateOfJoining!.year}'
                        : '-',
                  ),
                ),
                Expanded(
                  child: _kv(
                    p,
                    'Date of Maturity',
                    data.maturityDate != null
                        ? '${data.maturityDate!.day} '
                              '${_monthName(data.maturityDate!.month)} '
                              '${data.maturityDate!.year}'
                        : '-',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  Widget _kv(
    TextStyle Function(double, FontWeight, Color) p,
    String k,
    String v, {
    bool right = false,
    Color valueColor = const Color(0xFF2D2D2D),
  }) {
    return Column(
      crossAxisAlignment:
          right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(k, style: p(10, FontWeight.w400, const Color(0xFF7A7A7A))),
        const SizedBox(height: 4),
        Text(v, style: p(14, FontWeight.w700, valueColor)),
      ],
    );
  }
}